import { useCallback, useEffect, useMemo, useState } from 'react';
import Autocomplete from '@mui/material/Autocomplete';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import FormControl from '@mui/material/FormControl';
import IconButton from '@mui/material/IconButton';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TextField from '@mui/material/TextField';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import { alpha } from '@mui/material/styles';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import DirectionsBusIcon from '@mui/icons-material/DirectionsBus';
import DirectionsCarIcon from '@mui/icons-material/DirectionsCar';
import DirectionsWalkIcon from '@mui/icons-material/DirectionsWalk';
import EastIcon from '@mui/icons-material/East';
import NorthIcon from '@mui/icons-material/North';
import NorthEastIcon from '@mui/icons-material/NorthEast';
import NorthWestIcon from '@mui/icons-material/NorthWest';
import PedalBikeIcon from '@mui/icons-material/PedalBike';
import SouthIcon from '@mui/icons-material/South';
import SouthEastIcon from '@mui/icons-material/SouthEast';
import SouthWestIcon from '@mui/icons-material/SouthWest';
import StraightIcon from '@mui/icons-material/Straight';
import TramIcon from '@mui/icons-material/Tram';
import TurnLeftIcon from '@mui/icons-material/TurnLeft';
import TurnRightIcon from '@mui/icons-material/TurnRight';
import TurnSlightLeftIcon from '@mui/icons-material/TurnSlightLeft';
import TurnSlightRightIcon from '@mui/icons-material/TurnSlightRight';
import WestIcon from '@mui/icons-material/West';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import {
  CeTypes,
  CommandEvent,
  IntersectionListRoom,
  RoadTrafficLightModelsRoom,
  ScenarioRoom,
  TrackType,
  TrainListRoom,
} from '@ce/web-shared';
import type {
  DataSlotAppDto,
  IntersectionAppDto,
  IntersectionWizardAmpelAppDto,
  IntersectionWizardApproach,
  IntersectionWizardTurnDirection,
  IntersectionWizardDraftAppDto,
  IntersectionWizardGenerateResultAppDto,
  IntersectionWizardLaneAppDto,
  IntersectionWizardPhaseAppDto,
  IntersectionWizardPedestrianCrossingAppDto,
  IntersectionWizardRouteRuleAppDto,
  IntersectionWizardSignalGroupAppDto,
  IntersectionWizardSignalLookupAppDto,
  IntersectionWizardTrafficType,
  RouteAppDto,
  ScenarioAppDto,
  TrafficLightModelAppDto,
  TrainListAppDto,
} from '@ce/web-shared';
import { useSocket } from '../../../app/hooks/useSocket';
import { useSocketUrl } from '../../../app/hooks/useSocketUrl';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import { ExplainedCheckbox } from '../../../shared/components/checkbox';
import { FeedbackMessage } from '../../../shared/components/feedback';
import { IconHeadline } from '../../../shared/components/headlines';
import {
  Approach,
  ExpandableEditorTableRow,
  FormApproachSelect,
  FormSelect,
  FormTextfield,
  FormTurnToggle,
  NeutralTurnToggle,
} from '../../../shared/components/road';
import { WizardStepper } from '../../../shared/components/stepper';
import { useApiDataRoomHandler, useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import {
  IntersectionWizardCodePreview,
  IntersectionWizardNavigation,
  IntersectionWizardPhasePlanStep,
  IntersectionWizardSettingsStep,
  IntersectionWizardStartStep,
  IntersectionWizardSummaryStep,
} from './intersection-wizard';

const steps = ['Vorbereitung', 'Kreuzung', 'Fahrspuren', 'Signalgruppen & Ampeln', 'Verkehrsphasen', 'Zusammenfassung'];
const stepKeys = ['start', 'kreuzung', 'fahrspuren', 'signalgruppen', 'verkehrsphasen', 'zusammenfassung'] as const;
const wizardSteps = steps.slice(1);
const turnDirections: IntersectionWizardTurnDirection[] = ['LEFT', 'HALF_LEFT', 'STRAIGHT', 'HALF_RIGHT', 'RIGHT'];
const approaches: IntersectionWizardApproach[] = [
  'NORTH',
  'NORTH_EAST',
  'EAST',
  'SOUTH_EAST',
  'SOUTH',
  'SOUTH_WEST',
  'WEST',
  'NORTH_WEST',
];
const signalGroupTrafficTypes: IntersectionWizardTrafficType[] = ['CAR', 'BUS', 'TRAM', 'BICYCLE', 'PEDESTRIAN'];
const turnDirectionLabels: Record<IntersectionWizardTurnDirection, string> = {
  LEFT: 'Links',
  HALF_LEFT: 'Halblinks',
  STRAIGHT: 'Geradeaus',
  HALF_RIGHT: 'Halbrechts',
  RIGHT: 'Rechts',
};
const turnDirectionIcons = {
  LEFT: TurnLeftIcon,
  HALF_LEFT: TurnSlightLeftIcon,
  STRAIGHT: StraightIcon,
  HALF_RIGHT: TurnSlightRightIcon,
  RIGHT: TurnRightIcon,
} satisfies Record<IntersectionWizardTurnDirection, typeof TurnLeftIcon>;
const approachLabels = {
  NORTH: 'Norden',
  NORTH_EAST: 'Nordost',
  EAST: 'Osten',
  SOUTH_EAST: 'Südost',
  SOUTH: 'Süden',
  SOUTH_WEST: 'Südwest',
  WEST: 'Westen',
  NORTH_WEST: 'Nordwest',
} satisfies Record<IntersectionWizardApproach, string>;
const approachIcons = {
  NORTH: SouthIcon,
  NORTH_EAST: SouthWestIcon,
  EAST: WestIcon,
  SOUTH_EAST: NorthWestIcon,
  SOUTH: NorthIcon,
  SOUTH_WEST: NorthEastIcon,
  WEST: EastIcon,
  NORTH_WEST: SouthEastIcon,
} satisfies Record<IntersectionWizardApproach, typeof NorthIcon>;
const approachBackgrounds = {
  NORTH: '#eef6ff',
  NORTH_EAST: '#edf8f3',
  EAST: '#fff7e8',
  SOUTH_EAST: '#f7f0ff',
  SOUTH: '#fff0f0',
  SOUTH_WEST: '#f0f4ff',
  WEST: '#f4f6f0',
  NORTH_WEST: '#f0f7f8',
} satisfies Record<IntersectionWizardApproach, string>;
const cardTitleIconSx = {
  width: 32,
  height: 32,
  display: 'inline-flex',
  alignItems: 'center',
  justifyContent: 'center',
  flex: '0 0 32px',
  color: 'text.primary',
};
const editorSectionGridSx = {
  display: 'grid',
  gridTemplateColumns: { xs: '1fr', md: 'repeat(3, minmax(0, 1fr))' },
  gap: 1.5,
  alignItems: 'start',
};
const compactTableColumnSx = {
  width: '1px',
  whiteSpace: 'nowrap',
};
const trafficTypeIcons = {
  CAR: DirectionsCarIcon,
  BUS: DirectionsBusIcon,
  TRAM: TramIcon,
  BICYCLE: PedalBikeIcon,
  PEDESTRIAN: DirectionsWalkIcon,
} satisfies Record<IntersectionWizardTrafficType, typeof DirectionsCarIcon>;
const trafficTypeLabels = {
  CAR: 'Auto',
  BUS: 'Bus',
  TRAM: 'Tram',
  BICYCLE: 'Fahrrad',
  PEDESTRIAN: 'Fußgänger',
} satisfies Record<IntersectionWizardTrafficType, string>;
const signalGroupApproachPrefix = {
  NORTH: 'n',
  NORTH_EAST: 'ne',
  EAST: 'e',
  SOUTH_EAST: 'se',
  SOUTH: 's',
  SOUTH_WEST: 'sw',
  WEST: 'w',
  NORTH_WEST: 'nw',
} satisfies Record<IntersectionWizardApproach, string>;
const approachNameSuffix = {
  NORTH: 'North',
  NORTH_EAST: 'NorthEast',
  EAST: 'East',
  SOUTH_EAST: 'SouthEast',
  SOUTH: 'South',
  SOUTH_WEST: 'SouthWest',
  WEST: 'West',
  NORTH_WEST: 'NorthWest',
} satisfies Record<IntersectionWizardApproach, string>;
const signalGroupTurnSuffix = {
  LEFT: 'Left',
  HALF_LEFT: 'HalfLeft',
  STRAIGHT: 'Straight',
  HALF_RIGHT: 'HalfRight',
  RIGHT: 'Right',
} satisfies Record<IntersectionWizardTurnDirection, string>;

type TrafficLightModelOption = {
  label: string;
  model: TrafficLightModelAppDto;
};

const alwaysRouteOption = '__ALWAYS__';
const alwaysRouteLabel = 'routen-unabhängig schalten';

function createDraft(): IntersectionWizardDraftAppDto {
  const now = new Date().toISOString();
  return {
    id: `draft-${Date.now()}`,
    name: '',
    luaVariableName: 'kreuzung',
    intersectionEepSaveId: -1,
    switchInStrictOrder: false,
    showLuaCodeImmediately: true,
    manualLuaVariableNames: false,
    individualLanePhaseSettings: false,
    supportPedestrianSignals: false,
    supportMultipleLaneSignals: false,
    staticCams: [],
    createdAt: now,
    updatedAt: now,
    lanes: [],
    pedestrianCrossings: [],
    ampeln: [],
    signalGroups: [],
    routeRules: [],
    defaultRequestDisplays: [],
    phases: [],
    generatedLua: '',
  };
}

function slug(value: string, fallback: string) {
  const normalized = value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^A-Za-z0-9_]+/g, '_')
    .replace(/^_+|_+$/g, '');
  const result = normalized || fallback;
  return result.charAt(0).toLowerCase() + result.slice(1);
}

function sanitizeLuaIdentifier(value: string, fallback: string) {
  const ascii = value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^A-Za-z0-9_]+/g, '_')
    .replace(/^_+|_+$/g, '');
  const withFallback = ascii || fallback;
  return /^[A-Za-z_]/.test(withFallback) ? withFallback : `${fallback}_${withFallback}`;
}

function lowerFirst(value: string) {
  return value.charAt(0).toLowerCase() + value.slice(1);
}

function uniqueLuaIdentifier(preferred: string, fallback: string, used: Set<string>) {
  const base = sanitizeLuaIdentifier(preferred, fallback);
  let candidate = base;
  let suffix = 2;
  while (used.has(candidate)) {
    candidate = `${base}_${suffix}`;
    suffix += 1;
  }
  used.add(candidate);
  return candidate;
}

function laneLuaVariableName(
  lane: IntersectionWizardLaneAppDto,
  index: number,
  intersectionPrefix: string,
  used: Set<string>,
) {
  if (lane.luaVariableName?.trim()) {
    return uniqueLuaIdentifier(lane.luaVariableName, `lane${index + 1}`, used);
  }
  const numberedLane = /^(?:lane|spur|fahrstreifen|fs)\s*(\d+[a-z]?)$/i.exec(lane.name.trim());
  if (numberedLane) {
    const prefix = lowerFirst(sanitizeLuaIdentifier(intersectionPrefix, 'kreuzung'));
    return uniqueLuaIdentifier(`${prefix}Lane${numberedLane[1]}`, `${prefix}Lane${index + 1}`, used);
  }
  return uniqueLuaIdentifier(
    lowerFirst(sanitizeLuaIdentifier(lane.name, `lane${index + 1}`)),
    `lane${index + 1}`,
    used,
  );
}

function laneLuaVariableNames(lanes: IntersectionWizardLaneAppDto[], intersectionPrefix: string) {
  const used = new Set<string>();
  return new Map(lanes.map((lane, index) => [lane.id, laneLuaVariableName(lane, index, intersectionPrefix, used)]));
}

function route(path: string, socketUrl: string) {
  return new URL(`/api/v1/road/intersection-wizard${path}`, socketUrl);
}

function stepIndexFromKey(stepKey: string | undefined): number {
  if (stepKey === 'ampeln') return stepKeys.findIndex((candidate) => candidate === 'signalgruppen');
  const index = stepKeys.findIndex((candidate) => candidate === stepKey);
  return index >= 0 ? index : 0;
}

function splitRouteNames(value: string): string[] {
  return value
    .split(/[;,]/)
    .map((routeName) => routeName.trim())
    .filter(Boolean);
}

function normalizedApproach(approach: IntersectionWizardApproach | undefined): IntersectionWizardApproach {
  return approach ?? 'SOUTH';
}

function signalGroupNameForLane(lane: IntersectionWizardLaneAppDto): string {
  return `${signalGroupApproachPrefix[normalizedApproach(lane.approach ?? lane.heading)]}${lane.turnDirections
    .map((direction) => signalGroupTurnSuffix[direction])
    .join('')}`;
}

function uniqueSignalGroupName(preferredName: string, usedNames: Set<string>): string {
  let candidate = preferredName;
  let suffix = 2;
  while (usedNames.has(candidate)) {
    candidate = `${preferredName}${suffix}`;
    suffix += 1;
  }
  usedNames.add(candidate);
  return candidate;
}

function nextSignalGroupId(signalGroups: IntersectionWizardSignalGroupAppDto[]): string {
  const usedIds = new Set(signalGroups.map((group) => group.id));
  let index = signalGroups.length + 1;
  while (usedIds.has(`sg-${index}`)) {
    index += 1;
  }
  return `sg-${index}`;
}

function suggestGroups(lanes: IntersectionWizardLaneAppDto[]): IntersectionWizardSignalGroupAppDto[] {
  const groups = new Map<string, IntersectionWizardSignalGroupAppDto>();
  const usedNames = new Set<string>();
  lanes.forEach((lane) => {
    const key = `${normalizedApproach(lane.approach ?? lane.heading)}:${lane.turnDirections.join('|')}`;
    const existing = groups.get(key);
    if (existing) {
      existing.laneIds.push(lane.id);
      return;
    }
    groups.set(key, {
      id: `sg-${groups.size + 1}`,
      name: uniqueSignalGroupName(signalGroupNameForLane(lane), usedNames),
      laneIds: [lane.id],
      turnDirections: lane.turnDirections,
      trafficType: 'CAR',
      ampelIds: [],
    });
  });
  return Array.from(groups.values());
}

function signalGroupsForEachLane(lanes: IntersectionWizardLaneAppDto[]): IntersectionWizardSignalGroupAppDto[] {
  const usedNames = new Set<string>();
  return lanes.map((lane, index) => ({
    id: `sg-${index + 1}`,
    name: uniqueSignalGroupName(signalGroupNameForLane(lane), usedNames),
    laneIds: [lane.id],
    turnDirections: lane.turnDirections,
    trafficType: 'CAR',
    ampelIds: [laneAmpelId(lane)],
  }));
}

function ampelForLane(
  lane: IntersectionWizardLaneAppDto,
  index: number,
  trafficType: IntersectionWizardTrafficType = 'CAR',
): IntersectionWizardAmpelAppDto {
  return {
    id: `ampel-${lane.signalId || lane.id}`,
    name: `K${index}`,
    signalId: lane.signalId,
    use: 'VEHICLE_ONLY',
    trafficType,
    modelName: trafficType === 'TRAM' ? 'MA1_STRAB_3er_2_gruen' : 'Ampel_3er_XXX_mit_FG',
    modelConstant: trafficType === 'TRAM' ? 'MA1_STRAB_3er_2_gruen' : 'JS2_3er_mit_FG',
  };
}

function laneOptionLabel(lane: IntersectionWizardLaneAppDto): string {
  return `${lane.name} (Signal ${lane.signalId.trim() || '-'})`;
}

function laneAmpelId(lane: IntersectionWizardLaneAppDto) {
  return `lane-ampel-${lane.id}`;
}

function autoLaneName(prefix: string, laneNr: number) {
  return `${slug(prefix, 'kreuzung')}Fs${laneNr}`;
}

function renameAutoLaneNames(
  lanes: IntersectionWizardLaneAppDto[],
  previousPrefix: string,
  nextPrefix: string,
): IntersectionWizardLaneAppDto[] {
  return lanes.map((lane, index) => {
    const laneNr = index + 1;
    const previousName = autoLaneName(previousPrefix, laneNr);
    const legacyName = `FS${laneNr}`;
    if (lane.name !== previousName && lane.name !== legacyName) return lane;
    return { ...lane, name: autoLaneName(nextPrefix, laneNr) };
  });
}

function toggleDirectionSelection(
  selectedDirections: IntersectionWizardTurnDirection[],
  direction: IntersectionWizardTurnDirection,
) {
  if (selectedDirections.includes(direction)) {
    return selectedDirections.filter((selectedDirection) => selectedDirection !== direction);
  }
  return [...selectedDirections, direction];
}

function hasAdvancedIntersectionSettings(draft: IntersectionWizardDraftAppDto) {
  return Boolean(
    draft.greenTimeSeconds !== undefined ||
    (draft.switchInStrictOrder ?? false) ||
    (draft.showLuaCodeImmediately ?? false) ||
    (draft.manualLuaVariableNames ?? false) ||
    (draft.individualLanePhaseSettings ?? false) ||
    (draft.supportPedestrianSignals ?? false) ||
    (draft.supportMultipleLaneSignals ?? false),
  );
}

function defaultPhases(): IntersectionWizardPhaseAppDto[] {
  return [
    { id: 'phase-1', name: 'P1', signalGroupIds: [] },
    { id: 'phase-2', name: 'P2', signalGroupIds: [] },
  ];
}

function optionalPositiveNumber(value: string): number | undefined {
  if (!value.trim()) return undefined;
  const numeric = Number(value);
  return Number.isFinite(numeric) && numeric > 0 ? numeric : undefined;
}

function readonlyTitle(title: string, readonly: boolean) {
  return readonly ? `${title} (nur lesbar)` : title;
}

function firstFreeCxName(existingNames: string[]) {
  const usedNumbers = new Set(
    existingNames
      .map((name) => /^c(\d+)$/i.exec(name.trim())?.[1])
      .filter((value): value is string => Boolean(value))
      .map(Number),
  );
  let nextNumber = 1;
  while (usedNumbers.has(nextNumber)) {
    nextNumber += 1;
  }
  return `c${nextNumber}`;
}

function intersectionLuaBlock(lua: string): string {
  const match = /^-- START Kreuzung[^\n]*(?:\n[\s\S]*?)\n-- END Kreuzung[^\n]*/m.exec(lua);
  return match?.[0] ?? lua;
}

function IntersectionCreateWizard() {
  const socket = useSocket();
  const socketUrl = useSocketUrl();
  const navigate = useNavigate();
  const location = useLocation();
  const { wizardStep } = useParams<{ wizardStep?: string }>();
  const [searchParams] = useSearchParams();
  const activeStep = stepIndexFromKey(wizardStep);
  const [draft, setDraft] = useState<IntersectionWizardDraftAppDto>(() => createDraft());
  const [generatedLua, setGeneratedLua] = useState('');
  const [warnings, setWarnings] = useState<string[]>([]);
  const [loadedDraftId, setLoadedDraftId] = useState('');
  const [loadedIntersectionId, setLoadedIntersectionId] = useState('');
  const [status, setStatus] = useState('');
  const [ceTypeRoutes, setCeTypeRoutes] = useState<string[]>([]);
  const [freeSlots, setFreeSlots] = useState<DataSlotAppDto[]>([]);
  const [scenarioStaticCameras, setScenarioStaticCameras] = useState<string[]>([]);
  const [scenarioIntersectionNames, setScenarioIntersectionNames] = useState<string[]>([]);
  const [roadTrainRoutes, setRoadTrainRoutes] = useState<string[]>([]);
  const [tramTrainRoutes, setTramTrainRoutes] = useState<string[]>([]);
  const [trafficLightModels, setTrafficLightModels] = useState<Record<string, TrafficLightModelAppDto>>({});
  const [showAdvancedIntersectionSettings, setShowAdvancedIntersectionSettings] = useState(false);
  const [sendPreparationSettings, setSendPreparationSettings] = useState(true);
  const [expandedLaneId, setExpandedLaneId] = useState<string | null>(null);
  const [expandedPedestrianCrossingId, setExpandedPedestrianCrossingId] = useState<string | null>(null);
  const draftIdFromUrl = searchParams.get('draftId') ?? '';
  const intersectionIdFromUrl = searchParams.get('intersectionId') ?? '';
  const roadPathPrefix = location.pathname.startsWith('/simple/road')
    ? '/simple/road'
    : location.pathname.startsWith('/old/road')
      ? '/old/road'
      : '/road';

  function sendRoadModulePreparationSettings() {
    socket.emit(CommandEvent.ChangeSetting, {
      name: 'Signal-ID',
      func: 'IntersectionSettings.setShowSignalIdOnSignal',
      newValue: true,
    });
    socket.emit(CommandEvent.ChangeSetting, {
      name: 'Modellinformation',
      func: 'IntersectionSettings.setShowModelInfoOnSignal',
      newValue: true,
    });
  }

  const wizardUrl = useCallback(
    (stepIndex: number, options: { draftId?: string; removeIntersectionId?: boolean } = {}) => {
      const params = new URLSearchParams(searchParams);
      const draftId = options.draftId ?? draft.id;
      if (draftId) params.set('draftId', draftId);
      if (options.removeIntersectionId) params.delete('intersectionId');
      const query = params.toString();
      return `${roadPathPrefix}/createIntersection/${stepKeys[stepIndex]}${query ? `?${query}` : ''}`;
    },
    [draft.id, roadPathPrefix, searchParams],
  );

  const navigateToStep = useCallback(
    (stepIndex: number, options: { draftId?: string; removeIntersectionId?: boolean; replace?: boolean } = {}) => {
      navigate(wizardUrl(stepIndex, options), { replace: options.replace ?? false });
    },
    [navigate, wizardUrl],
  );

  useApiDataRoomHandler(CeTypes.HubRoute, (payload: string) => {
    const data = JSON.parse(payload) as Record<string, Partial<RouteAppDto>>;
    setCeTypeRoutes(
      Object.values(data)
        .map((routeEntry) => routeEntry.name)
        .filter((routeName): routeName is string => Boolean(routeName?.trim())),
    );
  });

  useApiDataRoomHandler(CeTypes.HubFreeSlot, (payload: string) => {
    const data = JSON.parse(payload) as Record<string, DataSlotAppDto>;
    setFreeSlots(Object.values(data).sort((a, b) => Number(a.id) - Number(b.id)));
  });

  useDomainRoomHandler(IntersectionListRoom, 'All', (payload: string) => {
    const data = JSON.parse(payload) as Record<string, Partial<IntersectionAppDto>>;
    setScenarioIntersectionNames(
      Object.values(data).flatMap((intersection) => [
        ...(intersection.scriptVariableName ? [intersection.scriptVariableName] : []),
        ...(intersection.name ? [intersection.name] : []),
      ]),
    );
  });

  useDomainRoomHandler(ScenarioRoom, 'current', (payload: string) => {
    const data = JSON.parse(payload) as Record<string, Partial<ScenarioAppDto>>;
    setScenarioStaticCameras(
      Array.from(
        new Set(
          Object.values(data)
            .flatMap((scenario) => scenario.staticCameras ?? [])
            .filter((cameraName): cameraName is string => Boolean(cameraName?.trim())),
        ),
      ).sort((a, b) => a.localeCompare(b, undefined, { numeric: true })),
    );
  });

  useDomainRoomHandler(TrainListRoom, TrackType.Road, (payload: string) => {
    const data = JSON.parse(payload) as Record<string, TrainListAppDto>;
    setRoadTrainRoutes(
      Object.values(data)
        .map((train) => train.route)
        .filter((routeName): routeName is string => Boolean(routeName?.trim())),
    );
  });

  useDomainRoomHandler(TrainListRoom, TrackType.Tram, (payload: string) => {
    const data = JSON.parse(payload) as Record<string, TrainListAppDto>;
    setTramTrainRoutes(
      Object.values(data)
        .map((train) => train.route)
        .filter((routeName): routeName is string => Boolean(routeName?.trim())),
    );
  });

  useDomainRoomHandler(RoadTrafficLightModelsRoom, 'All', (payload: string) => {
    setTrafficLightModels(JSON.parse(payload) as Record<string, TrafficLightModelAppDto>);
  });

  useEffect(() => {
    const timer = window.setTimeout(async () => {
      try {
        const response = await fetch(route('/generate', socketUrl), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(draft),
        });
        if (!response.ok) return;
        const result = (await response.json()) as IntersectionWizardGenerateResultAppDto;
        setGeneratedLua(result.lua);
        setWarnings(result.warnings);
      } catch (_error) {
        setWarnings(['Der Lua-Code konnte gerade nicht vom Server erzeugt werden.']);
      }
    }, 250);
    return () => window.clearTimeout(timer);
  }, [draft, socketUrl]);

  const updateDraft = useCallback((patch: Partial<IntersectionWizardDraftAppDto>) => {
    setDraft((current) => ({ ...current, ...patch, updatedAt: new Date().toISOString() }));
  }, []);

  useEffect(() => {
    if (activeStep !== 4 || draft.phases.length > 0) return;
    updateDraft({ phases: defaultPhases() });
  }, [activeStep, draft.phases.length, updateDraft]);

  const lookupSignal = useCallback(
    async (signalId: string): Promise<IntersectionWizardSignalLookupAppDto | undefined> => {
      if (!signalId.trim()) return undefined;
      const response = await fetch(route(`/signals/${encodeURIComponent(signalId.trim())}`, socketUrl));
      if (!response.ok) return undefined;
      return (await response.json()) as IntersectionWizardSignalLookupAppDto;
    },
    [socketUrl],
  );

  const ensureAmpelnForLanes = useCallback(async () => {
    const nextAmpeln = [...draft.ampeln];
    for (const lane of draft.lanes) {
      if (nextAmpeln.some((ampel) => ampel.signalId === lane.signalId)) continue;
      const trafficType =
        draft.signalGroups.find((group) => group.trafficType !== 'PEDESTRIAN' && group.laneIds.includes(lane.id))
          ?.trafficType ?? 'CAR';
      const ampel = ampelForLane(lane, nextAmpeln.length + 1, trafficType);
      const lookup = await lookupSignal(lane.signalId);
      if (lookup?.suggestedTrafficLightModel) ampel.modelName = lookup.suggestedTrafficLightModel;
      if (lookup?.suggestedTrafficLightModelConstant) ampel.modelConstant = lookup.suggestedTrafficLightModelConstant;
      nextAmpeln.push(ampel);
    }
    const nextGroups = draft.signalGroups.map((group) => ({
      ...group,
      ampelIds:
        group.ampelIds.length > 0
          ? group.ampelIds
          : group.laneIds
              .map((laneId) => draft.lanes.find((lane) => lane.id === laneId))
              .map((lane) => nextAmpeln.find((ampel) => ampel.signalId === lane?.signalId)?.id)
              .filter((value): value is string => Boolean(value)),
    }));
    updateDraft({ ampeln: nextAmpeln, signalGroups: nextGroups });
  }, [draft.ampeln, draft.lanes, draft.signalGroups, lookupSignal, updateDraft]);

  const persistDraft = useCallback(
    async (draftToPersist: IntersectionWizardDraftAppDto) => {
      const response = await fetch(route('/drafts', socketUrl), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...draftToPersist, generatedLua }),
      });
      if (!response.ok) return undefined;
      return (await response.json()) as IntersectionWizardDraftAppDto;
    },
    [generatedLua, socketUrl],
  );

  const loadCurrentIntersection = useCallback(
    async (intersectionId: string, attempt = 0) => {
      if (!intersectionId) return;
      try {
        const response = await fetch(route(`/current/${encodeURIComponent(intersectionId)}`, socketUrl));
        if (response.ok) {
          const loaded = (await response.json()) as IntersectionWizardDraftAppDto;
          setDraft(loaded);
          setShowAdvancedIntersectionSettings(hasAdvancedIntersectionSettings(loaded));
          setLoadedIntersectionId(intersectionId);
          navigateToStep(1, { draftId: loaded.id, removeIntersectionId: true, replace: true });
          return;
        }
      } catch (_error) {
        // Retry below; this request can race the test server startup or a transient reconnect.
      }
      if (attempt < 10) {
        window.setTimeout(() => void loadCurrentIntersection(intersectionId, attempt + 1), 150);
        return;
      }
      setStatus('Kreuzung konnte nicht geladen werden.');
    },
    [navigateToStep, socketUrl],
  );

  useEffect(() => {
    if (wizardStep === 'ampeln') {
      navigateToStep(stepIndexFromKey('signalgruppen'), { replace: true });
      return;
    }
    if (wizardStep && stepKeys.some((candidate) => candidate === wizardStep)) return;
    if (intersectionIdFromUrl && !draftIdFromUrl) return;
    navigateToStep(activeStep, { replace: true });
  }, [activeStep, draftIdFromUrl, intersectionIdFromUrl, navigateToStep, wizardStep]);

  useEffect(() => {
    if (!draftIdFromUrl || loadedDraftId === draftIdFromUrl) return;
    if (draft.id === draftIdFromUrl) {
      setLoadedDraftId(draftIdFromUrl);
      return;
    }
    let cancelled = false;
    fetch(route(`/drafts/${encodeURIComponent(draftIdFromUrl)}`, socketUrl))
      .then(async (response) => {
        if (!response.ok || cancelled) return;
        const loaded = (await response.json()) as IntersectionWizardDraftAppDto;
        setDraft(loaded);
        setShowAdvancedIntersectionSettings(hasAdvancedIntersectionSettings(loaded));
        setLoadedDraftId(loaded.id);
      })
      .catch(() => {
        if (!cancelled) setStatus('Entwurf konnte nicht geladen werden.');
      });
    return () => {
      cancelled = true;
    };
  }, [draft.id, draftIdFromUrl, loadedDraftId, socketUrl]);

  useEffect(() => {
    if (draftIdFromUrl || !intersectionIdFromUrl || loadedIntersectionId === intersectionIdFromUrl) return;
    void loadCurrentIntersection(intersectionIdFromUrl);
  }, [draftIdFromUrl, intersectionIdFromUrl, loadCurrentIntersection, loadedIntersectionId]);

  useEffect(() => {
    if (draftIdFromUrl && loadedDraftId !== draftIdFromUrl && draft.id !== draftIdFromUrl) return;
    if (intersectionIdFromUrl) return;
    const timer = window.setTimeout(async () => {
      try {
        const saved = await persistDraft(draft);
        if (!saved) return;
        setLoadedDraftId(saved.id);
        if (draftIdFromUrl !== saved.id) {
          navigateToStep(activeStep, { draftId: saved.id, removeIntersectionId: true, replace: true });
        }
      } catch (_error) {
        // The explicit save button still reports errors through the existing status area.
      }
    }, 600);
    return () => window.clearTimeout(timer);
  }, [activeStep, draft, draftIdFromUrl, intersectionIdFromUrl, loadedDraftId, navigateToStep, persistDraft]);

  const copyAllLua = useCallback(() => {
    if (!generatedLua || activeStep !== steps.length - 1) return;
    void navigator.clipboard.writeText(generatedLua);
    setStatus('Vollständiger Lua-Code kopiert.');
  }, [activeStep, generatedLua]);

  const copyIntersectionLua = useCallback(() => {
    if (!generatedLua || activeStep !== steps.length - 1) return;
    void navigator.clipboard.writeText(intersectionLuaBlock(generatedLua));
    setStatus('Kreuzungscode kopiert.');
  }, [activeStep, generatedLua]);

  const selectedLaneNames = useMemo(
    () => new Map(draft.lanes.map((lane) => [lane.id, laneOptionLabel(lane)])),
    [draft.lanes],
  );
  const routeOptions = useMemo(
    () =>
      Array.from(new Set([...ceTypeRoutes, ...roadTrainRoutes, ...tramTrainRoutes]))
        .filter(Boolean)
        .sort((a, b) => a.localeCompare(b, undefined, { numeric: true })),
    [ceTypeRoutes, roadTrainRoutes, tramTrainRoutes],
  );
  const cameraOptions = useMemo(
    () =>
      Array.from(new Set([...(draft.staticCams ?? []), ...scenarioStaticCameras]))
        .filter((cameraName) => cameraName.trim())
        .sort((a, b) => a.localeCompare(b, undefined, { numeric: true })),
    [draft.staticCams, scenarioStaticCameras],
  );
  const storageSlotOptions = useMemo(() => {
    const selectedSlot = draft.intersectionEepSaveId ?? -1;
    const options = freeSlots.slice(0, 20);
    if (selectedSlot === -1 || options.some((slot) => Number(slot.id) === selectedSlot)) return options;
    return [{ id: String(selectedSlot), name: 'Aktuell', data: '' }, ...options];
  }, [draft.intersectionEepSaveId, freeSlots]);
  const trafficLightModelOptions = useMemo<TrafficLightModelOption[]>(
    () =>
      Object.values(trafficLightModels)
        .map((model) => ({
          model,
          label: model.luaConstant ? `${model.luaConstant} (${model.name})` : model.name,
        }))
        .sort((a, b) => a.label.localeCompare(b.label, undefined, { numeric: true })),
    [trafficLightModels],
  );

  function selectedTrafficLightModelLabel(ampel: IntersectionWizardAmpelAppDto): string {
    return (
      trafficLightModelOptions.find(
        (option) => option.model.luaConstant === ampel.modelConstant || option.model.name === ampel.modelName,
      )?.label ?? ampel.modelConstant
    );
  }

  function trafficLightModelForAmpel(ampel: IntersectionWizardAmpelAppDto): TrafficLightModelAppDto | undefined {
    return Object.values(trafficLightModels).find(
      (model) =>
        model.luaConstant === ampel.modelConstant ||
        model.luaConstant === ampel.modelName ||
        model.name === ampel.modelName ||
        model.name === ampel.modelConstant ||
        model.id === ampel.modelName ||
        model.id === ampel.modelConstant,
    );
  }

  function supportsPedestrianSignal(ampel: IntersectionWizardAmpelAppDto): boolean {
    const model = trafficLightModelForAmpel(ampel);
    if (model) {
      return model.positionPedestrians !== undefined && model.positionPedestrians !== model.positionRed;
    }
    return /(?:mit|nur)_FG/i.test(ampel.modelConstant) || /(?:mit|nur)_FG/i.test(ampel.modelName);
  }

  function compactTrafficLightModelLabel(model: TrafficLightModelAppDto): string {
    return model.luaConstant ?? model.name;
  }

  function selectedLaneAmpel(lane: IntersectionWizardLaneAppDto) {
    const signalId = lane.signalId.trim();
    return (
      draft.ampeln.find((ampel) => signalId && ampel.signalId.trim() === signalId) ??
      draft.ampeln.find((ampel) => ampel.id === laneAmpelId(lane))
    );
  }

  function updateAmpel(id: string, patch: Partial<IntersectionWizardAmpelAppDto>) {
    updateDraft({ ampeln: draft.ampeln.map((ampel) => (ampel.id === id ? { ...ampel, ...patch } : ampel)) });
  }

  function updateLaneAndAmpel(
    lane: IntersectionWizardLaneAppDto,
    lanePatch: Partial<IntersectionWizardLaneAppDto>,
    ampelPatch: Partial<IntersectionWizardAmpelAppDto> = {},
  ) {
    const nextLane = { ...lane, ...lanePatch };
    const existingAmpel = selectedLaneAmpel(lane);
    const nextAmpel = {
      ...(existingAmpel ?? {
        ...ampelForLane(nextLane, draft.ampeln.length + 1),
        id: laneAmpelId(nextLane),
      }),
      signalId: nextLane.signalId,
      ...ampelPatch,
    };
    updateDraft({
      lanes: draft.lanes.map((entry) => (entry.id === lane.id ? nextLane : entry)),
      ampeln: existingAmpel
        ? draft.ampeln.map((ampel) => (ampel.id === existingAmpel.id ? nextAmpel : ampel))
        : [...draft.ampeln, nextAmpel],
    });
  }

  async function enrichLaneAmpelFromSignal(lane: IntersectionWizardLaneAppDto) {
    const lookup = await lookupSignal(lane.signalId);
    if (!lookup?.suggestedTrafficLightModel && !lookup?.suggestedTrafficLightModelConstant) return;
    updateLaneAndAmpel(
      lane,
      {},
      {
        ...(lookup.suggestedTrafficLightModel ? { modelName: lookup.suggestedTrafficLightModel } : {}),
        ...(lookup.suggestedTrafficLightModelConstant
          ? { modelConstant: lookup.suggestedTrafficLightModelConstant }
          : {}),
      },
    );
  }

  function removeLane(lane: IntersectionWizardLaneAppDto) {
    const ampel = selectedLaneAmpel(lane);
    updateDraft({
      lanes: draft.lanes.filter((entry) => entry.id !== lane.id),
      ampeln: ampel ? draft.ampeln.filter((entry) => entry.id !== ampel.id) : draft.ampeln,
      signalGroups: draft.signalGroups.map((group) => ({
        ...group,
        laneIds: group.laneIds.filter((laneId) => laneId !== lane.id),
        ampelIds: ampel ? group.ampelIds.filter((ampelId) => ampelId !== ampel.id) : group.ampelIds,
      })),
      routeRules: (draft.routeRules ?? []).filter((rule) => rule.laneId !== lane.id),
      defaultRequestDisplays: (draft.defaultRequestDisplays ?? []).filter((entry) => entry.laneId !== lane.id),
    });
    setExpandedLaneId((current) => (current === lane.id ? null : current));
  }

  function addLane() {
    const laneNr = draft.lanes.length + 1;
    const lane: IntersectionWizardLaneAppDto = {
      id: `lane-${laneNr}`,
      name: autoLaneName(draft.luaVariableName, laneNr),
      signalId: '',
      approach: 'SOUTH',
      turnDirections: ['STRAIGHT'],
    };
    updateDraft({
      lanes: [...draft.lanes, lane],
    });
    setExpandedLaneId(lane.id);
  }

  function nextAmpelName() {
    return `K${draft.ampeln.length + 1}`;
  }

  function nextPedestrianSignalName() {
    const usedNumbers = draft.ampeln
      .flatMap((ampel) => [ampel.name, ampel.pedestrianName ?? ''])
      .map((name) => /^F(\d+)$/i.exec(name.trim())?.[1])
      .filter((value): value is string => Boolean(value))
      .map(Number);
    const nextNumber = usedNumbers.length > 0 ? Math.max(...usedNumbers) + 1 : 1;
    return `F${nextNumber}`;
  }

  function pedestrianCrossingName(approach: IntersectionWizardApproach, index: number) {
    return `pedCrossing${approachNameSuffix[approach]}${index}`;
  }

  function pedestrianSignalGroupName(approach: IntersectionWizardApproach, index: number) {
    return `sgPedCrossing${approachNameSuffix[approach]}${index}`;
  }

  function createPanelAmpel(): IntersectionWizardAmpelAppDto {
    return {
      id: `ampel-${Date.now()}`,
      name: nextAmpelName(),
      signalId: '',
      use: 'VEHICLE_ONLY',
      trafficType: 'CAR',
      modelName: 'Ampel_3er_XXX_mit_FG',
      modelConstant: 'JS2_3er_mit_FG',
    };
  }

  function createPedestrianAmpel(name = nextPedestrianSignalName()): IntersectionWizardAmpelAppDto {
    return {
      id: `ampel-${Date.now()}-${name}`,
      name,
      signalId: '',
      use: 'PEDESTRIAN_ONLY',
      trafficType: 'PEDESTRIAN',
      modelName: 'JS2_2er_nur_FG',
      modelConstant: 'JS2_2er_nur_FG',
    };
  }

  function addPedestrianCrossing() {
    const approach: IntersectionWizardApproach = 'SOUTH';
    const index = (draft.pedestrianCrossings ?? []).length + 1;
    const usedGroupNames = new Set(draft.signalGroups.map((group) => group.name));
    const signal1 = createPedestrianAmpel();
    const signal2 = createPedestrianAmpel(`F${Number(signal1.name.replace(/^F/i, '')) + 1 || draft.ampeln.length + 2}`);
    const signalGroupId = nextSignalGroupId(draft.signalGroups);
    const crossing: IntersectionWizardPedestrianCrossingAppDto = {
      id: `ped-crossing-${Date.now()}`,
      name: pedestrianCrossingName(approach, index),
      approach,
      signalGroupId,
    };
    updateDraft({
      supportPedestrianSignals: true,
      pedestrianCrossings: [...(draft.pedestrianCrossings ?? []), crossing],
      ampeln: [...draft.ampeln, signal1, signal2],
      signalGroups: [
        ...draft.signalGroups,
        {
          id: signalGroupId,
          name: uniqueSignalGroupName(pedestrianSignalGroupName(approach, index), usedGroupNames),
          laneIds: [],
          turnDirections: ['STRAIGHT'],
          trafficType: 'PEDESTRIAN',
          ampelIds: [signal1.id, signal2.id],
        },
      ],
    });
    setExpandedPedestrianCrossingId(crossing.id);
  }

  function updatePedestrianCrossing(
    crossing: IntersectionWizardPedestrianCrossingAppDto,
    patch: Partial<IntersectionWizardPedestrianCrossingAppDto>,
  ) {
    updateDraft({
      pedestrianCrossings: (draft.pedestrianCrossings ?? []).map((entry) =>
        entry.id === crossing.id ? { ...entry, ...patch } : entry,
      ),
    });
  }

  function removePedestrianCrossing(crossing: IntersectionWizardPedestrianCrossingAppDto) {
    const group = draft.signalGroups.find((entry) => entry.id === crossing.signalGroupId);
    const removableAmpelIds =
      group?.ampelIds.filter(
        (ampelId) => draft.ampeln.find((ampel) => ampel.id === ampelId)?.use === 'PEDESTRIAN_ONLY',
      ) ?? [];
    updateDraft({
      pedestrianCrossings: (draft.pedestrianCrossings ?? []).filter((entry) => entry.id !== crossing.id),
      ampeln: draft.ampeln.filter((ampel) => !removableAmpelIds.includes(ampel.id)),
      signalGroups: draft.signalGroups.filter((entry) => entry.id !== crossing.signalGroupId),
      phases: draft.phases.map((phase) => ({
        ...phase,
        signalGroupIds: phase.signalGroupIds.filter((signalGroupId) => signalGroupId !== crossing.signalGroupId),
      })),
    });
    setExpandedPedestrianCrossingId((current) => (current === crossing.id ? null : current));
  }

  function routeRulesWithoutSignalGroup(signalGroupId: string) {
    return (draft.routeRules ?? [])
      .map((rule) => ({
        ...rule,
        signalGroupIds: rule.signalGroupIds.filter((id) => id !== signalGroupId),
      }))
      .filter((rule) => rule.signalGroupIds.length > 0);
  }

  function routeRuleForSignalGroup(laneId: string, signalGroupId: string) {
    return (draft.routeRules ?? []).find(
      (rule) => rule.laneId === laneId && rule.signalGroupIds.includes(signalGroupId),
    );
  }

  function hasDefaultRequestDisplay(laneId: string, signalGroupId: string) {
    return (draft.defaultRequestDisplays ?? []).some(
      (entry) => entry.laneId === laneId && entry.signalGroupId === signalGroupId,
    );
  }

  function updateDefaultRequestDisplay(laneId: string, signalGroupId: string, enabled: boolean) {
    const current = draft.defaultRequestDisplays ?? [];
    updateDraft({
      defaultRequestDisplays: enabled
        ? [...current, { laneId, signalGroupId }].filter(
            (entry, index, entries) =>
              entries.findIndex(
                (candidate) => candidate.laneId === entry.laneId && candidate.signalGroupId === entry.signalGroupId,
              ) === index,
          )
        : current.filter((entry) => !(entry.laneId === laneId && entry.signalGroupId === signalGroupId)),
    });
  }

  function routeSelectionForSignalGroup(
    lane: IntersectionWizardLaneAppDto,
    group: IntersectionWizardSignalGroupAppDto,
  ) {
    const rule = routeRuleForSignalGroup(lane.id, group.id);
    return rule ? rule.routeNames : [alwaysRouteOption];
  }

  function updatePanelRoutes(
    lane: IntersectionWizardLaneAppDto,
    group: IntersectionWizardSignalGroupAppDto,
    values: string[],
  ) {
    const normalizedValues = values
      .map((value) => value.trim())
      .filter(Boolean)
      .map((value) => (value === alwaysRouteLabel ? alwaysRouteOption : value));
    const useAlways = normalizedValues.length === 0 || normalizedValues.includes(alwaysRouteOption);
    const currentRule = routeRuleForSignalGroup(lane.id, group.id);
    const routeRules = routeRulesWithoutSignalGroup(group.id);
    const signalGroups = draft.signalGroups.map((entry) =>
      entry.id === group.id
        ? {
            ...entry,
            laneIds: useAlways
              ? Array.from(new Set([...entry.laneIds, lane.id]))
              : entry.laneIds.filter((laneId) => laneId !== lane.id),
          }
        : entry,
    );

    updateDraft({
      signalGroups,
      routeRules: useAlways
        ? routeRules
        : [
            ...routeRules,
            {
              id: currentRule?.id ?? `route-rule-${Date.now()}`,
              laneId: lane.id,
              routeNames: normalizedValues.filter((value) => value !== alwaysRouteOption),
              signalGroupIds: [group.id],
              mode: currentRule?.mode ?? 'ONLY',
              showRequests: currentRule?.showRequests ?? true,
            },
          ],
    });
  }

  function updatePanelMode(
    lane: IntersectionWizardLaneAppDto,
    group: IntersectionWizardSignalGroupAppDto,
    mode: IntersectionWizardRouteRuleAppDto['mode'],
  ) {
    const currentRule = routeRuleForSignalGroup(lane.id, group.id);
    if (!currentRule) return;
    updateRouteRule(currentRule.id, { mode });
  }

  function addDirectionalPanel(lane: IntersectionWizardLaneAppDto) {
    const turnDirection = lane.turnDirections[0] ?? 'STRAIGHT';
    const usedNames = new Set(draft.signalGroups.map((group) => group.name));
    const ampel = createPanelAmpel();
    updateDraft({
      ampeln: [...draft.ampeln, ampel],
      signalGroups: [
        ...draft.signalGroups,
        {
          id: nextSignalGroupId(draft.signalGroups),
          name: uniqueSignalGroupName(signalGroupNameForLane({ ...lane, turnDirections: [turnDirection] }), usedNames),
          laneIds: [lane.id],
          turnDirections: [turnDirection],
          trafficType: 'CAR',
          ampelIds: [ampel.id],
        },
      ],
    });
  }

  function removePanel(lane: IntersectionWizardLaneAppDto, group: IntersectionWizardSignalGroupAppDto) {
    const laneAmpel = selectedLaneAmpel(lane);
    const removableAmpelIds = group.ampelIds.filter((ampelId) => ampelId !== laneAmpel?.id);
    updateDraft({
      ampeln: draft.ampeln.filter((ampel) => !removableAmpelIds.includes(ampel.id)),
      signalGroups: draft.signalGroups.filter((entry) => entry.id !== group.id),
      routeRules: routeRulesWithoutSignalGroup(group.id),
      defaultRequestDisplays: (draft.defaultRequestDisplays ?? []).filter(
        (entry) => entry.laneId !== lane.id || entry.signalGroupId !== group.id,
      ),
      phases: draft.phases.map((phase) => ({
        ...phase,
        signalGroupIds: phase.signalGroupIds.filter((signalGroupId) => signalGroupId !== group.id),
      })),
    });
  }

  function addAmpelToSignalGroup(group: IntersectionWizardSignalGroupAppDto) {
    const ampel = createPanelAmpel();
    updateDraft({
      ampeln: [...draft.ampeln, ampel],
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === group.id ? { ...entry, ampelIds: [...entry.ampelIds, ampel.id] } : entry,
      ),
    });
  }

  function removeAmpelFromSignalGroup(group: IntersectionWizardSignalGroupAppDto, ampelId: string) {
    updateDraft({
      ampeln: draft.ampeln.filter((ampel) => ampel.id !== ampelId),
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === group.id ? { ...entry, ampelIds: entry.ampelIds.filter((id) => id !== ampelId) } : entry,
      ),
    });
  }

  function addPedestrianSignalToGroup(group: IntersectionWizardSignalGroupAppDto) {
    const ampel = createPedestrianAmpel();
    updateDraft({
      ampeln: [...draft.ampeln, ampel],
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === group.id ? { ...entry, ampelIds: [...entry.ampelIds, ampel.id] } : entry,
      ),
    });
  }

  function removePedestrianSignalFromGroup(
    group: IntersectionWizardSignalGroupAppDto,
    ampel: IntersectionWizardAmpelAppDto,
  ) {
    updateDraft({
      ampeln: ampel.use === 'PEDESTRIAN_ONLY' ? draft.ampeln.filter((entry) => entry.id !== ampel.id) : draft.ampeln,
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === group.id
          ? { ...entry, ampelIds: entry.ampelIds.filter((ampelId) => ampelId !== ampel.id) }
          : entry,
      ),
    });
  }

  function pedestrianDisplayName(ampel: IntersectionWizardAmpelAppDto) {
    return ampel.use === 'VEHICLE_AND_PEDESTRIAN' ? (ampel.pedestrianName ?? ampel.name) : ampel.name;
  }

  function updatePedestrianSignalName(
    group: IntersectionWizardSignalGroupAppDto,
    ampel: IntersectionWizardAmpelAppDto,
    name: string,
  ) {
    updateDraft({
      ampeln: draft.ampeln.map((entry) =>
        entry.id === ampel.id
          ? entry.use === 'PEDESTRIAN_ONLY'
            ? { ...entry, name }
            : { ...entry, use: 'VEHICLE_AND_PEDESTRIAN', pedestrianName: name }
          : entry,
      ),
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === group.id ? { ...entry, ampelIds: Array.from(new Set(entry.ampelIds)) } : entry,
      ),
    });
  }

  function updatePedestrianSignalSource(
    group: IntersectionWizardSignalGroupAppDto,
    ampel: IntersectionWizardAmpelAppDto,
    sourceId: string,
  ) {
    if (sourceId === '__OWN_PEDESTRIAN_SIGNAL__') {
      if (ampel.use === 'PEDESTRIAN_ONLY') return;
      const ownAmpel = createPedestrianAmpel(pedestrianDisplayName(ampel));
      updateDraft({
        ampeln: [...draft.ampeln, ownAmpel],
        signalGroups: draft.signalGroups.map((entry) =>
          entry.id === group.id
            ? { ...entry, ampelIds: entry.ampelIds.map((ampelId) => (ampelId === ampel.id ? ownAmpel.id : ampelId)) }
            : entry,
        ),
      });
      return;
    }

    const source = draft.ampeln.find((entry) => entry.id === sourceId);
    if (!source) return;
    const pedestrianName = pedestrianDisplayName(ampel);
    updateDraft({
      ampeln: draft.ampeln
        .filter((entry) => !(entry.id === ampel.id && ampel.use === 'PEDESTRIAN_ONLY'))
        .map((entry) => (entry.id === source.id ? { ...entry, use: 'VEHICLE_AND_PEDESTRIAN', pedestrianName } : entry)),
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === group.id
          ? { ...entry, ampelIds: entry.ampelIds.map((ampelId) => (ampelId === ampel.id ? source.id : ampelId)) }
          : entry,
      ),
    });
  }

  function updateLane(id: string, patch: Partial<IntersectionWizardLaneAppDto>) {
    updateDraft({ lanes: draft.lanes.map((lane) => (lane.id === id ? { ...lane, ...patch } : lane)) });
  }

  function updateSignalGroup(id: string, patch: Partial<IntersectionWizardSignalGroupAppDto>) {
    updateDraft({
      signalGroups: draft.signalGroups.map((group) => (group.id === id ? { ...group, ...patch } : group)),
    });
  }

  function addSignalGroup() {
    const firstLane = draft.lanes[0];
    const usedNames = new Set(draft.signalGroups.map((group) => group.name));
    updateDraft({
      signalGroups: [
        ...draft.signalGroups,
        {
          id: nextSignalGroupId(draft.signalGroups),
          name: uniqueSignalGroupName(firstLane ? signalGroupNameForLane(firstLane) : 'sg', usedNames),
          laneIds: firstLane ? [firstLane.id] : [],
          turnDirections: firstLane?.turnDirections ?? ['STRAIGHT'],
          trafficType: 'CAR',
          ampelIds: [],
        },
      ],
    });
  }

  function removeSignalGroup(id: string) {
    updateDraft({
      signalGroups: draft.signalGroups.filter((group) => group.id !== id),
      defaultRequestDisplays: (draft.defaultRequestDisplays ?? []).filter((entry) => entry.signalGroupId !== id),
      routeRules: (draft.routeRules ?? [])
        .map((rule) => ({
          ...rule,
          signalGroupIds: rule.signalGroupIds.filter((signalGroupId) => signalGroupId !== id),
        }))
        .filter((rule) => rule.signalGroupIds.length > 0),
      phases: draft.phases.map((phase) => ({
        ...phase,
        signalGroupIds: phase.signalGroupIds.filter((signalGroupId) => signalGroupId !== id),
      })),
    });
  }

  function addPhase() {
    const usedIds = new Set(draft.phases.map((phase) => phase.id));
    let phaseNr = draft.phases.length + 1;
    while (usedIds.has(`phase-${phaseNr}`)) phaseNr += 1;
    updateDraft({ phases: [...draft.phases, { id: `phase-${phaseNr}`, name: `P${phaseNr}`, signalGroupIds: [] }] });
  }

  function removePhase(id: string) {
    updateDraft({ phases: draft.phases.filter((phase) => phase.id !== id) });
  }

  function addRouteRule() {
    updateDraft({
      routeRules: [
        ...(draft.routeRules ?? []),
        {
          id: `route-rule-${Date.now()}`,
          laneId: draft.lanes[0]?.id ?? '',
          routeNames: routeOptions[0] ? [routeOptions[0]] : [],
          signalGroupIds: draft.signalGroups[0]?.id ? [draft.signalGroups[0].id] : [],
          mode: 'ONLY',
          showRequests: true,
        },
      ],
    });
  }

  function updateRouteRule(id: string, patch: Partial<IntersectionWizardRouteRuleAppDto>) {
    updateDraft({
      routeRules: (draft.routeRules ?? []).map((rule) => (rule.id === id ? { ...rule, ...patch } : rule)),
    });
  }

  function prepareDraftForSignalGroups(draftToPrepare: IntersectionWizardDraftAppDto): IntersectionWizardDraftAppDto {
    const nextAmpeln = [...draftToPrepare.ampeln];
    const laneAmpelByLaneId = new Map<string, IntersectionWizardAmpelAppDto>();
    draftToPrepare.lanes.forEach((lane, index) => {
      const signalId = lane.signalId.trim();
      const existingAmpel =
        nextAmpeln.find((ampel) => signalId && ampel.signalId.trim() === signalId) ??
        nextAmpeln.find((ampel) => ampel.id === laneAmpelId(lane));
      const laneAmpel =
        existingAmpel ??
        ({
          ...ampelForLane(lane, nextAmpeln.length + index + 1),
          id: laneAmpelId(lane),
        } satisfies IntersectionWizardAmpelAppDto);
      if (!existingAmpel) nextAmpeln.push(laneAmpel);
      laneAmpelByLaneId.set(lane.id, laneAmpel);
    });

    const baseSignalGroups =
      draftToPrepare.signalGroups.length > 0
        ? draftToPrepare.signalGroups
        : signalGroupsForEachLane(draftToPrepare.lanes);
    const nextSignalGroups = baseSignalGroups.map((group) => {
      const laneAmpelIds = group.laneIds
        .map((laneId) => laneAmpelByLaneId.get(laneId)?.id)
        .filter((id): id is string => Boolean(id));
      return { ...group, ampelIds: Array.from(new Set([...laneAmpelIds, ...group.ampelIds])) };
    });

    return {
      ...draftToPrepare,
      ampeln: nextAmpeln,
      signalGroups: nextSignalGroups,
      updatedAt: new Date().toISOString(),
    };
  }

  async function persistAndNavigate(stepIndex: number, draftToPersist = draft) {
    const saved = await persistDraft(draftToPersist);
    if (saved) {
      setLoadedDraftId(saved.id);
      navigateToStep(stepIndex, { draftId: saved.id, removeIntersectionId: true });
      return;
    }
    navigateToStep(stepIndex);
  }

  function goToNextStep() {
    if (activeStep === 2 && draft.lanes.length === 0) return;
    let nextDraft = draft;
    if (activeStep === 2 && draft.lanes.length > 0) {
      nextDraft = prepareDraftForSignalGroups(draft);
      setDraft(nextDraft);
    }
    if (activeStep === 3 && draft.phases.length === 0) {
      nextDraft = { ...nextDraft, phases: defaultPhases(), updatedAt: new Date().toISOString() };
      setDraft(nextDraft);
    }
    void persistAndNavigate(Math.min(activeStep + 1, steps.length - 1), nextDraft);
  }

  function navigationButtons() {
    const nextDisabled = activeStep === steps.length - 1 || (activeStep === 2 && draft.lanes.length === 0);
    return (
      <IntersectionWizardNavigation
        activeStep={activeStep}
        nextDisabled={nextDisabled}
        onBack={() => void persistAndNavigate(Math.max(activeStep - 1, 0))}
        onNext={goToNextStep}
      />
    );
  }

  function updatePhase(id: string, patch: Partial<IntersectionWizardPhaseAppDto>) {
    updateDraft({ phases: draft.phases.map((phase) => (phase.id === id ? { ...phase, ...patch } : phase)) });
  }

  function togglePhaseSignalGroup(phase: IntersectionWizardPhaseAppDto, signalGroupId: string) {
    const signalGroupIds = phase.signalGroupIds.includes(signalGroupId)
      ? phase.signalGroupIds.filter((id) => id !== signalGroupId)
      : [...phase.signalGroupIds, signalGroupId];
    updatePhase(phase.id, { signalGroupIds });
  }

  function startNewIntersection() {
    if (sendPreparationSettings) {
      sendRoadModulePreparationSettings();
    }
    const defaultCxName = firstFreeCxName(scenarioIntersectionNames);
    const draftToStart =
      draft.name.trim() || draft.luaVariableName !== 'kreuzung'
        ? draft
        : {
            ...draft,
            name: defaultCxName,
            luaVariableName: defaultCxName,
            lanes: renameAutoLaneNames(draft.lanes, draft.luaVariableName, defaultCxName),
          };
    if (draftToStart !== draft) setDraft(draftToStart);
    void persistAndNavigate(1, draftToStart);
  }

  function stepContent() {
    if (activeStep === 0) {
      return (
        <IntersectionWizardStartStep
          isLoadingIntersection={Boolean(intersectionIdFromUrl && !draftIdFromUrl)}
          sendPreparationSettings={sendPreparationSettings}
          onSendPreparationSettingsChange={setSendPreparationSettings}
          onStartNewIntersection={startNewIntersection}
        />
      );
    }

    if (activeStep === 1) {
      return (
        <IntersectionWizardSettingsStep
          cameraOptions={cameraOptions}
          draft={draft}
          showAdvancedIntersectionSettings={showAdvancedIntersectionSettings}
          storageSlotOptions={storageSlotOptions}
          onDraftPatch={updateDraft}
          onIntersectionNameChange={(name) => {
            const luaVariableName = slug(name, 'kreuzung');
            updateDraft({
              name,
              luaVariableName,
              lanes: renameAutoLaneNames(draft.lanes, draft.luaVariableName, luaVariableName),
            });
          }}
          onLuaVariableNameChange={(luaVariableName) =>
            updateDraft({
              luaVariableName,
              lanes: renameAutoLaneNames(draft.lanes, draft.luaVariableName, luaVariableName),
            })
          }
          onOptionalPositiveNumber={optionalPositiveNumber}
          onShowAdvancedIntersectionSettingsChange={setShowAdvancedIntersectionSettings}
        />
      );
    }

    if (activeStep === 2) {
      const laneVariableNames = laneLuaVariableNames(draft.lanes, draft.luaVariableName || 'kreuzung');
      const signalModelOptionsForLane = (lane: IntersectionWizardLaneAppDto, index: number) => {
        const laneAmpel = selectedLaneAmpel(lane) ?? {
          ...ampelForLane(lane, index + 1),
          id: laneAmpelId(lane),
        };
        const selectedModelValue = laneAmpel.modelConstant || laneAmpel.modelName;
        const modelOptions =
          selectedModelValue &&
          !trafficLightModelOptions.some(
            (option) => (option.model.luaConstant ?? option.model.name) === selectedModelValue,
          )
            ? [
                {
                  model: {
                    id: selectedModelValue,
                    name: selectedModelValue,
                    luaConstant: selectedModelValue,
                  } as TrafficLightModelAppDto,
                  label: selectedModelValue,
                },
                ...trafficLightModelOptions,
              ]
            : trafficLightModelOptions;

        return { laneAmpel, modelOptions, selectedModelValue };
      };

      function renderLaneEditor(lane: IntersectionWizardLaneAppDto, index: number) {
        const luaVariableName = laneVariableNames.get(lane.id) ?? `lane${index + 1}`;
        const { laneAmpel, modelOptions, selectedModelValue } = signalModelOptionsForLane(lane, index);
        const luaVariableReadonly = !(draft.manualLuaVariableNames ?? false);

        return (
          <Box sx={{ py: 2 }}>
            <Stack spacing={2.5}>
              <Stack spacing={1.25}>
                <Typography variant="subtitle2">Fahrspur</Typography>
                <Box sx={editorSectionGridSx}>
                  <FormApproachSelect
                    id={`${lane.id}-approach`}
                    value={lane.approach ?? 'SOUTH'}
                    infoText="Aus dieser Richtung kommen Fahrzeuge."
                    onChange={(approach) => updateLane(lane.id, { approach })}
                  />
                  <FormTurnToggle
                    label="Abbiegerichtungen"
                    value={lane.turnDirections}
                    infoText="Wähle die Abbiegerichtungen."
                    onChange={(turnDirections) => updateLane(lane.id, { turnDirections })}
                  />
                  <FormTextfield
                    label="Name der Fahrspur"
                    value={lane.name}
                    infoText="Dient nur der Anzeige."
                    inputProps={{ maxLength: 10, 'aria-label': `Name der Fahrspur ${lane.name}` }}
                    onChange={(event) => updateLane(lane.id, { name: event.target.value })}
                  />
                </Box>
              </Stack>
              <Stack spacing={1.25}>
                <Typography variant="subtitle2">Fahrspur-Signal</Typography>
                <Box sx={editorSectionGridSx}>
                  <FormTextfield
                    label="Signal-ID"
                    value={lane.signalId}
                    infoText="Fahrspur-Signal-ID aus EEP."
                    inputProps={{ inputMode: 'numeric', maxLength: 4, 'aria-label': `Signal-ID ${lane.name}` }}
                    onBlur={() => void enrichLaneAmpelFromSignal(lane)}
                    onChange={(event) =>
                      updateLaneAndAmpel(lane, { signalId: event.target.value }, { signalId: event.target.value })
                    }
                  />
                  <FormTextfield
                    label="Ampelname"
                    value={laneAmpel.name}
                    infoText="Angezeigter Name der Ampel."
                    inputProps={{ maxLength: 4, 'aria-label': `Ampelname ${lane.name}` }}
                    onChange={(event) => updateLaneAndAmpel(lane, {}, { name: event.target.value })}
                  />
                  <FormSelect
                    id={`${lane.id}-signal-model`}
                    label="Ampelmodell"
                    value={selectedModelValue}
                    infoText="Wähle aus der Liste aus."
                    onChange={(value) => {
                      const option = modelOptions.find(
                        (entry) => (entry.model.luaConstant ?? entry.model.name) === value,
                      );
                      updateLaneAndAmpel(
                        lane,
                        {},
                        {
                          modelName: option?.model.name ?? value,
                          modelConstant: option?.model.luaConstant ?? value,
                        },
                      );
                    }}
                    options={modelOptions.map((option) => {
                      const value = option.model.luaConstant ?? option.model.name;
                      return {
                        value,
                        label: compactTrafficLightModelLabel(option.model),
                      };
                    })}
                  />
                </Box>
              </Stack>
              <Stack spacing={1.25}>
                <Typography variant="subtitle2">Erweiterte Einstellungen</Typography>
                <Box sx={editorSectionGridSx}>
                  <FormTextfield
                    label={readonlyTitle('Lua-Variablenname', luaVariableReadonly)}
                    value={luaVariableName}
                    infoText="Eindeutiger Name für Kontaktpunkte."
                    InputProps={{ readOnly: luaVariableReadonly }}
                    inputProps={{
                      readOnly: luaVariableReadonly,
                      'aria-label': `Lua-Variablenname ${lane.name}`,
                    }}
                    onChange={(event) => {
                      if (luaVariableReadonly) return;
                      updateLane(lane.id, { luaVariableName: event.target.value });
                    }}
                  />
                  {draft.individualLanePhaseSettings && (
                    <FormTextfield
                      label="Fahrzeugmultiplikator"
                      type="number"
                      value={lane.vehicleMultiplier ?? 1}
                      infoText="Je höher, desto mehr Priorität."
                      inputProps={{ min: 1, 'aria-label': `Fahrzeugmultiplikator ${lane.name}` }}
                      onChange={(event) =>
                        updateLane(lane.id, {
                          vehicleMultiplier: optionalPositiveNumber(event.target.value) ?? 1,
                        })
                      }
                    />
                  )}
                </Box>
              </Stack>
            </Stack>
          </Box>
        );
      }

      function renderLaneTable() {
        return (
          <Stack spacing={1.5}>
            <IconHeadline text="Fahrspuren" icon={<DirectionsCarIcon />} variant="h6" />
            <TableContainer component={Paper} variant="outlined">
              <Table
                size="small"
                aria-label="Fahrspuren mit Editor"
                sx={{
                  '& tbody tr:last-of-type td': {
                    borderBottom: 0,
                  },
                }}
              >
                <TableHead>
                  <TableRow>
                    <TableCell sx={{ width: 56 }} />
                    <TableCell sx={compactTableColumnSx}>Zufahrt aus</TableCell>
                    <TableCell sx={compactTableColumnSx}>Abbiegerichtungen</TableCell>
                    <TableCell sx={compactTableColumnSx}>Fahrspur</TableCell>
                    <TableCell sx={compactTableColumnSx}>Signal</TableCell>
                    <TableCell sx={compactTableColumnSx}>Ampel</TableCell>
                    <TableCell sx={compactTableColumnSx}>Ampelmodell</TableCell>
                    <TableCell />
                    <TableCell align="right" sx={{ width: 56 }} />
                  </TableRow>
                </TableHead>
                <TableBody>
                  {draft.lanes.map((lane, index) => {
                    const { laneAmpel, selectedModelValue } = signalModelOptionsForLane(lane, index);
                    return (
                      <ExpandableEditorTableRow
                        key={lane.id}
                        ariaLabel={lane.name || 'Fahrspur'}
                        expanded={expandedLaneId === lane.id}
                        dataCellCount={7}
                        deletable
                        editor={renderLaneEditor(lane, index)}
                        onDelete={() => removeLane(lane)}
                        onToggle={() => setExpandedLaneId((current) => (current === lane.id ? null : lane.id))}
                      >
                        <TableCell sx={compactTableColumnSx}>
                          <Approach approach={lane.approach ?? 'SOUTH'} />
                        </TableCell>
                        <TableCell sx={compactTableColumnSx}>
                          <NeutralTurnToggle value={lane.turnDirections} />
                        </TableCell>
                        <TableCell sx={compactTableColumnSx}>{lane.name || '-'}</TableCell>
                        <TableCell sx={compactTableColumnSx}>{lane.signalId || '-'}</TableCell>
                        <TableCell sx={compactTableColumnSx}>{laneAmpel.name || '-'}</TableCell>
                        <TableCell sx={compactTableColumnSx}>{selectedModelValue || '-'}</TableCell>
                        <TableCell />
                      </ExpandableEditorTableRow>
                    );
                  })}
                </TableBody>
              </Table>
            </TableContainer>
            <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
              <Button variant="contained" startIcon={<AddIcon />} onClick={addLane}>
                Fahrspur hinzufügen
              </Button>
            </Box>
          </Stack>
        );
      }

      function renderPedestrianCrossingEditor(crossing: IntersectionWizardPedestrianCrossingAppDto) {
        return (
          <Box sx={{ py: 2 }}>
            <Box sx={editorSectionGridSx}>
              <FormSelect
                id={`${crossing.id}-approach`}
                label="Überquerung von"
                value={crossing.approach}
                infoText="Aus dieser Richtung wird die Straße überquert."
                renderValue={(value) => <Approach approach={value} />}
                onChange={(approach) => updatePedestrianCrossing(crossing, { approach })}
                options={approaches.map((approach) => ({
                  value: approach,
                  label: <Approach approach={approach} />,
                }))}
              />
              <FormTextfield
                label="Name der Furt"
                value={crossing.name}
                infoText="Dient nur der Anzeige."
                inputProps={{ maxLength: 32, 'aria-label': `Name der Furt ${crossing.name}` }}
                onChange={(event) => updatePedestrianCrossing(crossing, { name: event.target.value })}
              />
            </Box>
          </Box>
        );
      }

      function renderPedestrianCrossingTable() {
        return (
          <Stack spacing={1.5}>
            <IconHeadline text="Fußgängerfurten" icon={<DirectionsWalkIcon />} variant="h6" />
            <TableContainer component={Paper} variant="outlined">
              <Table
                size="small"
                aria-label="Fußgängerfurten mit Editor"
                sx={{
                  '& tbody tr:last-of-type td': {
                    borderBottom: 0,
                  },
                }}
              >
                <TableHead>
                  <TableRow>
                    <TableCell sx={{ width: 56 }} />
                    <TableCell sx={compactTableColumnSx}>Überquerung von</TableCell>
                    <TableCell sx={compactTableColumnSx}>Fußgängerfurt</TableCell>
                    <TableCell />
                    <TableCell align="right" sx={{ width: 56 }} />
                  </TableRow>
                </TableHead>
                <TableBody>
                  {(draft.pedestrianCrossings ?? []).map((crossing) => (
                    <ExpandableEditorTableRow
                      key={crossing.id}
                      ariaLabel={crossing.name || 'Fußgängerfurt'}
                      expanded={expandedPedestrianCrossingId === crossing.id}
                      dataCellCount={3}
                      deletable
                      editor={renderPedestrianCrossingEditor(crossing)}
                      onDelete={() => removePedestrianCrossing(crossing)}
                      onToggle={() =>
                        setExpandedPedestrianCrossingId((current) => (current === crossing.id ? null : crossing.id))
                      }
                    >
                      <TableCell sx={compactTableColumnSx}>
                        <Approach approach={crossing.approach} />
                      </TableCell>
                      <TableCell sx={compactTableColumnSx}>{crossing.name || '-'}</TableCell>
                      <TableCell />
                    </ExpandableEditorTableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
            <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
              <Button variant="contained" startIcon={<AddIcon />} onClick={addPedestrianCrossing}>
                Fußgängerfurt hinzufügen
              </Button>
            </Box>
          </Stack>
        );
      }

      return (
        <Stack spacing={2}>
          {renderLaneTable()}
          {draft.supportPedestrianSignals && renderPedestrianCrossingTable()}
        </Stack>
      );
    }

    if (activeStep === 3) {
      const routeSignalGroupIds = new Set((draft.routeRules ?? []).flatMap((rule) => rule.signalGroupIds));
      const lanesByApproach = approaches
        .map((approach) => ({
          approach,
          lanes: draft.lanes.filter((lane) => normalizedApproach(lane.approach) === approach),
          pedestrianCrossings: (draft.pedestrianCrossings ?? []).filter((crossing) => crossing.approach === approach),
        }))
        .filter((entry) => entry.lanes.length > 0 || entry.pedestrianCrossings.length > 0);
      const signalGroupNamesEditable = draft.manualLuaVariableNames ?? false;

      function renderReadonlyTurnDirections(directions: IntersectionWizardTurnDirection[]) {
        return (
          <ToggleButtonGroup
            value={directions}
            size="small"
            sx={{
              flexWrap: 'wrap',
              pointerEvents: 'none',
              '& .MuiToggleButtonGroup-grouped': {
                minHeight: 40,
              },
            }}
          >
            {turnDirections.map((direction) => {
              const DirectionIcon = turnDirectionIcons[direction];
              const selected = directions.includes(direction);
              return (
                <ToggleButton
                  key={direction}
                  value={direction}
                  aria-label={turnDirectionLabels[direction]}
                  title={turnDirectionLabels[direction]}
                  sx={{
                    px: 1.5,
                    color: selected ? 'common.white' : 'text.disabled',
                    bgcolor: selected ? (theme) => alpha(theme.palette.primary.main, 0.6) : undefined,
                    borderColor: selected ? (theme) => alpha(theme.palette.primary.main, 0.28) : undefined,
                    '&.Mui-selected, &.Mui-selected:hover': {
                      color: 'common.white',
                      bgcolor: (theme) => alpha(theme.palette.primary.main, 0.6),
                      borderColor: (theme) => alpha(theme.palette.primary.main, 0.28),
                    },
                  }}
                >
                  <DirectionIcon fontSize="small" />
                </ToggleButton>
              );
            })}
          </ToggleButtonGroup>
        );
      }

      function renderAmpelRow(
        lane: IntersectionWizardLaneAppDto,
        group: IntersectionWizardSignalGroupAppDto,
        ampel: IntersectionWizardAmpelAppDto,
        readonly: boolean,
      ) {
        const selectedModelValue = ampel.modelConstant || ampel.modelName;
        const modelOptions =
          selectedModelValue &&
          !trafficLightModelOptions.some(
            (option) => (option.model.luaConstant ?? option.model.name) === selectedModelValue,
          )
            ? [
                {
                  model: {
                    id: selectedModelValue,
                    name: selectedModelValue,
                    luaConstant: selectedModelValue,
                  } as TrafficLightModelAppDto,
                  label: selectedModelValue,
                },
                ...trafficLightModelOptions,
              ]
            : trafficLightModelOptions;

        return (
          <Box
            key={ampel.id}
            sx={{
              display: 'grid',
              gap: 1.25,
              gridTemplateColumns: { xs: '1fr', md: '5rem 5rem minmax(13rem, 1fr) 2.5rem' },
              alignItems: 'end',
            }}
          >
            <Stack spacing={0.5}>
              <Typography variant="caption" color="text.secondary">
                Signal-ID
              </Typography>
              <TextField
                value={ampel.signalId}
                size="small"
                disabled={readonly}
                inputProps={{ maxLength: 4, 'aria-label': `Signal-ID ${ampel.name}` }}
                onChange={(event) => updateAmpel(ampel.id, { signalId: event.target.value })}
              />
            </Stack>
            <Stack spacing={0.5}>
              <Typography variant="caption" color="text.secondary">
                Ampelname
              </Typography>
              <TextField
                value={ampel.name}
                size="small"
                disabled={readonly}
                inputProps={{ maxLength: 4, 'aria-label': `Ampelname ${ampel.signalId || lane.name}` }}
                onChange={(event) => updateAmpel(ampel.id, { name: event.target.value })}
              />
            </Stack>
            <Stack spacing={0.5}>
              <Typography variant="caption" color="text.secondary">
                Ampelmodell
              </Typography>
              <FormControl size="small" fullWidth disabled={readonly}>
                <Select
                  value={selectedModelValue}
                  inputProps={{ 'aria-label': `Ampelmodell ${ampel.signalId || lane.name}` }}
                  onChange={(event) => {
                    const value = event.target.value;
                    const option = trafficLightModelOptions.find(
                      (entry) => (entry.model.luaConstant ?? entry.model.name) === value,
                    );
                    updateAmpel(ampel.id, {
                      modelName: option?.model.name ?? value,
                      modelConstant: option?.model.luaConstant ?? value,
                    });
                  }}
                >
                  {modelOptions.map((option) => {
                    const value = option.model.luaConstant ?? option.model.name;
                    return (
                      <MenuItem key={value} value={value}>
                        {compactTrafficLightModelLabel(option.model)}
                      </MenuItem>
                    );
                  })}
                </Select>
              </FormControl>
            </Stack>
            {readonly ? (
              <Box sx={{ width: 40, height: 40 }} />
            ) : (
              <IconButton
                size="small"
                aria-label={`Ampel ${ampel.name || ampel.signalId || ampel.id} löschen`}
                title="Ampel löschen"
                onClick={() => removeAmpelFromSignalGroup(group, ampel.id)}
                sx={{
                  width: 40,
                  height: 40,
                  color: 'text.secondary',
                  '&:hover': { color: 'error.main', bgcolor: 'error.light' },
                }}
              >
                <DeleteIcon fontSize="small" />
              </IconButton>
            )}
          </Box>
        );
      }

      function renderSignalGroupPanel(
        lane: IntersectionWizardLaneAppDto,
        group: IntersectionWizardSignalGroupAppDto,
        laneAmpel: IntersectionWizardAmpelAppDto,
        variant: 'simple' | 'standard' | 'route',
      ) {
        const routeRule = routeRuleForSignalGroup(lane.id, group.id);
        const panelIsRouteBased = variant === 'route' || Boolean(routeRule);
        const ampelIds = Array.from(
          new Set(variant === 'simple' ? group.ampelIds : group.ampelIds.filter((ampelId) => ampelId !== laneAmpel.id)),
        );
        const ampeln = ampelIds
          .map((ampelId) => draft.ampeln.find((ampel) => ampel.id === ampelId))
          .filter((ampel): ampel is IntersectionWizardAmpelAppDto => Boolean(ampel));

        if (variant === 'simple') {
          return (
            <Stack key={`${lane.id}-${group.id}-${variant}`} spacing={1.5}>
              <Stack spacing={0.5}>
                <Typography variant="caption" color="text.secondary">
                  {readonlyTitle('Signalgruppe', !signalGroupNamesEditable)}
                </Typography>
                <TextField
                  value={group.name}
                  onChange={(event) => {
                    if (!signalGroupNamesEditable) return;
                    updateSignalGroup(group.id, { name: event.target.value });
                  }}
                  size="small"
                  InputProps={{ readOnly: !signalGroupNamesEditable }}
                  inputProps={{
                    maxLength: 24,
                    readOnly: !signalGroupNamesEditable,
                    'aria-label': `Signalgruppe ${group.name}`,
                  }}
                />
              </Stack>
              <ExplainedCheckbox
                checked={hasDefaultRequestDisplay(lane.id, group.id)}
                label="Anforderungen anzeigen"
                onChange={(_event, checked) => updateDefaultRequestDisplay(lane.id, group.id, checked)}
              />
              <Stack spacing={1}>
                {ampeln.map((ampel) => renderAmpelRow(lane, group, ampel, ampel.id === laneAmpel.id))}
                <Button size="small" startIcon={<AddIcon />} onClick={() => addAmpelToSignalGroup(group)}>
                  Ampel hinzufügen
                </Button>
              </Stack>
            </Stack>
          );
        }

        return (
          <Paper
            key={`${lane.id}-${group.id}-${variant}`}
            variant="outlined"
            sx={{ p: 1.5, borderRadius: 2, bgcolor: '#f3faf4' }}
          >
            <Stack spacing={1.5}>
              <Stack direction="row" spacing={1} alignItems="center">
                <Typography variant="subtitle2" sx={{ flex: 1 }}>
                  {variant === 'standard'
                    ? `Standard-Signalgruppe: ${group.name || group.id}`
                    : `Signalgruppe: ${group.name || group.id}`}
                </Typography>
                {variant === 'route' && (
                  <IconButton
                    size="small"
                    aria-label={`Richtungsampel ${group.name || group.id} löschen`}
                    title="Richtungsampel löschen"
                    onClick={() => removePanel(lane, group)}
                  >
                    <DeleteIcon fontSize="small" />
                  </IconButton>
                )}
              </Stack>
              {(variant === 'standard' || variant === 'route') && (
                <ExplainedCheckbox
                  checked={
                    variant === 'route'
                      ? (routeRule?.showRequests ?? hasDefaultRequestDisplay(lane.id, group.id))
                      : hasDefaultRequestDisplay(lane.id, group.id)
                  }
                  label="Anforderungen anzeigen"
                  sx={{ alignSelf: 'flex-start', mr: 0 }}
                  onChange={(_event, checked) => {
                    if (variant === 'route' && routeRule) {
                      updateRouteRule(routeRule.id, { showRequests: checked });
                    } else {
                      updateDefaultRequestDisplay(lane.id, group.id, checked);
                    }
                  }}
                />
              )}
              <Box
                sx={{
                  display: 'grid',
                  gap: 1.25,
                  gridTemplateColumns: {
                    xs: '1fr',
                    md: panelIsRouteBased ? 'max-content minmax(14rem, 1fr) max-content' : '1fr',
                  },
                  alignItems: 'start',
                }}
              >
                <Stack spacing={0.5}>
                  <Typography variant="caption" color="text.secondary">
                    Abbiegerichtungen der Signalgruppe
                  </Typography>
                  <ToggleButtonGroup
                    value={group.turnDirections}
                    size="small"
                    sx={{
                      flexWrap: 'wrap',
                      '& .MuiToggleButtonGroup-grouped': {
                        minHeight: 40,
                      },
                    }}
                  >
                    {turnDirections.map((direction) => {
                      const DirectionIcon = turnDirectionIcons[direction];
                      const disabled = !lane.turnDirections.includes(direction);
                      return (
                        <ToggleButton
                          key={direction}
                          value={direction}
                          disabled={disabled}
                          aria-label={turnDirectionLabels[direction]}
                          title={turnDirectionLabels[direction]}
                          onClick={() =>
                            updateSignalGroup(group.id, {
                              turnDirections: toggleDirectionSelection(group.turnDirections, direction).filter(
                                (selectedDirection) => lane.turnDirections.includes(selectedDirection),
                              ),
                            })
                          }
                          sx={{
                            px: 1.25,
                            color: disabled ? 'text.disabled' : 'grey.900',
                            '&.Mui-selected, &.Mui-selected:hover': {
                              color: 'common.white',
                              bgcolor: 'success.main',
                              borderColor: 'success.main',
                            },
                            '&.Mui-disabled.Mui-selected': {
                              color: 'common.white',
                              bgcolor: 'success.main',
                              borderColor: 'success.main',
                              opacity: 0.65,
                            },
                          }}
                        >
                          <DirectionIcon fontSize="small" />
                        </ToggleButton>
                      );
                    })}
                  </ToggleButtonGroup>
                </Stack>
                {panelIsRouteBased && (
                  <Stack spacing={0.5}>
                    <Typography variant="caption" color="text.secondary">
                      Routen
                    </Typography>
                    <Autocomplete<string, true, false, true>
                      multiple
                      freeSolo
                      size="small"
                      options={[alwaysRouteOption, ...routeOptions]}
                      value={routeSelectionForSignalGroup(lane, group)}
                      getOptionLabel={(option) => (option === alwaysRouteOption ? alwaysRouteLabel : option)}
                      renderTags={(value, getTagProps) =>
                        value.map((option, index) => (
                          <Chip
                            {...getTagProps({ index })}
                            key={`${option}-${index}`}
                            label={option === alwaysRouteOption ? alwaysRouteLabel : option}
                            size="small"
                          />
                        ))
                      }
                      onChange={(_event, values) => updatePanelRoutes(lane, group, values)}
                      renderInput={(params) => <TextField {...params} />}
                    />
                  </Stack>
                )}
                {panelIsRouteBased && (
                  <Stack spacing={0.5}>
                    <Typography variant="caption" color="text.secondary">
                      Bei Standard-Freigabe
                    </Typography>
                    <ToggleButtonGroup
                      exclusive
                      size="small"
                      value={routeRule?.mode ?? 'ONLY'}
                      onChange={(_event, mode) => {
                        if (mode) updatePanelMode(lane, group, mode as IntersectionWizardRouteRuleAppDto['mode']);
                      }}
                      disabled={!routeRule}
                      sx={{
                        '& .MuiToggleButtonGroup-grouped': {
                          minHeight: 40,
                        },
                      }}
                    >
                      <ToggleButton
                        value="ONLY"
                        title="Fahrzeuge mit diesen Routen warten, wenn die Standard-Signalgruppe grün anzeigt."
                      >
                        Warten
                      </ToggleButton>
                      <ToggleButton
                        value="ALSO"
                        title="Fahrzeuge fahren auch, wenn die Standard-Signalgruppe grün anzeigt."
                      >
                        Fahren
                      </ToggleButton>
                    </ToggleButtonGroup>
                  </Stack>
                )}
              </Box>
              <Stack spacing={0.5}>
                <Typography variant="caption" color="text.secondary">
                  {readonlyTitle('Signalgruppe', !signalGroupNamesEditable)}
                </Typography>
                <TextField
                  value={group.name}
                  onChange={(event) => {
                    if (!signalGroupNamesEditable) return;
                    updateSignalGroup(group.id, { name: event.target.value });
                  }}
                  size="small"
                  InputProps={{ readOnly: !signalGroupNamesEditable }}
                  inputProps={{
                    maxLength: 24,
                    readOnly: !signalGroupNamesEditable,
                    'aria-label': `Signalgruppe ${group.name}`,
                  }}
                />
              </Stack>
              <Stack spacing={1}>
                {ampeln.map((ampel) => renderAmpelRow(lane, group, ampel, ampel.id === laneAmpel.id))}
                <Button size="small" startIcon={<AddIcon />} onClick={() => addAmpelToSignalGroup(group)}>
                  Ampel hinzufügen
                </Button>
              </Stack>
            </Stack>
          </Paper>
        );
      }

      function renderLaneCard(lane: IntersectionWizardLaneAppDto) {
        const laneAmpel = selectedLaneAmpel(lane) ?? {
          ...ampelForLane(lane, draft.ampeln.length + 1),
          id: laneAmpelId(lane),
        };
        const defaultGroups = draft.signalGroups.filter((group) => group.laneIds.includes(lane.id));
        const routeGroups = (draft.routeRules ?? [])
          .filter((rule) => rule.laneId === lane.id)
          .flatMap((rule) => rule.signalGroupIds)
          .map((signalGroupId) => draft.signalGroups.find((group) => group.id === signalGroupId))
          .filter((group): group is IntersectionWizardSignalGroupAppDto => Boolean(group));
        const panelsVisible = routeGroups.length > 0 || defaultGroups.length > 1;
        const simpleGroup = defaultGroups[0];
        const laneSignalGroup = defaultGroups[0] ?? routeGroups[0];

        return (
          <Paper key={lane.id} variant="outlined" sx={{ p: 1.5, borderRadius: 2, bgcolor: 'background.paper' }}>
            <Stack spacing={1.5}>
              <Stack direction="row" spacing={1} alignItems="center">
                <Box sx={cardTitleIconSx}>
                  <DirectionsCarIcon fontSize="medium" />
                </Box>
                <Typography variant="h5" sx={{ flex: 1, lineHeight: 1.2 }}>
                  Signalgruppen für {lane.name}
                </Typography>
                {draft.supportMultipleLaneSignals && (
                  <Button
                    size="small"
                    startIcon={<AddIcon />}
                    title="Ermöglicht Richtungsampeln."
                    onClick={() => addDirectionalPanel(lane)}
                  >
                    Richtungssignale hinzufügen
                  </Button>
                )}
              </Stack>
              <Stack spacing={0.5}>
                <Typography variant="caption" color="text.secondary">
                  Abbiegerichtungen der Fahrspur
                </Typography>
                {renderReadonlyTurnDirections(lane.turnDirections)}
              </Stack>
              {panelsVisible ? (
                <Stack spacing={1.25}>
                  {laneSignalGroup && (
                    <Stack spacing={0.5}>
                      <Typography variant="caption" color="text.secondary">
                        Fahrspur-Ampel
                      </Typography>
                      {renderAmpelRow(lane, laneSignalGroup, laneAmpel, true)}
                    </Stack>
                  )}
                  {defaultGroups.map((group, index) =>
                    renderSignalGroupPanel(lane, group, laneAmpel, index === 0 ? 'standard' : 'route'),
                  )}
                  {routeGroups.map((group) => renderSignalGroupPanel(lane, group, laneAmpel, 'route'))}
                </Stack>
              ) : simpleGroup ? (
                renderSignalGroupPanel(lane, simpleGroup, laneAmpel, 'simple')
              ) : (
                <FeedbackMessage severity="warning">
                  Für diese Fahrspur ist noch keine Signalgruppe angelegt.
                </FeedbackMessage>
              )}
            </Stack>
          </Paper>
        );
      }

      function renderPedestrianSignalRow(
        group: IntersectionWizardSignalGroupAppDto,
        ampel: IntersectionWizardAmpelAppDto,
      ) {
        const sourceOptions = draft.ampeln.filter(
          (entry) =>
            entry.use !== 'PEDESTRIAN_ONLY' && entry.trafficType !== 'PEDESTRIAN' && supportsPedestrianSignal(entry),
        );
        const selectedModelValue = ampel.modelConstant || ampel.modelName;
        const modelOptions =
          selectedModelValue &&
          !trafficLightModelOptions.some(
            (option) => (option.model.luaConstant ?? option.model.name) === selectedModelValue,
          )
            ? [
                {
                  model: {
                    id: selectedModelValue,
                    name: selectedModelValue,
                    luaConstant: selectedModelValue,
                  } as TrafficLightModelAppDto,
                  label: selectedModelValue,
                },
                ...trafficLightModelOptions,
              ]
            : trafficLightModelOptions;
        const ownSignal = ampel.use === 'PEDESTRIAN_ONLY';

        return (
          <Box
            key={ampel.id}
            sx={{
              display: 'grid',
              gap: 1.25,
              gridTemplateColumns: {
                xs: '1fr',
                md: ownSignal
                  ? '5rem minmax(12rem, 1fr) 5rem minmax(13rem, 1fr) 2.5rem'
                  : '5rem minmax(16rem, 1fr) 2.5rem',
              },
              alignItems: 'end',
            }}
          >
            <Stack spacing={0.5}>
              <Typography variant="caption" color="text.secondary">
                Name
              </Typography>
              <TextField
                value={pedestrianDisplayName(ampel)}
                size="small"
                inputProps={{ maxLength: 4, 'aria-label': `Fußgängersignal ${pedestrianDisplayName(ampel)}` }}
                onChange={(event) => updatePedestrianSignalName(group, ampel, event.target.value)}
              />
            </Stack>
            <Stack spacing={0.5}>
              <Typography variant="caption" color="text.secondary">
                Quelle
              </Typography>
              <FormControl size="small" fullWidth>
                <Select
                  value={ownSignal ? '__OWN_PEDESTRIAN_SIGNAL__' : ampel.id}
                  inputProps={{ 'aria-label': `Quelle ${pedestrianDisplayName(ampel)}` }}
                  onChange={(event) => updatePedestrianSignalSource(group, ampel, event.target.value)}
                >
                  <MenuItem value="__OWN_PEDESTRIAN_SIGNAL__">Eigenes Fußgängersignal</MenuItem>
                  {sourceOptions.map((option) => (
                    <MenuItem key={option.id} value={option.id}>
                      {option.name || option.signalId} als Fußgängersignal nutzen
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Stack>
            {ownSignal && (
              <>
                <Stack spacing={0.5}>
                  <Typography variant="caption" color="text.secondary">
                    Signal-ID
                  </Typography>
                  <TextField
                    value={ampel.signalId}
                    size="small"
                    inputProps={{ maxLength: 4, 'aria-label': `Signal-ID ${ampel.name}` }}
                    onChange={(event) => updateAmpel(ampel.id, { signalId: event.target.value })}
                  />
                </Stack>
                <Stack spacing={0.5}>
                  <Typography variant="caption" color="text.secondary">
                    Ampelmodell
                  </Typography>
                  <FormControl size="small" fullWidth>
                    <Select
                      value={selectedModelValue}
                      inputProps={{ 'aria-label': `Ampelmodell ${ampel.name}` }}
                      onChange={(event) => {
                        const value = event.target.value;
                        const option = trafficLightModelOptions.find(
                          (entry) => (entry.model.luaConstant ?? entry.model.name) === value,
                        );
                        updateAmpel(ampel.id, {
                          modelName: option?.model.name ?? value,
                          modelConstant: option?.model.luaConstant ?? value,
                        });
                      }}
                    >
                      {modelOptions.map((option) => {
                        const value = option.model.luaConstant ?? option.model.name;
                        return (
                          <MenuItem key={value} value={value}>
                            {compactTrafficLightModelLabel(option.model)}
                          </MenuItem>
                        );
                      })}
                    </Select>
                  </FormControl>
                </Stack>
              </>
            )}
            <IconButton
              size="small"
              aria-label={`Fußgängersignal ${pedestrianDisplayName(ampel)} löschen`}
              title="Fußgängersignal löschen"
              onClick={() => removePedestrianSignalFromGroup(group, ampel)}
              sx={{
                width: 40,
                height: 40,
                color: 'text.secondary',
                '&:hover': { color: 'error.main', bgcolor: 'error.light' },
              }}
            >
              <DeleteIcon fontSize="small" />
            </IconButton>
          </Box>
        );
      }

      function renderPedestrianCrossingCard(crossing: IntersectionWizardPedestrianCrossingAppDto) {
        const group = draft.signalGroups.find((entry) => entry.id === crossing.signalGroupId);
        if (!group) return null;
        const ampeln = group.ampelIds
          .map((ampelId) => draft.ampeln.find((ampel) => ampel.id === ampelId))
          .filter((ampel): ampel is IntersectionWizardAmpelAppDto => Boolean(ampel));

        return (
          <Paper key={crossing.id} variant="outlined" sx={{ p: 1.5, borderRadius: 2, bgcolor: 'background.paper' }}>
            <Stack spacing={1.5}>
              <Stack direction="row" spacing={1} alignItems="center">
                <Box sx={cardTitleIconSx}>
                  <DirectionsWalkIcon fontSize="medium" />
                </Box>
                <Typography variant="h5" sx={{ flex: 1, lineHeight: 1.2 }}>
                  Signalgruppen für {crossing.name}
                </Typography>
              </Stack>
              <Stack spacing={0.5}>
                <Typography variant="caption" color="text.secondary">
                  {readonlyTitle('Signalgruppe', !signalGroupNamesEditable)}
                </Typography>
                <TextField
                  value={group.name}
                  onChange={(event) => {
                    if (!signalGroupNamesEditable) return;
                    updateSignalGroup(group.id, { name: event.target.value });
                  }}
                  size="small"
                  InputProps={{ readOnly: !signalGroupNamesEditable }}
                  inputProps={{
                    maxLength: 32,
                    readOnly: !signalGroupNamesEditable,
                    'aria-label': `Signalgruppe ${group.name}`,
                  }}
                />
              </Stack>
              <Stack spacing={1}>
                {ampeln.map((ampel) => renderPedestrianSignalRow(group, ampel))}
                <Button size="small" startIcon={<AddIcon />} onClick={() => addPedestrianSignalToGroup(group)}>
                  Fußgängersignal hinzufügen
                </Button>
              </Stack>
            </Stack>
          </Paper>
        );
      }

      return (
        <Stack spacing={2}>
          {lanesByApproach.map(({ approach, lanes, pedestrianCrossings }) => {
            const ApproachIcon = approachIcons[approach];
            return (
              <Paper
                key={approach}
                variant="outlined"
                sx={{ p: 2, borderRadius: 2, bgcolor: approachBackgrounds[approach] }}
              >
                <Stack spacing={1.5}>
                  <Stack direction="row" spacing={1} alignItems="baseline">
                    <ApproachIcon fontSize="small" sx={{ alignSelf: 'center' }} />
                    <Typography variant="h6">Zufahrt aus {approachLabels[approach]}</Typography>
                  </Stack>
                  <Stack spacing={1}>{lanes.map((lane) => renderLaneCard(lane))}</Stack>
                  {pedestrianCrossings.length > 0 && (
                    <Stack spacing={1}>
                      {pedestrianCrossings.map((crossing) => renderPedestrianCrossingCard(crossing))}
                    </Stack>
                  )}
                </Stack>
              </Paper>
            );
          })}
          {routeSignalGroupIds.size > 0 && (
            <Typography variant="body2" color="text.secondary">
              Routenabhängige Fahrregeln werden direkt in den Fahrspur-Panels gepflegt.
            </Typography>
          )}
        </Stack>
      );
    }

    if (activeStep === 4) {
      return (
        <IntersectionWizardPhasePlanStep
          draft={draft}
          createAmpelForLane={ampelForLane}
          laneAmpelId={laneAmpelId}
          selectedLaneAmpel={selectedLaneAmpel}
          onAddPhase={addPhase}
          onDraftPatch={updateDraft}
          onOptionalPositiveNumber={optionalPositiveNumber}
          onRemovePhase={removePhase}
          onTogglePhaseSignalGroup={togglePhaseSignalGroup}
          onUpdatePhase={updatePhase}
        />
      );
    }

    return <IntersectionWizardSummaryStep status={status} />;
  }

  const isSummaryStep = activeStep === steps.length - 1;
  const showCodePreview = (draft.showLuaCodeImmediately ?? true) || isSummaryStep;

  return (
    <PageContainer>
      <PageHeadline>Kreuzung erstellen</PageHeadline>
      {activeStep === 0 ? (
        <Paper sx={{ p: 3, maxWidth: 680 }}>{stepContent()}</Paper>
      ) : (
        <Box
          sx={{
            display: 'grid',
            gridTemplateColumns:
              showCodePreview && !isSummaryStep ? { xs: '1fr', xl: 'minmax(0, 2fr) minmax(360px, 1fr)' } : '1fr',
            gap: 3,
          }}
        >
          <Stack spacing={3} sx={{ minWidth: 0 }}>
            <WizardStepper
              activeStep={activeStep - 1}
              steps={wizardSteps.map((label) => ({ label }))}
              onStepSelect={(index) => void persistAndNavigate(index + 1)}
            />
            {navigationButtons()}
            <Paper sx={{ p: 3 }}>{stepContent()}</Paper>
            {showCodePreview && isSummaryStep && (
              <IntersectionWizardCodePreview
                lua={generatedLua}
                warnings={warnings}
                copyEnabled
                onCopyIntersection={copyIntersectionLua}
                onCopyAll={copyAllLua}
                fullWidth
              />
            )}
            {navigationButtons()}
          </Stack>
          {showCodePreview && !isSummaryStep && (
            <IntersectionWizardCodePreview
              lua={generatedLua}
              warnings={warnings}
              copyEnabled={false}
              onCopyIntersection={copyIntersectionLua}
              onCopyAll={copyAllLua}
            />
          )}
        </Box>
      )}
    </PageContainer>
  );
}

export default IntersectionCreateWizard;
