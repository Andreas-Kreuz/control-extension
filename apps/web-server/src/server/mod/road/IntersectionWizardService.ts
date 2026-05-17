import * as fromEepData from '../../eep/server-data/EepDataStore';
import DomainRoomService from '../../eep/server-data/dynamic/DomainRoomService';
import EepDataSelector from '../eepdata/EepDataSelector';
import RoadSelector from './RoadSelector';
import { trafficLightModelConstantForName } from './RoadSelector';
import PersistentServerStateService from './PersistentServerStateService';
import {
  createDefaultSignalGroups,
  createDraftFromCurrentIntersection,
  generateIntersectionWizardLua,
} from './IntersectionWizardCodegen';
import {
  IntersectionWizardAmpelAppDto,
  IntersectionWizardApproach,
  IntersectionWizardDraftAppDto,
  IntersectionWizardDraftSummaryAppDto,
  IntersectionWizardTurnDirection,
  IntersectionWizardSignalLookupAppDto,
  IntersectionWizardTrafficType,
  TrafficLightModelAppDto,
} from '@ce/web-shared';
import express from 'express';

interface IntersectionWizardState {
  drafts: Record<string, IntersectionWizardDraftAppDto>;
}

interface EepDirectoryProvider {
  getExchangeDirectory(): string;
}

function nowIso(): string {
  return new Date().toISOString();
}

function defaultState(): IntersectionWizardState {
  return { drafts: {} };
}

function normalizeStorageSlot(value: unknown): number {
  const numeric = Number(value ?? -1);
  return Number.isFinite(numeric) ? numeric : -1;
}

const oppositeApproach: Record<IntersectionWizardApproach, IntersectionWizardApproach> = {
  NORTH: 'SOUTH',
  NORTH_EAST: 'SOUTH_WEST',
  EAST: 'WEST',
  SOUTH_EAST: 'NORTH_WEST',
  SOUTH: 'NORTH',
  SOUTH_WEST: 'NORTH_EAST',
  WEST: 'EAST',
  NORTH_WEST: 'SOUTH_EAST',
};

function isApproach(value: unknown): value is IntersectionWizardApproach {
  return (
    value === 'NORTH' ||
    value === 'NORTH_EAST' ||
    value === 'EAST' ||
    value === 'SOUTH_EAST' ||
    value === 'SOUTH' ||
    value === 'SOUTH_WEST' ||
    value === 'WEST' ||
    value === 'NORTH_WEST'
  );
}

function normalizeApproach(approach: unknown, legacyHeading?: unknown): IntersectionWizardApproach {
  if (isApproach(approach)) return approach;
  if (isApproach(legacyHeading)) return oppositeApproach[legacyHeading];
  return 'SOUTH';
}

function summarizeDraft(draft: IntersectionWizardDraftAppDto): IntersectionWizardDraftSummaryAppDto {
  return {
    id: draft.id,
    name: draft.name,
    updatedAt: draft.updatedAt,
    lanesCount: draft.lanes.length,
    signalGroupsCount: draft.signalGroups.length,
    phasesCount: draft.phases.length,
  };
}

function modelFromSignalName(signalName: string | undefined, models: Record<string, TrafficLightModelAppDto>) {
  if (!signalName) return undefined;
  const normalizedSignalName = signalName.toLocaleLowerCase();
  return Object.values(models).find((model) => normalizedSignalName.includes(model.name.toLocaleLowerCase()));
}

function normalizeDraft(input: Partial<IntersectionWizardDraftAppDto>): IntersectionWizardDraftAppDto {
  const timestamp = nowIso();
  const legacyLaneTrafficTypes = new Map(
    (input.lanes ?? []).map((lane) => [
      lane.id,
      ((lane as { trafficType?: IntersectionWizardTrafficType }).trafficType ?? 'CAR') as IntersectionWizardTrafficType,
    ]),
  );
  const lanes = (input.lanes ?? []).map((lane) => ({
    id: lane.id,
    name: lane.name,
    ...(lane.vehicleMultiplier !== undefined ? { vehicleMultiplier: lane.vehicleMultiplier } : {}),
    signalId: lane.signalId,
    approach: normalizeApproach(
      lane.approach,
      lane.heading ?? (lane as { compassDirection?: IntersectionWizardApproach }).compassDirection,
    ),
    turnDirections:
      lane.turnDirections ?? (lane as { directions?: IntersectionWizardTurnDirection[] }).directions ?? [],
  }));
  const pedestrianCrossings =
    input.pedestrianCrossings?.map((crossing) => ({
      ...crossing,
      approach: normalizeApproach(crossing.approach, crossing.heading),
    })) ?? [];
  const ampeln = input.ampeln ?? [];
  const signalGroups =
    input.signalGroups?.map((group) => ({
      ...group,
      turnDirections:
        group.turnDirections ?? (group as { directions?: IntersectionWizardTurnDirection[] }).directions ?? [],
      trafficType:
        group.trafficType ?? group.laneIds.map((laneId) => legacyLaneTrafficTypes.get(laneId)).find(Boolean) ?? 'CAR',
    })) ?? createDefaultSignalGroups(lanes, (lane) => legacyLaneTrafficTypes.get(lane.id) ?? 'CAR');
  const inferredSupportMultipleLaneSignals =
    (input.routeRules ?? []).length > 0 ||
    signalGroups.some((group) =>
      group.laneIds.some((laneId) => signalGroups.filter((entry) => entry.laneIds.includes(laneId)).length > 1),
    );
  const inferredSupportPedestrianSignals =
    pedestrianCrossings.length > 0 ||
    signalGroups.some((group) => group.trafficType === 'PEDESTRIAN') ||
    ampeln.some(
      (ampel) =>
        ampel.use === 'PEDESTRIAN_ONLY' || ampel.use === 'VEHICLE_AND_PEDESTRIAN' || ampel.trafficType === 'PEDESTRIAN',
    );
  const draft: IntersectionWizardDraftAppDto = {
    id: input.id || `draft-${Date.now()}`,
    name: input.name ?? '',
    luaVariableName: input.luaVariableName ?? 'kreuzung',
    intersectionEepSaveId: normalizeStorageSlot(input.intersectionEepSaveId),
    ...(input.tippStructure !== undefined ? { tippStructure: input.tippStructure } : {}),
    switchInStrictOrder: input.switchInStrictOrder ?? false,
    showLuaCodeImmediately: input.showLuaCodeImmediately ?? false,
    supportPedestrianSignals: input.supportPedestrianSignals ?? inferredSupportPedestrianSignals,
    supportMultipleLaneSignals: input.supportMultipleLaneSignals ?? inferredSupportMultipleLaneSignals,
    staticCams: input.staticCams ?? [],
    createdAt: input.createdAt ?? timestamp,
    updatedAt: timestamp,
    lanes,
    pedestrianCrossings,
    ampeln,
    signalGroups,
    routeRules: input.routeRules ?? [],
    phases: input.phases ?? [],
    generatedLua: '',
  };
  const generated = generateIntersectionWizardLua(draft);
  draft.generatedLua = generated.lua;
  return draft;
}

export default class IntersectionWizardService implements DomainRoomService {
  private eepDataSelector = new EepDataSelector();
  private roadSelector = new RoadSelector();
  private persistentState: PersistentServerStateService<IntersectionWizardState>;

  constructor(
    private router: express.Router,
    eepDirectoryProvider: EepDirectoryProvider,
  ) {
    this.persistentState = new PersistentServerStateService(
      () => eepDirectoryProvider.getExchangeDirectory(),
      defaultState,
    );
    this.registerRoutes();
  }

  getUpdaters = () => [
    {
      updateFromState: (state: Readonly<fromEepData.State>) => {
        this.eepDataSelector.updateFromState(state);
        this.roadSelector.updateFromState(state);
      },
    },
  ];

  getDataProviders = () => [];

  private registerRoutes(): void {
    this.router.get('/road/intersection-wizard/drafts', (_req, res) => {
      res.json(Object.values(this.persistentState.readWizardState().drafts).map(summarizeDraft));
    });

    this.router.get('/road/intersection-wizard/drafts/:id', (req, res) => {
      const draft = this.persistentState.readWizardState().drafts[req.params.id];
      if (!draft) {
        res.status(404).json({ error: 'not found' });
        return;
      }
      res.json(draft);
    });

    this.router.post('/road/intersection-wizard/drafts', (req, res) => {
      const draft = normalizeDraft(req.body as Partial<IntersectionWizardDraftAppDto>);
      const state = this.persistentState.readWizardState();
      state.drafts[draft.id] = draft;
      this.persistentState.writeWizardState(state);
      res.json(draft);
    });

    this.router.delete('/road/intersection-wizard/drafts/:id', (req, res) => {
      const state = this.persistentState.readWizardState();
      delete state.drafts[req.params.id];
      this.persistentState.writeWizardState(state);
      res.json({ ok: true });
    });

    this.router.post('/road/intersection-wizard/generate', (req, res) => {
      const draft = normalizeDraft(req.body as Partial<IntersectionWizardDraftAppDto>);
      const generated = generateIntersectionWizardLua(draft);
      draft.generatedLua = generated.lua;
      res.json({ draft, lua: generated.lua, warnings: generated.warnings });
    });

    this.router.get('/road/intersection-wizard/signals/:id', (req, res) => {
      res.json(this.lookupSignal(req.params.id));
    });

    this.router.get('/road/intersection-wizard/current/:id', (req, res, next) => {
      const intersectionId = req.params.id;
      const intersection = this.roadSelector.getIntersection(intersectionId);
      if (!intersection) {
        next();
        return;
      }
      const lanes = Object.values(this.roadSelector.getIntersections())
        .filter((candidate) => candidate.id === intersection.id)
        .flatMap(() => Object.values(this.roadSelector.getIntersectionLanes()))
        .filter((lane) => lane.intersectionId === intersection.id);
      const ampeln = Object.values(this.roadSelector.getIntersectionTrafficLights()).filter(
        (ampel) => ampel.intersectionId === intersection.id,
      );
      res.json(createDraftFromCurrentIntersection(intersection, lanes, ampeln));
    });
  }

  private lookupSignal(id: string): IntersectionWizardSignalLookupAppDto {
    const signal = this.eepDataSelector.getSignal(id);
    if (!signal) {
      return { id, found: false };
    }

    const model = modelFromSignalName(
      signal.itemNameWithModelPath ?? signal.itemName,
      this.roadSelector.getTrafficLightModels(),
    );
    const suggestedTrafficLightModel = model?.name;
    const lookup: IntersectionWizardSignalLookupAppDto = {
      id,
      found: true,
      position: signal.position,
      tag: signal.tag,
    };
    if (signal.itemName !== undefined) lookup.itemName = signal.itemName;
    if (signal.itemNameWithModelPath !== undefined) lookup.itemNameWithModelPath = signal.itemNameWithModelPath;
    if (signal.signalFunctions !== undefined) lookup.signalFunctions = signal.signalFunctions;
    if (signal.activeFunction !== undefined) lookup.activeFunction = signal.activeFunction;
    if (suggestedTrafficLightModel) lookup.suggestedTrafficLightModel = suggestedTrafficLightModel;
    const suggestedTrafficLightModelConstant =
      model?.luaConstant ?? trafficLightModelConstantForName(suggestedTrafficLightModel);
    if (suggestedTrafficLightModelConstant)
      lookup.suggestedTrafficLightModelConstant = suggestedTrafficLightModelConstant;
    return lookup;
  }

  static defaultAmpelForSignal(signalId: string, index: number): IntersectionWizardAmpelAppDto {
    return {
      id: `ampel-${signalId || index}`,
      name: `A${index}`,
      signalId,
      use: 'VEHICLE_ONLY',
      trafficType: 'CAR',
      modelName: 'Ampel_3er_XXX_mit_FG',
      modelConstant: 'JS2_3er_mit_FG',
    };
  }
}
