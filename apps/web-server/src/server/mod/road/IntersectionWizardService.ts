import * as fromEepData from '../../eep/server-data/EepDataStore';
import DomainRoomService from '../../eep/server-data/dynamic/DomainRoomService';
import EepDataSelector from '../eepdata/EepDataSelector';
import RoadSelector from './RoadSelector';
import { trafficLightModelConstantForName } from './RoadSelector';
import PersistentServerStateService from './PersistentServerStateService';
import {
  createDraftFromCurrentIntersection,
  generateIntersectionWizardLua,
  normalizeLegacyDraftInput,
} from './IntersectionWizardCodegen';
import {
  IntersectionWizardAmpelAppDto,
  IntersectionWizardApproach,
  IntersectionWizardDraftAppDto,
  IntersectionWizardDraftSummaryAppDto,
  IntersectionWizardLaneCountType,
  IntersectionWizardSignalLookupAppDto,
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

function optionalNumber(value: unknown): number | undefined {
  if (typeof value === 'string' && value.trim() === '') return undefined;
  if (value === null || value === undefined) return undefined;
  const numeric = Number(value);
  return Number.isFinite(numeric) ? numeric : undefined;
}

function optionalNumberArray(value: unknown): number[] | undefined {
  if (!Array.isArray(value)) return undefined;
  const numbers = value.map(Number).filter((entry) => Number.isFinite(entry));
  return numbers.length > 0 ? numbers : undefined;
}

function normalizeLaneCountType(value: unknown): IntersectionWizardLaneCountType | undefined {
  return value === 'CONTACTS' || value === 'SIGNALS' || value === 'TRACKS' ? value : undefined;
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

function basename(value: string): string {
  return value.replace(/\\/g, '/').split('/').pop() ?? value;
}

function withoutExtension(value: string): string {
  return value.replace(/\.[^.]+$/, '');
}

function normalizedModelLookupName(itemNameWithModelPath: string): string {
  return withoutExtension(basename(itemNameWithModelPath)).toLocaleLowerCase();
}

function escapeRegExpLiteral(value: string): string {
  return value.replace(/[\\^$*+?.()|[\]{}]/g, '\\$&');
}

function luaPatternToRegExp(pattern: string): RegExp {
  let source = '';
  for (let i = 0; i < pattern.length; i += 1) {
    const char = pattern.charAt(i);
    const next = i + 1 < pattern.length ? pattern.charAt(i + 1) : undefined;
    if (char === '^' || char === '$') {
      source += char;
    } else if (char === '.' && next === '*') {
      source += '.*';
      i += 1;
    } else if (char === '.') {
      source += '.';
    } else if (char === '%' && next !== undefined) {
      source += escapeRegExpLiteral(next);
      i += 1;
    } else {
      source += escapeRegExpLiteral(char);
    }
  }
  return new RegExp(source);
}

function sortedTrafficLightModels(models: Record<string, TrafficLightModelAppDto>) {
  return Object.values(models).sort((a, b) => a.modelNameMatchOrder - b.modelNameMatchOrder);
}

function modelFromSignalName(signalName: string | undefined, models: Record<string, TrafficLightModelAppDto>) {
  if (!signalName) return undefined;
  const normalizedSignalName = normalizedModelLookupName(signalName);
  const patternModel = sortedTrafficLightModels(models).find((model) =>
    model.modelNamePatterns.some((pattern) => luaPatternToRegExp(pattern).test(normalizedSignalName)),
  );
  if (patternModel) return patternModel;

  return Object.values(models).find((model) => normalizedSignalName.includes(model.name.toLocaleLowerCase()));
}

export function inferTrafficLightModelConstantFromItemName(
  itemNameWithModelPath: string | undefined,
  models: Record<string, TrafficLightModelAppDto>,
) {
  const model = modelFromSignalName(itemNameWithModelPath, models);
  return model?.luaConstant ?? trafficLightModelConstantForName(model?.name);
}

function normalizeDraft(input: Partial<IntersectionWizardDraftAppDto>): IntersectionWizardDraftAppDto {
  const timestamp = nowIso();
  const normalizedInput = normalizeLegacyDraftInput(input);
  const lanes = (normalizedInput.lanes ?? []).map((lane) => {
    const countType = normalizeLaneCountType(lane.countType);
    const requestTrackIds = optionalNumberArray(lane.requestTrackIds);
    const highlightTrackIds = optionalNumberArray(lane.highlightTrackIds);
    return {
      id: lane.id,
      name: lane.name,
      ...(lane.luaVariableName?.trim() ? { luaVariableName: lane.luaVariableName } : {}),
      ...(lane.vehicleMultiplier !== undefined ? { vehicleMultiplier: lane.vehicleMultiplier } : {}),
      ...(countType ? { countType } : {}),
      ...(requestTrackIds ? { requestTrackIds } : {}),
      ...(highlightTrackIds ? { highlightTrackIds } : {}),
      approach: normalizeApproach(lane.approach),
      signalSource: lane.signalSource === 'SIGNAL_GROUP' ? ('SIGNAL_GROUP' as const) : ('OWN' as const),
      ...(lane.signalGroupSignalId ? { signalGroupSignalId: lane.signalGroupSignalId } : {}),
      signal: {
        name: lane.signal?.name?.trim() ? lane.signal.name : `${lane.name || lane.id}Signal`,
        ...(lane.signal?.signalId?.trim() ? { signalId: lane.signal.signalId } : {}),
        modelName: lane.signal?.modelName || 'Unsichtbar_2er',
        modelConstant: lane.signal?.modelConstant || 'Unsichtbar_2er',
        lightStructures: (lane.signal?.lightStructures ?? []).slice(0, 4),
        axisStructures: lane.signal?.axisStructures ?? [],
      },
      signalGroupAssignments: (lane.signalGroupAssignments ?? [])
        .filter((assignment) => assignment.signalGroupId)
        .map((assignment) => ({
          signalGroupId: assignment.signalGroupId,
          mode:
            assignment.mode === 'ONLY'
              ? ('ONLY' as const)
              : assignment.mode === 'ALSO'
                ? ('ALSO' as const)
                : ('DEFAULT' as const),
          ...(assignment.routeNames && assignment.routeNames.length > 0
            ? { routeNames: assignment.routeNames.filter((routeName) => routeName.trim()) }
            : {}),
        })),
    };
  });
  const ampeln = (normalizedInput.ampeln ?? []).map((ampel) => ({
    ...ampel,
    kind:
      ampel.kind ??
      (ampel.lightStructures && ampel.lightStructures.length > 0 && !ampel.signalId?.trim()
        ? ('STRUCTURE_LIGHT' as const)
        : ('SIGNAL' as const)),
    ...(ampel.signalId?.trim() ? { signalId: ampel.signalId } : {}),
    lightStructures: (ampel.lightStructures ?? []).slice(0, 4),
    axisStructures: ampel.axisStructures ?? [],
  }));
  const signalGroups = (normalizedInput.signalGroups ?? []).map((group) => ({
    ...group,
    name: group.name,
    approach: normalizeApproach(group.approach),
    turnDirections: group.trafficType === 'PEDESTRIAN' ? [] : group.turnDirections,
    trafficType: group.trafficType ?? 'CAR',
    showRequests: group.showRequests ?? false,
    ampelIds: group.ampelIds ?? [],
  }));
  const inferredSupportMultipleLaneSignals = lanes.some((lane) => lane.signalGroupAssignments.length > 1);
  const inferredSupportPedestrianSignals =
    signalGroups.some((group) => group.trafficType === 'PEDESTRIAN') ||
    ampeln.some(
      (ampel) =>
        ampel.use === 'PEDESTRIAN_ONLY' || ampel.use === 'VEHICLE_AND_PEDESTRIAN' || ampel.trafficType === 'PEDESTRIAN',
    );
  const inferredSupportStructureLightSignals = ampeln.some((ampel) => ampel.kind === 'STRUCTURE_LIGHT');
  const greenTimeSeconds = optionalNumber(normalizedInput.greenTimeSeconds);
  const draft: IntersectionWizardDraftAppDto = {
    id: normalizedInput.id || `draft-${Date.now()}`,
    name: normalizedInput.name ?? '',
    luaVariableName: normalizedInput.luaVariableName ?? 'kreuzung',
    ...(greenTimeSeconds !== undefined ? { greenTimeSeconds } : {}),
    intersectionEepSaveId: normalizeStorageSlot(normalizedInput.intersectionEepSaveId),
    ...(normalizedInput.tippStructure !== undefined ? { tippStructure: normalizedInput.tippStructure } : {}),
    switchInStrictOrder: normalizedInput.switchInStrictOrder ?? false,
    showLuaCodeImmediately: normalizedInput.showLuaCodeImmediately ?? false,
    manualLuaVariableNames: normalizedInput.manualLuaVariableNames ?? false,
    individualLanePhaseSettings: normalizedInput.individualLanePhaseSettings ?? false,
    supportPedestrianSignals: (normalizedInput.supportPedestrianSignals ?? false) || inferredSupportPedestrianSignals,
    supportMultipleLaneSignals:
      (normalizedInput.supportMultipleLaneSignals ?? false) || inferredSupportMultipleLaneSignals,
    supportStructureLightSignals:
      (normalizedInput.supportStructureLightSignals ?? false) || inferredSupportStructureLightSignals,
    staticCams: normalizedInput.staticCams ?? [],
    createdAt: normalizedInput.createdAt ?? timestamp,
    updatedAt: timestamp,
    lanes,
    ampeln,
    signalGroups,
    phases:
      normalizedInput.phases?.map((phase) => {
        const phaseGreenTimeSeconds = optionalNumber(phase.greenTimeSeconds);
        return {
          ...phase,
          ...(phaseGreenTimeSeconds !== undefined ? { greenTimeSeconds: phaseGreenTimeSeconds } : {}),
        };
      }) ?? [],
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

    const signalItemName = signal.itemNameWithModelPath ?? signal.itemName;
    const model = modelFromSignalName(signalItemName, this.roadSelector.getTrafficLightModels());
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
      kind: 'SIGNAL',
      signalId,
      use: 'VEHICLE_ONLY',
      trafficType: 'CAR',
      modelName: 'JS2 3er-Ampel mit Fußgängern',
      modelConstant: 'JS2_3er_mit_FG',
    };
  }
}
