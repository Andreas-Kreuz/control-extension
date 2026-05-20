import { useCallback, useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import Autocomplete from '@mui/material/Autocomplete';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Checkbox from '@mui/material/Checkbox';
import Chip from '@mui/material/Chip';
import FormControl from '@mui/material/FormControl';
import FormHelperText from '@mui/material/FormHelperText';
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
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import type { SxProps, Theme } from '@mui/material/styles';
import AddIcon from '@mui/icons-material/Add';
import DirectionsCarIcon from '@mui/icons-material/DirectionsCar';
import DirectionsWalkIcon from '@mui/icons-material/DirectionsWalk';
import TrafficIcon from '@mui/icons-material/Traffic';
import TramIcon from '@mui/icons-material/Tram';
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
  IntersectionWizardAmpelKind,
  IntersectionWizardApproach,
  IntersectionWizardDraftAppDto,
  IntersectionWizardGenerateResultAppDto,
  IntersectionWizardLaneAppDto,
  IntersectionWizardLaneSignalAppDto,
  IntersectionWizardPhaseAppDto,
  IntersectionWizardSignalGroupAppDto,
  IntersectionWizardSignalLookupAppDto,
  IntersectionWizardTrafficType,
  IntersectionWizardTurnDirection,
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
import { IconHeadline, IconHeadlineDelete } from '../../../shared/components/headlines';
import {
  Approach,
  ExpandableEditorTableRow,
  FormSelect,
  FormTextfield,
  SignalGroupTrafficLightPreview,
  approachLabels,
  turnDirectionIcons,
  turnDirectionLabels,
  turnDirections,
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

const steps = ['Vorbereitung', 'Kreuzung', 'Ampelgruppen & Ampeln', 'Fahrspuren', 'Ampelphasen', 'Zusammenfassung'];
const stepKeys = ['start', 'kreuzung', 'signalgruppen', 'fahrspuren', 'verkehrsphasen', 'zusammenfassung'] as const;
const wizardSteps = steps.slice(1);
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
const trafficTypes: IntersectionWizardTrafficType[] = ['CAR', 'TRAM', 'PEDESTRIAN'];
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
const signalGroupTurnOrder = {
  LEFT: 0,
  HALF_LEFT: 1,
  STRAIGHT: 2,
  HALF_RIGHT: 3,
  RIGHT: 4,
} satisfies Record<IntersectionWizardTurnDirection, number>;
const trafficTypeLabels = {
  CAR: 'Fahrzeuge',
  TRAM: 'Tram/Bus',
  PEDESTRIAN: 'Fußgänger',
} satisfies Record<IntersectionWizardTrafficType, string>;
const compactTrafficTypeLabels = {
  CAR: 'Auto',
  TRAM: 'ÖPNV',
  PEDESTRIAN: 'Fussg.',
} satisfies Record<IntersectionWizardTrafficType, string>;
const trafficTypeIcons = {
  CAR: DirectionsCarIcon,
  TRAM: TramIcon,
  PEDESTRIAN: DirectionsWalkIcon,
} satisfies Record<IntersectionWizardTrafficType, typeof DirectionsCarIcon>;
const trafficTypeSuffix = {
  CAR: 'Car',
  TRAM: 'Tram',
  PEDESTRIAN: 'Ped',
} satisfies Record<IntersectionWizardTrafficType, string>;
const signalGroupCardLargeQuery = '@container (min-width: 720px)';
const signalGroupCardExtraLargeQuery = '@container (min-width: 1040px)';

type TrafficLightModelOption = { label: string; model: TrafficLightModelAppDto };

const hiddenToggleInfoTextSx = {
  '& .MuiFormHelperText-root': {
    visibility: 'hidden',
  },
  '&:hover .MuiFormHelperText-root, &:focus-within .MuiFormHelperText-root': {
    visibility: 'visible',
  },
};

const signalGroupToggleButtonSx = {
  minHeight: 40,
};

const selectedSignalGroupSx = {
  bgcolor: 'rgba(25, 118, 210, 0.08)',
  '&:hover': {
    bgcolor: 'rgba(25, 118, 210, 0.12)',
  },
};

function CompactToggleField(props: {
  children: ReactNode;
  errorTexts?: string[];
  infoText?: string;
  label: string;
  sx?: SxProps<Theme>;
}) {
  const errorTexts = props.errorTexts ?? [];
  const hasError = errorTexts.length > 0;
  const helperText = hasError ? errorTexts.join(' ') : props.infoText;
  return (
    <Stack
      spacing={0.5}
      sx={[
        !hasError && props.infoText ? hiddenToggleInfoTextSx : {},
        ...(Array.isArray(props.sx) ? props.sx : [props.sx]),
      ]}
    >
      <Typography variant="caption" color={hasError ? 'error' : 'text.secondary'}>
        {props.label}
      </Typography>
      {props.children}
      {helperText && (
        <FormHelperText error={hasError} sx={{ m: 0 }}>
          {helperText}
        </FormHelperText>
      )}
    </Stack>
  );
}

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
    supportStructureLightSignals: false,
    staticCams: [],
    createdAt: now,
    updatedAt: now,
    lanes: [],
    ampeln: [],
    signalGroups: [],
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

function laneLuaDisplayName(lane: IntersectionWizardLaneAppDto, index: number, intersectionPrefix: string) {
  if (lane.luaVariableName?.trim()) return sanitizeLuaIdentifier(lane.luaVariableName, `lane${index + 1}`);
  const numberedLane = /^(?:lane|spur|fahrstreifen|fs)\s*(\d+[a-z]?)$/i.exec(lane.name.trim());
  if (numberedLane) {
    return `${lowerFirst(sanitizeLuaIdentifier(intersectionPrefix, 'kreuzung'))}Lane${numberedLane[1]}`;
  }
  return lowerFirst(sanitizeLuaIdentifier(lane.name, `lane${index + 1}`));
}

function route(path: string, socketUrl: string) {
  return new URL(`/api/v1/road/intersection-wizard${path}`, socketUrl);
}

function stepIndexFromKey(stepKey: string | undefined): number {
  if (stepKey === 'ampeln') return stepKeys.findIndex((candidate) => candidate === 'signalgruppen');
  const index = stepKeys.findIndex((candidate) => candidate === stepKey);
  return index >= 0 ? index : 0;
}

function optionalPositiveNumber(value: string): number | undefined {
  if (!value.trim()) return undefined;
  const numeric = Number(value);
  return Number.isFinite(numeric) && numeric > 0 ? numeric : undefined;
}

function firstFreeCxName(existingNames: string[]) {
  const usedNumbers = new Set(
    existingNames
      .map((name) => /^c(\d+)$/i.exec(name.trim())?.[1])
      .filter((value): value is string => Boolean(value))
      .map(Number),
  );
  let nextNumber = 1;
  while (usedNumbers.has(nextNumber)) nextNumber += 1;
  return `c${nextNumber}`;
}

function signalGroupName(
  approach: IntersectionWizardApproach,
  trafficType: IntersectionWizardTrafficType,
  directions: IntersectionWizardTurnDirection[],
) {
  const directionSuffix =
    trafficType === 'PEDESTRIAN'
      ? ''
      : orderTurnDirections(directions)
          .map((direction) => signalGroupTurnSuffix[direction])
          .join('');
  return `sg${approachNameSuffix[approach]}${trafficTypeSuffix[trafficType]}${directionSuffix}`;
}

function orderTurnDirections(directions: IntersectionWizardTurnDirection[]) {
  return [...directions].sort((a, b) => signalGroupTurnOrder[a] - signalGroupTurnOrder[b]);
}

function uniqueId(prefix: string, usedIds: string[]) {
  const used = new Set(usedIds);
  let index = usedIds.length + 1;
  while (used.has(`${prefix}-${index}`)) index += 1;
  return `${prefix}-${index}`;
}

function defaultPhases(): IntersectionWizardPhaseAppDto[] {
  return [
    { id: 'phase-1', name: 'P1', signalGroupIds: [] },
    { id: 'phase-2', name: 'P2', signalGroupIds: [] },
  ];
}

function defaultModelForType(type: IntersectionWizardTrafficType) {
  if (type === 'TRAM') return { modelName: 'MA1_STRAB_3er_2_gruen', modelConstant: 'MA1_STRAB_3er_2_gruen' };
  if (type === 'PEDESTRIAN') return { modelName: 'JS2_2er_nur_FG', modelConstant: 'JS2_2er_nur_FG' };
  return { modelName: 'Ampel_3er_XXX_mit_FG', modelConstant: 'JS2_3er_mit_FG' };
}

function isStructureLightAmpel(ampel: IntersectionWizardAmpelAppDto) {
  return ampel.kind === 'STRUCTURE_LIGHT' || (!ampel.signalId?.trim() && (ampel.lightStructures ?? []).length > 0);
}

function emptyLaneSignal(name: string): IntersectionWizardLaneSignalAppDto {
  return { name, modelName: 'Unsichtbar_2er', modelConstant: 'Unsichtbar_2er', lightStructures: [] };
}

function compactTrafficLightModelLabel(model: TrafficLightModelAppDto): string {
  return model.luaConstant ?? model.name;
}

function compactStructureName(name: string | undefined): string {
  const firstPart = (name ?? '').trim().split('_')[0];
  const numberPart = /#\d+/.exec(firstPart)?.[0];
  return numberPart ?? (firstPart || '-');
}

function signalGroupSummary(group: IntersectionWizardSignalGroupAppDto) {
  const trafficType = group.trafficType === 'CAR' ? 'Auto' : trafficTypeLabels[group.trafficType];
  const directionText =
    group.trafficType === 'PEDESTRIAN'
      ? undefined
      : orderTurnDirections(group.turnDirections)
          .map((direction) => turnDirectionLabels[direction])
          .join(', ');
  return ['Schaltet gemeinsam', approachLabels[group.approach], trafficType, directionText].filter(Boolean).join(' · ');
}

function WizardSectionTitle(props: { children: ReactNode; helper: string }) {
  return (
    <Stack spacing={0.25}>
      <Typography variant="subtitle2">{props.children}</Typography>
      <Typography variant="caption" color="text.secondary">
        {props.helper}
      </Typography>
    </Stack>
  );
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
  const [freeSlots, setFreeSlots] = useState<DataSlotAppDto[]>([]);
  const [routeOptions, setRouteOptions] = useState<string[]>([]);
  const [scenarioStaticCameras, setScenarioStaticCameras] = useState<string[]>([]);
  const [scenarioIntersectionNames, setScenarioIntersectionNames] = useState<string[]>([]);
  const [trafficLightModels, setTrafficLightModels] = useState<Record<string, TrafficLightModelAppDto>>({});
  const [showAdvancedIntersectionSettings, setShowAdvancedIntersectionSettings] = useState(false);
  const [sendPreparationSettings, setSendPreparationSettings] = useState(true);
  const [expandedAmpelId, setExpandedAmpelId] = useState('');
  const draftIdFromUrl = searchParams.get('draftId') ?? '';
  const intersectionIdFromUrl = searchParams.get('intersectionId') ?? '';
  const roadPathPrefix = location.pathname.startsWith('/simple/road')
    ? '/simple/road'
    : location.pathname.startsWith('/old/road')
      ? '/old/road'
      : '/road';

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
  const updateDraft = useCallback((patch: Partial<IntersectionWizardDraftAppDto>) => {
    setDraft((current) => ({ ...current, ...patch, updatedAt: new Date().toISOString() }));
  }, []);

  useApiDataRoomHandler(CeTypes.HubRoute, (payload: string) => {
    const data = JSON.parse(payload) as Record<string, Partial<RouteAppDto>>;
    setRouteOptions((current) =>
      Array.from(
        new Set([
          ...current,
          ...Object.values(data)
            .map((routeEntry) => routeEntry.name)
            .filter((routeName): routeName is string => Boolean(routeName?.trim())),
        ]),
      ).sort((a, b) => a.localeCompare(b, undefined, { numeric: true })),
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
    setRouteOptions((current) =>
      Array.from(
        new Set([
          ...current,
          ...Object.values(data)
            .map((train) => train.route)
            .filter(Boolean),
        ]),
      ).sort(),
    );
  });
  useDomainRoomHandler(TrainListRoom, TrackType.Tram, (payload: string) => {
    const data = JSON.parse(payload) as Record<string, TrainListAppDto>;
    setRouteOptions((current) =>
      Array.from(
        new Set([
          ...current,
          ...Object.values(data)
            .map((train) => train.route)
            .filter(Boolean),
        ]),
      ).sort(),
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
          setLoadedIntersectionId(intersectionId);
          navigateToStep(1, { draftId: loaded.id, removeIntersectionId: true, replace: true });
          return;
        }
      } catch (_error) {
        // Retry below; this request can race the test server startup.
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
      const saved = await persistDraft(draft);
      if (!saved) return;
      setLoadedDraftId(saved.id);
      if (draftIdFromUrl !== saved.id) {
        navigateToStep(activeStep, { draftId: saved.id, removeIntersectionId: true, replace: true });
      }
    }, 600);
    return () => window.clearTimeout(timer);
  }, [activeStep, draft, draftIdFromUrl, intersectionIdFromUrl, loadedDraftId, navigateToStep, persistDraft]);

  useEffect(() => {
    if (activeStep !== 4 || draft.phases.length > 0) return;
    updateDraft({ phases: defaultPhases() });
  }, [activeStep, draft.phases.length, updateDraft]);

  async function lookupSignal(signalId: string): Promise<IntersectionWizardSignalLookupAppDto | undefined> {
    if (!signalId.trim()) return undefined;
    const response = await fetch(route(`/signals/${encodeURIComponent(signalId.trim())}`, socketUrl));
    if (!response.ok) return undefined;
    return (await response.json()) as IntersectionWizardSignalLookupAppDto;
  }

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

  function nextAmpelName(type: IntersectionWizardTrafficType) {
    const prefix = type === 'TRAM' ? 'S' : type === 'PEDESTRIAN' ? 'F' : 'K';
    const usedNumbers = draft.ampeln
      .map((ampel) => new RegExp(`^${prefix}(\\d+)$`, 'i').exec(ampel.name.trim())?.[1])
      .filter((value): value is string => Boolean(value))
      .map(Number);
    return `${prefix}${usedNumbers.length > 0 ? Math.max(...usedNumbers) + 1 : 1}`;
  }

  function createAmpel(
    type: IntersectionWizardTrafficType,
    name = nextAmpelName(type),
    kind: IntersectionWizardAmpelKind = 'SIGNAL',
  ): IntersectionWizardAmpelAppDto {
    return {
      id: `ampel-${Date.now()}-${name}-${Math.random().toString(16).slice(2)}`,
      name,
      kind,
      use: type === 'PEDESTRIAN' ? 'PEDESTRIAN_ONLY' : 'VEHICLE_ONLY',
      trafficType: type,
      ...(kind === 'SIGNAL' ? defaultModelForType(type) : { modelName: 'NONE', modelConstant: 'NONE' }),
      lightStructures: kind === 'STRUCTURE_LIGHT' ? [{}] : [],
      axisStructures: [],
    };
  }

  function addSignalGroup() {
    const approach: IntersectionWizardApproach = 'SOUTH';
    const trafficType: IntersectionWizardTrafficType = 'CAR';
    const groupId = uniqueId(
      'sg',
      draft.signalGroups.map((group) => group.id),
    );
    const ampel = createAmpel(trafficType);
    const group: IntersectionWizardSignalGroupAppDto = {
      id: groupId,
      name: signalGroupName(approach, trafficType, ['STRAIGHT']),
      approach,
      trafficType,
      turnDirections: ['STRAIGHT'],
      showRequests: false,
      ampelIds: [ampel.id],
    };
    updateDraft({ ampeln: [...draft.ampeln, ampel], signalGroups: [...draft.signalGroups, group] });
  }

  function patchSignalGroup(id: string, patch: Partial<IntersectionWizardSignalGroupAppDto>) {
    const group = draft.signalGroups.find((entry) => entry.id === id);
    if (!group) return;
    const nextGroup = { ...group, ...patch };
    nextGroup.turnDirections =
      nextGroup.trafficType === 'PEDESTRIAN'
        ? []
        : nextGroup.turnDirections.length > 0
          ? nextGroup.turnDirections
          : ['STRAIGHT'];
    nextGroup.name = signalGroupName(nextGroup.approach, nextGroup.trafficType, nextGroup.turnDirections);
    let nextAmpeln = draft.ampeln;
    let ampelIds = nextGroup.ampelIds;
    if (group.trafficType !== nextGroup.trafficType && ampelIds.length === 0) {
      const first = createAmpel(nextGroup.trafficType);
      nextAmpeln = [...nextAmpeln, first];
      ampelIds = [first.id];
    }
    if (nextGroup.trafficType === 'PEDESTRIAN' && ampelIds.length < 2) {
      const missing = Array.from({ length: 2 - ampelIds.length }).map(() => createAmpel('PEDESTRIAN'));
      nextAmpeln = [...nextAmpeln, ...missing];
      ampelIds = [...ampelIds, ...missing.map((ampel) => ampel.id)];
    }
    updateDraft({
      ampeln: nextAmpeln,
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === id ? { ...nextGroup, ampelIds, pedestrianCrossingName: nextGroup.pedestrianCrossingName } : entry,
      ),
    });
  }

  function removeSignalGroup(id: string) {
    const removed = draft.signalGroups.find((group) => group.id === id);
    const removedAmpelIds = removed?.ampelIds ?? [];
    updateDraft({
      signalGroups: draft.signalGroups.filter((group) => group.id !== id),
      ampeln: draft.ampeln.filter((ampel) => !removedAmpelIds.includes(ampel.id)),
      lanes: draft.lanes.map((lane) => ({
        ...lane,
        signalGroupSignalId: lane.signalGroupSignalId === id ? undefined : lane.signalGroupSignalId,
        signalGroupAssignments: lane.signalGroupAssignments.filter((assignment) => assignment.signalGroupId !== id),
      })),
      phases: draft.phases.map((phase) => ({
        ...phase,
        signalGroupIds: phase.signalGroupIds.filter((signalGroupId) => signalGroupId !== id),
      })),
    });
  }

  function patchAmpel(id: string, patch: Partial<IntersectionWizardAmpelAppDto>) {
    updateDraft({ ampeln: draft.ampeln.map((ampel) => (ampel.id === id ? { ...ampel, ...patch } : ampel)) });
  }

  async function updateAmpelSignalId(ampel: IntersectionWizardAmpelAppDto, signalId: string) {
    patchAmpel(ampel.id, { signalId });
    const lookup = await lookupSignal(signalId);
    if (!lookup?.suggestedTrafficLightModel && !lookup?.suggestedTrafficLightModelConstant) return;
    patchAmpel(ampel.id, {
      ...(lookup.suggestedTrafficLightModel ? { modelName: lookup.suggestedTrafficLightModel } : {}),
      ...(lookup.suggestedTrafficLightModelConstant
        ? { modelConstant: lookup.suggestedTrafficLightModelConstant }
        : {}),
    });
  }

  function addAmpelToGroup(group: IntersectionWizardSignalGroupAppDto) {
    const ampel = createAmpel(group.trafficType, nextAmpelName(group.trafficType), 'SIGNAL');
    setExpandedAmpelId(ampel.id);
    updateDraft({
      ampeln: [...draft.ampeln, ampel],
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === group.id ? { ...entry, ampelIds: [...entry.ampelIds, ampel.id] } : entry,
      ),
    });
  }

  function addStructureLightToGroup(group: IntersectionWizardSignalGroupAppDto) {
    const baseName = `${nextAmpelName(group.trafficType)}Light`;
    const ampel = createAmpel(group.trafficType, baseName, 'STRUCTURE_LIGHT');
    setExpandedAmpelId(ampel.id);
    updateDraft({
      ampeln: [...draft.ampeln, ampel],
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === group.id ? { ...entry, ampelIds: [...entry.ampelIds, ampel.id] } : entry,
      ),
    });
  }

  function removeAmpelFromGroup(group: IntersectionWizardSignalGroupAppDto, ampelId: string) {
    if (group.ampelIds.length <= 1) return;
    updateDraft({
      ampeln: draft.ampeln.filter((ampel) => ampel.id !== ampelId),
      signalGroups: draft.signalGroups.map((entry) =>
        entry.id === group.id ? { ...entry, ampelIds: entry.ampelIds.filter((id) => id !== ampelId) } : entry,
      ),
    });
  }

  function updateAmpelLightStructure(
    ampel: IntersectionWizardAmpelAppDto,
    key: 'structureRed' | 'structureGreen' | 'structureYellow' | 'structureRequest',
    value: string,
  ) {
    const structure = { ...(ampel.lightStructures?.[0] ?? {}), [key]: value };
    patchAmpel(ampel.id, { lightStructures: [structure] });
  }

  function addLane() {
    const approach = draft.signalGroups.find((group) => group.trafficType !== 'PEDESTRIAN')?.approach ?? 'SOUTH';
    const signalGroupsForApproach = draft.signalGroups.filter(
      (group) => group.trafficType !== 'PEDESTRIAN' && group.approach === approach,
    );
    const laneNr = draft.lanes.length + 1;
    const lane: IntersectionWizardLaneAppDto = {
      id: uniqueId(
        'lane',
        draft.lanes.map((entry) => entry.id),
      ),
      name: `FS${laneNr}`,
      approach,
      signalSource: 'OWN',
      signal: emptyLaneSignal(`lane${laneNr}Sig`),
      signalGroupAssignments:
        signalGroupsForApproach.length === 1 ? [{ signalGroupId: signalGroupsForApproach[0].id, mode: 'DEFAULT' }] : [],
    };
    updateDraft({ lanes: [...draft.lanes, lane] });
  }

  function patchLane(id: string, patch: Partial<IntersectionWizardLaneAppDto>) {
    updateDraft({ lanes: draft.lanes.map((lane) => (lane.id === id ? { ...lane, ...patch } : lane)) });
  }

  function removeLane(id: string) {
    updateDraft({ lanes: draft.lanes.filter((lane) => lane.id !== id) });
  }

  function setLaneAssignment(lane: IntersectionWizardLaneAppDto, groupId: string, selected: boolean) {
    const current = lane.signalGroupAssignments.filter((assignment) => assignment.signalGroupId !== groupId);
    patchLane(lane.id, {
      signalGroupAssignments: selected ? [...current, { signalGroupId: groupId, mode: 'DEFAULT' }] : current,
    });
  }

  function patchLaneAssignment(
    lane: IntersectionWizardLaneAppDto,
    groupId: string,
    patch: Partial<IntersectionWizardLaneAppDto['signalGroupAssignments'][number]>,
  ) {
    patchLane(lane.id, {
      signalGroupAssignments: lane.signalGroupAssignments.map((assignment) =>
        assignment.signalGroupId === groupId ? { ...assignment, ...patch } : assignment,
      ),
    });
  }

  function availableSignalGroupsForLane(lane: IntersectionWizardLaneAppDto) {
    return draft.signalGroups.filter((group) => group.trafficType !== 'PEDESTRIAN' && group.approach === lane.approach);
  }

  function signalGroupAmpelNames(group: IntersectionWizardSignalGroupAppDto) {
    return group.ampelIds
      .map((ampelId) => draft.ampeln.find((ampel) => ampel.id === ampelId)?.name)
      .filter(Boolean)
      .join(', ');
  }

  function addPhase() {
    const id = uniqueId(
      'phase',
      draft.phases.map((phase) => phase.id),
    );
    updateDraft({ phases: [...draft.phases, { id, name: `P${draft.phases.length + 1}`, signalGroupIds: [] }] });
  }

  function removePhase(id: string) {
    updateDraft({ phases: draft.phases.filter((phase) => phase.id !== id) });
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
    if (activeStep === 3 && draft.lanes.length === 0) return;
    let nextDraft = draft;
    if (activeStep === 3 && draft.phases.length === 0) {
      nextDraft = { ...nextDraft, phases: defaultPhases(), updatedAt: new Date().toISOString() };
      setDraft(nextDraft);
    }
    void persistAndNavigate(Math.min(activeStep + 1, steps.length - 1), nextDraft);
  }

  function navigationButtons() {
    const nextDisabled = activeStep === steps.length - 1 || (activeStep === 3 && draft.lanes.length === 0);
    return (
      <IntersectionWizardNavigation
        activeStep={activeStep}
        nextDisabled={nextDisabled}
        onBack={() => void persistAndNavigate(Math.max(activeStep - 1, 0))}
        onNext={goToNextStep}
      />
    );
  }

  function startNewIntersection() {
    if (sendPreparationSettings) sendRoadModulePreparationSettings();
    const defaultCxName = firstFreeCxName(scenarioIntersectionNames);
    const draftToStart =
      draft.name.trim() || draft.luaVariableName !== 'kreuzung'
        ? draft
        : { ...draft, name: defaultCxName, luaVariableName: defaultCxName };
    if (draftToStart !== draft) setDraft(draftToStart);
    void persistAndNavigate(1, draftToStart);
  }

  function copyAllLua() {
    if (!generatedLua || activeStep !== steps.length - 1) return;
    void navigator.clipboard.writeText(generatedLua);
    setStatus('Vollständiger Lua-Code kopiert.');
  }

  function copyIntersectionLua() {
    if (!generatedLua || activeStep !== steps.length - 1) return;
    void navigator.clipboard.writeText(intersectionLuaBlock(generatedLua));
    setStatus('Kreuzungscode kopiert.');
  }

  function modelSelectValue(model: Pick<IntersectionWizardAmpelAppDto, 'modelConstant' | 'modelName'>) {
    return model.modelConstant || model.modelName;
  }

  function modelOptionsWithSelected(selectedModelValue: string) {
    if (
      selectedModelValue &&
      !trafficLightModelOptions.some((option) => (option.model.luaConstant ?? option.model.name) === selectedModelValue)
    ) {
      return [
        {
          model: { id: selectedModelValue, name: selectedModelValue, luaConstant: selectedModelValue },
          label: selectedModelValue,
        } as TrafficLightModelOption,
        ...trafficLightModelOptions,
      ];
    }
    return trafficLightModelOptions;
  }

  function toggleExpandedAmpel(ampelId: string) {
    setExpandedAmpelId((current) => (current === ampelId ? '' : ampelId));
  }

  function sourceSignalOptions(group: IntersectionWizardSignalGroupAppDto, ampel: IntersectionWizardAmpelAppDto) {
    const sameApproachAmpeln = draft.signalGroups
      .filter((entry) => entry.approach === group.approach)
      .flatMap((entry) => entry.ampelIds)
      .map((ampelId) => draft.ampeln.find((entry) => entry.id === ampelId))
      .filter((entry): entry is IntersectionWizardAmpelAppDto =>
        Boolean(entry && entry.id !== ampel.id && !isStructureLightAmpel(entry)),
      );
    if (!ampel.sourceAmpelId || sameApproachAmpeln.some((entry) => entry.id === ampel.sourceAmpelId)) {
      return sameApproachAmpeln;
    }
    const selected = draft.ampeln.find((entry) => entry.id === ampel.sourceAmpelId);
    return selected && !isStructureLightAmpel(selected) ? [selected, ...sameApproachAmpeln] : sameApproachAmpeln;
  }

  function renderTurnDirectionToggle(group: IntersectionWizardSignalGroupAppDto, sx?: SxProps<Theme>) {
    function toggleTurnDirection(turnDirection: IntersectionWizardTurnDirection) {
      const nextTurns = group.turnDirections.includes(turnDirection)
        ? group.turnDirections.filter((selectedTurnDirection) => selectedTurnDirection !== turnDirection)
        : [...group.turnDirections, turnDirection];
      patchSignalGroup(group.id, {
        turnDirections: nextTurns.length > 0 ? orderTurnDirections(nextTurns) : ['STRAIGHT'],
      });
    }

    return (
      <CompactToggleField
        label="Abbiegerichtungen"
        infoText="Diese Abbiegerichtungen gelten für die Ampelgruppe."
        sx={
          sx ?? {
            gridColumn: '1',
            [signalGroupCardLargeQuery]: {
              gridColumn: '5 / span 4',
              gridRow: '2',
            },
            [signalGroupCardExtraLargeQuery]: {
              gridColumn: '7 / span 3',
              gridRow: '1',
            },
          }
        }
      >
        <ToggleButtonGroup value={group.turnDirections} size="small">
          {turnDirections.map((turnDirection) => {
            const TurnDirectionIcon = turnDirectionIcons[turnDirection];
            return (
              <ToggleButton
                key={turnDirection}
                value={turnDirection}
                aria-label={turnDirectionLabels[turnDirection]}
                title={turnDirectionLabels[turnDirection]}
                onClick={() => toggleTurnDirection(turnDirection)}
                sx={{
                  ...signalGroupToggleButtonSx,
                  '&.Mui-selected, &.Mui-selected:hover': {
                    bgcolor: 'primary.main',
                    borderColor: 'primary.main',
                    color: 'primary.contrastText',
                  },
                }}
              >
                <TurnDirectionIcon fontSize="small" />
              </ToggleButton>
            );
          })}
        </ToggleButtonGroup>
      </CompactToggleField>
    );
  }

  function renderSignalAmpelEditor(group: IntersectionWizardSignalGroupAppDto, ampel: IntersectionWizardAmpelAppDto) {
    const selectedModelValue = modelSelectValue(ampel);
    const options = modelOptionsWithSelected(selectedModelValue);
    const sourceOptions = sourceSignalOptions(group, ampel);
    return (
      <Stack spacing={1.25} sx={{ pt: 3, pb: 1.5, maxWidth: 720 }}>
        <FormTextfield
          label="Name"
          value={ampel.name}
          size="small"
          infoText="Lua-Variablenname der Ampel."
          inputProps={{ maxLength: 8, 'aria-label': `Ampelname ${ampel.name}` }}
          onChange={(event) => patchAmpel(ampel.id, { name: event.target.value })}
        />
        {group.trafficType === 'PEDESTRIAN' && (
          <CompactToggleField
            label="Signal definieren"
            infoText="Vorhandene Ampeln mit Fußgängersignalen wiederverwenden"
          >
            <FormControl size="small" fullWidth>
              <Select
                value={ampel.sourceAmpelId ?? '__OWN__'}
                inputProps={{ 'aria-label': `Quelle ${ampel.name}` }}
                onChange={(event) =>
                  patchAmpel(ampel.id, {
                    sourceAmpelId: event.target.value === '__OWN__' ? undefined : event.target.value,
                  })
                }
              >
                <MenuItem value="__OWN__">Eigenes Signal</MenuItem>
                {sourceOptions.map((option) => (
                  <MenuItem key={option.id} value={option.id}>
                    {option.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </CompactToggleField>
        )}
        <FormTextfield
          label="Signal-ID"
          value={ampel.signalId ?? ''}
          size="small"
          infoText="Positive EEP-Signal-ID."
          inputProps={{ inputMode: 'numeric', 'aria-label': `Signal-ID ${ampel.name}` }}
          onBlur={(event) => void updateAmpelSignalId(ampel, event.target.value)}
          onChange={(event) => patchAmpel(ampel.id, { signalId: event.target.value })}
        />
        <CompactToggleField label="Signal-Modell" infoText="Notwendig für die Anzeige von rot, gelb, grün, usw.">
          <FormControl size="small" fullWidth>
            <Select
              value={selectedModelValue}
              inputProps={{ 'aria-label': `Signal-Modell ${ampel.name}` }}
              onChange={(event) => {
                const value = event.target.value;
                const option = options.find((entry) => (entry.model.luaConstant ?? entry.model.name) === value);
                patchAmpel(ampel.id, {
                  modelName: option?.model.name ?? value,
                  modelConstant: option?.model.luaConstant ?? value,
                });
              }}
            >
              {options.map((option) => {
                const value = option.model.luaConstant ?? option.model.name;
                return (
                  <MenuItem key={value} value={value}>
                    {compactTrafficLightModelLabel(option.model)}
                  </MenuItem>
                );
              })}
            </Select>
          </FormControl>
        </CompactToggleField>
      </Stack>
    );
  }

  function renderStructureAmpelEditor(ampel: IntersectionWizardAmpelAppDto) {
    return (
      <Stack spacing={1.25} sx={{ mt: 1, py: 1.5, maxWidth: 720 }}>
        <FormTextfield
          label="Name"
          value={ampel.name}
          size="small"
          infoText="Lua-Variablenname der Immobilien-Ampel."
          inputProps={{ maxLength: 16, 'aria-label': `Ampelname ${ampel.name}` }}
          onChange={(event) => patchAmpel(ampel.id, { name: event.target.value })}
        />
        {(['structureRed', 'structureYellow', 'structureGreen', 'structureRequest'] as const).map((key) => (
          <FormTextfield
            key={key}
            label={
              key === 'structureRed'
                ? 'Immobilie-Rot'
                : key === 'structureYellow'
                  ? 'Immobilie-Gelb (optional)'
                  : key === 'structureGreen'
                    ? 'Immobilie-Grün'
                    : 'Immobilie-Anforderung (optional)'
            }
            value={ampel.lightStructures?.[0]?.[key] ?? ''}
            size="small"
            infoText="Vollständiger Immobilienname des gesteuerten Lichts."
            onChange={(event) => updateAmpelLightStructure(ampel, key, event.target.value)}
          />
        ))}
      </Stack>
    );
  }

  function renderSignalAmpelTable(group: IntersectionWizardSignalGroupAppDto, ampeln: IntersectionWizardAmpelAppDto[]) {
    return (
      <Stack spacing={1} sx={{ gridColumn: '1 / -1', minWidth: 0 }}>
        <Stack direction="row" spacing={1} alignItems="center">
          <WizardSectionTitle helper="Füge alle gleichzeitig zu schaltende Ampeln dieser Richtung hinzu.">
            {group.trafficType === 'PEDESTRIAN' ? 'Fußgängerampeln aus EEP' : 'Ampeln aus EEP'}
          </WizardSectionTitle>
          <Box sx={{ flex: 1 }} />
          <Button size="small" startIcon={<AddIcon />} onClick={() => addAmpelToGroup(group)}>
            {group.trafficType === 'PEDESTRIAN' ? 'EEP-Fußgängerampel hinzufügen' : 'EEP-Ampel hinzufügen'}
          </Button>
        </Stack>
        <TableContainer component={Box} sx={{ border: 1, borderColor: 'divider', borderRadius: 1 }}>
          <Table size="small" aria-label={`Ampeln aus EEP für ${group.name}`}>
            <TableHead>
              <TableRow>
                <TableCell sx={{ width: 56 }} />
                <TableCell>Name</TableCell>
                <TableCell>Signal-ID</TableCell>
                <TableCell>Signal-Model</TableCell>
                <TableCell align="right" sx={{ width: 56 }} />
              </TableRow>
            </TableHead>
            <TableBody>
              {ampeln.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} sx={{ color: 'text.secondary' }}>
                    Noch keine EEP-Ampel hinzugefügt.
                  </TableCell>
                </TableRow>
              ) : (
                ampeln.map((ampel) => (
                  <ExpandableEditorTableRow
                    key={ampel.id}
                    ariaLabel={ampel.name}
                    expanded={expandedAmpelId === ampel.id}
                    dataCellCount={3}
                    deletable={group.ampelIds.length > 1}
                    editor={renderSignalAmpelEditor(group, ampel)}
                    onDelete={() => removeAmpelFromGroup(group, ampel.id)}
                    onToggle={() => toggleExpandedAmpel(ampel.id)}
                  >
                    <TableCell>{ampel.name || '-'}</TableCell>
                    <TableCell>{ampel.signalId || '-'}</TableCell>
                    <TableCell>{modelSelectValue(ampel) || '-'}</TableCell>
                  </ExpandableEditorTableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Stack>
    );
  }

  function renderStructureAmpelTable(
    group: IntersectionWizardSignalGroupAppDto,
    ampeln: IntersectionWizardAmpelAppDto[],
  ) {
    if (group.trafficType === 'PEDESTRIAN') return null;
    return (
      <Stack spacing={1} sx={{ gridColumn: '1 / -1', minWidth: 0 }}>
        <Stack direction="row" spacing={1} alignItems="center">
          <WizardSectionTitle helper="Füge alle Immobilien-Ampeln hinzu, die gemeinsam mit dieser Ampelgruppe schalten sollen.">
            Immobilien-Ampeln aus EEP
          </WizardSectionTitle>
          <Box sx={{ flex: 1 }} />
          <Button size="small" startIcon={<AddIcon />} onClick={() => addStructureLightToGroup(group)}>
            EEP-Immobilien-Ampel hinzufügen
          </Button>
        </Stack>
        <TableContainer component={Box} sx={{ border: 1, borderColor: 'divider', borderRadius: 1 }}>
          <Table size="small" aria-label={`Immobilien-Ampeln aus EEP für ${group.name}`}>
            <TableHead>
              <TableRow>
                <TableCell sx={{ width: 56 }} />
                <TableCell>Name</TableCell>
                <TableCell>Immo-Rot</TableCell>
                <TableCell>Immo-Gelb</TableCell>
                <TableCell>Immo-Grün</TableCell>
                <TableCell>Immo-Anforderung</TableCell>
                <TableCell align="right" sx={{ width: 56 }} />
              </TableRow>
            </TableHead>
            <TableBody>
              {ampeln.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} sx={{ color: 'text.secondary' }}>
                    Noch keine EEP-Immobilien-Ampel hinzugefügt.
                  </TableCell>
                </TableRow>
              ) : (
                ampeln.map((ampel) => {
                  const structure = ampel.lightStructures?.[0];
                  return (
                    <ExpandableEditorTableRow
                      key={ampel.id}
                      ariaLabel={ampel.name}
                      expanded={expandedAmpelId === ampel.id}
                      dataCellCount={5}
                      deletable={group.ampelIds.length > 1}
                      editor={renderStructureAmpelEditor(ampel)}
                      onDelete={() => removeAmpelFromGroup(group, ampel.id)}
                      onToggle={() => toggleExpandedAmpel(ampel.id)}
                    >
                      <TableCell>{ampel.name || '-'}</TableCell>
                      <TableCell>{compactStructureName(structure?.structureRed)}</TableCell>
                      <TableCell>{compactStructureName(structure?.structureYellow)}</TableCell>
                      <TableCell>{compactStructureName(structure?.structureGreen)}</TableCell>
                      <TableCell>{compactStructureName(structure?.structureRequest)}</TableCell>
                    </ExpandableEditorTableRow>
                  );
                })
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Stack>
    );
  }

  function renderSignalGroupsStep() {
    const supportsPedestrianSignals =
      (draft.supportPedestrianSignals ?? false) ||
      draft.signalGroups.some((group) => group.trafficType === 'PEDESTRIAN');
    const supportsStructureLightSignals =
      (draft.supportStructureLightSignals ?? false) || draft.ampeln.some(isStructureLightAmpel);
    return (
      <Stack spacing={2}>
        <Stack direction="row" spacing={1} alignItems="center">
          <IconHeadline text="Ampelgruppen" variant="h6" />
        </Stack>
        {draft.signalGroups.length === 0 && (
          <FeedbackMessage severity="info">Lege mindestens eine Ampelgruppe an.</FeedbackMessage>
        )}
        <Stack spacing={2} sx={{ bgcolor: 'grey.50', p: 1.5, borderRadius: 1 }}>
          {draft.signalGroups.map((group) => {
            const selectableTrafficTypes = trafficTypes.filter(
              (type) => type !== 'PEDESTRIAN' || supportsPedestrianSignals,
            );
            const groupAmpeln = group.ampelIds
              .map((ampelId) => draft.ampeln.find((ampel) => ampel.id === ampelId))
              .filter((ampel): ampel is IntersectionWizardAmpelAppDto => Boolean(ampel));
            const signalAmpeln = groupAmpeln.filter((ampel) => !isStructureLightAmpel(ampel));
            const structureAmpeln = groupAmpeln.filter(isStructureLightAmpel);
            return (
              <Paper
                key={group.id}
                variant="outlined"
                sx={{
                  p: 2,
                  minWidth: 0,
                  overflow: 'hidden',
                  bgcolor: 'background.paper',
                  borderColor: 'grey.300',
                  boxShadow: '0 1px 2px rgba(15, 23, 42, 0.06)',
                  containerType: 'inline-size',
                }}
              >
                <Stack spacing={1.5}>
                  <IconHeadlineDelete
                    text={`Ampelgruppe ${group.name}`}
                    icon={<TrafficIcon />}
                    variant="h6"
                    subText={signalGroupSummary(group)}
                    ariaLabel={`Ampelgruppe ${group.name} löschen`}
                    onDelete={() => removeSignalGroup(group.id)}
                  />
                  <Stack spacing={2} sx={{ mt: 0.5 }}>
                    <WizardSectionTitle helper="Diese Angaben gelten für alle Ampeln in dieser Gruppe.">
                      Standort und Gültigkeit
                    </WizardSectionTitle>
                    <Box
                      sx={{
                        display: 'grid',
                        gridTemplateColumns: '1fr',
                        gap: 1.5,
                        minWidth: 0,
                        [signalGroupCardLargeQuery]: {
                          gridTemplateColumns: 'repeat(12, minmax(0, 1fr))',
                        },
                      }}
                    >
                      <Stack
                        spacing={0.5}
                        sx={{
                          ...hiddenToggleInfoTextSx,
                          gridColumn: '1',
                          [signalGroupCardLargeQuery]: { gridColumn: '1 / span 4', gridRow: '1' },
                          [signalGroupCardExtraLargeQuery]: { gridColumn: '1 / span 3' },
                        }}
                      >
                        <Typography variant="caption" color="text.secondary">
                          Zufahrt
                        </Typography>
                        <FormControl size="small" sx={{ minWidth: 220, width: 'max-content' }}>
                          <Select
                            size="small"
                            value={group.approach}
                            inputProps={{ 'aria-label': `Zufahrt ${group.name}` }}
                            renderValue={(value) => <Approach approach={value} />}
                            sx={{
                              minHeight: 40,
                              '& .MuiSelect-select': {
                                alignItems: 'center',
                                display: 'flex',
                                minHeight: 0,
                                py: 0.75,
                              },
                            }}
                            onChange={(event) =>
                              patchSignalGroup(group.id, {
                                approach: event.target.value as IntersectionWizardApproach,
                              })
                            }
                          >
                            {approaches.map((approach) => (
                              <MenuItem key={approach} value={approach}>
                                <Approach approach={approach} />
                              </MenuItem>
                            ))}
                          </Select>
                        </FormControl>
                        <FormHelperText sx={{ m: 0 }}>Aus dieser Richtung kommt der Verkehr.</FormHelperText>
                      </Stack>
                      <CompactToggleField
                        label="Typ"
                        infoText="Autos, ÖPNV oder Fußgänger"
                        sx={{
                          gridColumn: '1',
                          [signalGroupCardLargeQuery]: {
                            gridColumn: '1 / span 4',
                            gridRow: '2',
                          },
                          [signalGroupCardExtraLargeQuery]: {
                            gridColumn: '4 / span 3',
                            gridRow: '1',
                          },
                        }}
                      >
                        <ToggleButtonGroup
                          exclusive
                          size="small"
                          value={group.trafficType}
                          onChange={(_event, value) => value && patchSignalGroup(group.id, { trafficType: value })}
                        >
                          {selectableTrafficTypes.map((type) => {
                            const TypeIcon = trafficTypeIcons[type];
                            return (
                              <ToggleButton
                                key={type}
                                value={type}
                                title={trafficTypeLabels[type]}
                                sx={{
                                  ...signalGroupToggleButtonSx,
                                  gap: 0.5,
                                  '&.Mui-selected, &.Mui-selected:hover': {
                                    bgcolor: 'primary.main',
                                    borderColor: 'primary.main',
                                    color: 'primary.contrastText',
                                  },
                                }}
                              >
                                <TypeIcon fontSize="small" />
                                {compactTrafficTypeLabels[type]}
                              </ToggleButton>
                            );
                          })}
                        </ToggleButtonGroup>
                      </CompactToggleField>
                      {group.trafficType !== 'PEDESTRIAN' && renderTurnDirectionToggle(group)}
                      <Stack
                        spacing={0.5}
                        sx={{
                          alignSelf: 'start',
                          gridColumn: '1',
                          [signalGroupCardLargeQuery]: {
                            gridColumn: '9 / span 4',
                            gridRow: '2 / span 2',
                          },
                          [signalGroupCardExtraLargeQuery]: {
                            gridColumn: '10 / span 3',
                            gridRow: '1 / span 2',
                          },
                        }}
                      >
                        <Typography variant="caption" color="text.secondary">
                          Vorschau
                        </Typography>
                        <SignalGroupTrafficLightPreview
                          align="left"
                          trafficType={group.trafficType}
                          turnDirections={group.turnDirections}
                        />
                        <FormHelperText sx={{ m: 0 }}>
                          {group.trafficType === 'PEDESTRIAN'
                            ? 'Fußgängerfurt'
                            : 'Diese Richtungen schaltet die Ampelgruppe.'}
                        </FormHelperText>
                      </Stack>
                      {draft.manualLuaVariableNames && (
                        <FormTextfield
                          label="Name"
                          value={group.name}
                          size="small"
                          infoText="Automatisch abgeleiteter Lua-Name der Ampelgruppe."
                          InputProps={{ readOnly: true }}
                          sx={{
                            gridColumn: '1',
                            [signalGroupCardLargeQuery]: { gridColumn: '5 / span 4', gridRow: '3' },
                            [signalGroupCardExtraLargeQuery]: { gridColumn: '4 / span 3', gridRow: '2' },
                          }}
                        />
                      )}
                    </Box>
                    <Stack spacing={1.5}>
                      {renderSignalAmpelTable(group, signalAmpeln)}
                      {supportsStructureLightSignals && renderStructureAmpelTable(group, structureAmpeln)}
                      {group.trafficType !== 'PEDESTRIAN' && structureAmpeln.length > 0 && (
                        <ExplainedCheckbox
                          checked={group.showRequests}
                          label="Anforderungen anzeigen"
                          sx={{
                            alignSelf: 'start',
                            '& .MuiFormControlLabel-root': { m: 0 },
                          }}
                          onChange={(_event, checked) => patchSignalGroup(group.id, { showRequests: checked })}
                        />
                      )}
                    </Stack>
                  </Stack>
                </Stack>
              </Paper>
            );
          })}
        </Stack>
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', width: '100%' }}>
          <Button startIcon={<AddIcon />} variant="contained" onClick={addSignalGroup}>
            Ampelgruppe hinzufügen
          </Button>
        </Box>
      </Stack>
    );
  }

  function renderLaneSignalFields(lane: IntersectionWizardLaneAppDto) {
    const selectedModelValue = modelSelectValue(lane.signal);
    const options = modelOptionsWithSelected(selectedModelValue);
    const selectableSignalGroups = lane.signalGroupAssignments
      .map((assignment) => draft.signalGroups.find((group) => group.id === assignment.signalGroupId))
      .filter((group): group is IntersectionWizardSignalGroupAppDto => Boolean(group && group.ampelIds.length === 1));
    if (lane.signalSource === 'SIGNAL_GROUP') {
      return (
        <FormControl size="small" fullWidth>
          <Select
            value={lane.signalGroupSignalId ?? ''}
            inputProps={{ 'aria-label': `Fahrspursignal ${lane.name}` }}
            onChange={(event) => patchLane(lane.id, { signalGroupSignalId: event.target.value })}
          >
            {selectableSignalGroups.map((group) => (
              <MenuItem key={group.id} value={group.id}>
                {group.name} ({signalGroupAmpelNames(group)})
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      );
    }
    return (
      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: 'repeat(3, minmax(0, 1fr))' }, gap: 1 }}>
        <FormTextfield
          label="Name"
          value={lane.signal.name}
          size="small"
          infoText="Lua-Variablenname des Fahrspursignals."
          onChange={(event) => patchLane(lane.id, { signal: { ...lane.signal, name: event.target.value } })}
        />
        <FormTextfield
          label="Signal-ID"
          value={lane.signal.signalId ?? ''}
          size="small"
          infoText="Positive EEP-Signal-ID des Fahrspursignals."
          inputProps={{ inputMode: 'numeric' }}
          onChange={(event) => patchLane(lane.id, { signal: { ...lane.signal, signalId: event.target.value } })}
        />
        <FormControl size="small" fullWidth>
          <Select
            value={selectedModelValue}
            onChange={(event) => {
              const value = event.target.value;
              const option = options.find((entry) => (entry.model.luaConstant ?? entry.model.name) === value);
              patchLane(lane.id, {
                signal: {
                  ...lane.signal,
                  modelName: option?.model.name ?? value,
                  modelConstant: option?.model.luaConstant ?? value,
                },
              });
            }}
          >
            {options.map((option) => {
              const value = option.model.luaConstant ?? option.model.name;
              return (
                <MenuItem key={value} value={value}>
                  {compactTrafficLightModelLabel(option.model)}
                </MenuItem>
              );
            })}
          </Select>
        </FormControl>
      </Box>
    );
  }

  function renderLaneAssignmentRows(lane: IntersectionWizardLaneAppDto, showAssignmentControls: boolean) {
    const availableGroups = availableSignalGroupsForLane(lane);
    const showSelectionCheckboxes = availableGroups.length > 1;
    return availableSignalGroupsForLane(lane).map((group) => {
      const assignment = lane.signalGroupAssignments.find((entry) => entry.signalGroupId === group.id);
      const selected = Boolean(assignment) || !showSelectionCheckboxes;
      return (
        <Box
          key={group.id}
          sx={{
            display: 'grid',
            gridTemplateColumns: {
              xs: 'auto auto minmax(0, 1fr)',
              md: 'auto auto minmax(12rem, max-content) minmax(18rem, 1fr)',
            },
            gap: 1,
            alignItems: 'start',
            px: 1,
            py: 0.75,
            borderTop: 1,
            borderColor: 'divider',
            bgcolor: selected ? selectedSignalGroupSx.bgcolor : 'transparent',
            boxShadow: selected ? 'inset 3px 0 0 #1976d2' : 'none',
            transition: 'background-color 120ms ease',
            '&:hover': {
              bgcolor: selected ? selectedSignalGroupSx['&:hover'].bgcolor : 'action.hover',
            },
            '&:first-of-type': {
              borderTop: 0,
            },
          }}
        >
          {showSelectionCheckboxes ? (
            <Checkbox
              checked={selected}
              sx={{ alignSelf: 'center', p: 0.5 }}
              onChange={(_event, checked) => setLaneAssignment(lane, group.id, checked)}
            />
          ) : (
            <Box sx={{ alignSelf: 'center', width: 30 }} />
          )}
          <Box sx={{ width: 96, alignSelf: 'center' }}>
            <SignalGroupTrafficLightPreview
              align="left"
              size="small"
              trafficType={group.trafficType}
              turnDirections={group.turnDirections}
            />
          </Box>
          <Typography variant="body2" sx={{ alignSelf: 'center', whiteSpace: 'nowrap' }}>
            {group.name}
          </Typography>
          {showAssignmentControls && (
            <Stack
              spacing={1}
              sx={{
                display: selected ? 'flex' : 'none',
                gridColumn: { xs: '3 / -1', md: '4' },
                gridRow: { xs: '2', md: '1' },
                minWidth: 0,
                pt: 1.5,
              }}
            >
              {selected && (
                <>
                  <FormControl size="small" fullWidth>
                    <Select
                      value={assignment?.mode ?? 'DEFAULT'}
                      onChange={(event) =>
                        patchLaneAssignment(lane, group.id, {
                          mode: event.target.value as 'DEFAULT' | 'ONLY' | 'ALSO',
                        })
                      }
                    >
                      <MenuItem value="DEFAULT">Standard-Signalgruppe</MenuItem>
                      <MenuItem value="ONLY">Nur bei diesen Routen fahren</MenuItem>
                      <MenuItem value="ALSO">Auch bei diesen Routen fahren</MenuItem>
                    </Select>
                  </FormControl>
                  {assignment?.mode !== 'DEFAULT' && (
                    <Autocomplete<string, true, false, true>
                      multiple
                      freeSolo
                      size="small"
                      options={routeOptions}
                      value={assignment?.routeNames ?? []}
                      renderTags={(value, getTagProps) =>
                        value.map((option, index) => (
                          <Chip {...getTagProps({ index })} key={`${option}-${index}`} label={option} size="small" />
                        ))
                      }
                      onChange={(_event, values) => patchLaneAssignment(lane, group.id, { routeNames: values })}
                      renderInput={(params) => <FormTextfield {...params} infoText="Routen für diese Zuweisung." />}
                    />
                  )}
                </>
              )}
            </Stack>
          )}
        </Box>
      );
    });
  }

  function renderLanesStep() {
    const validApproaches = Array.from(
      new Set(draft.signalGroups.filter((group) => group.trafficType !== 'PEDESTRIAN').map((group) => group.approach)),
    );
    return (
      <Stack spacing={2}>
        <Stack direction="row" spacing={1} alignItems="center">
          <IconHeadline text="Fahrspuren" variant="h6" />
        </Stack>
        {validApproaches.length === 0 && (
          <FeedbackMessage severity="warning">
            Lege zuerst mindestens eine Fahrzeug- oder Tram/Bus-Signalgruppe an.
          </FeedbackMessage>
        )}
        <Stack spacing={2} sx={{ bgcolor: 'grey.50', p: 1.5, borderRadius: 1 }}>
          {draft.lanes.map((lane, laneIndex) => {
            const selectedAssignments = lane.signalGroupAssignments;
            const showAssignmentControls = selectedAssignments.length > 1;
            const hasDefault = selectedAssignments.some((assignment) => assignment.mode === 'DEFAULT');
            const selectableSignalGroups = selectedAssignments
              .map((assignment) => draft.signalGroups.find((group) => group.id === assignment.signalGroupId))
              .filter((group): group is IntersectionWizardSignalGroupAppDto =>
                Boolean(group && group.ampelIds.length === 1),
              );
            return (
              <Paper
                key={lane.id}
                variant="outlined"
                sx={{
                  p: 2,
                  bgcolor: 'background.paper',
                  borderColor: 'grey.300',
                  boxShadow: '0 1px 2px rgba(15, 23, 42, 0.06)',
                }}
              >
                <Stack spacing={0.5}>
                  <IconHeadlineDelete
                    text={`Fahrspur ${lane.name} (${laneLuaDisplayName(lane, laneIndex, draft.luaVariableName)})`}
                    icon={<DirectionsCarIcon />}
                    variant="h6"
                    ariaLabel={`Fahrspur ${lane.name} löschen`}
                    onDelete={() => removeLane(lane.id)}
                  />
                  <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' }, gap: 1.5 }}>
                    <FormTextfield
                      label="Fahrspurname"
                      value={lane.name}
                      size="small"
                      infoText="Name der Fahrspur im generierten Lua-Code."
                      onChange={(event) => patchLane(lane.id, { name: event.target.value })}
                    />
                    <FormSelect
                      id={`${lane.id}-approach`}
                      label="Zufahrt"
                      value={lane.approach}
                      size="small"
                      infoText="Nur Richtungen mit Signalgruppen können genutzt werden."
                      renderValue={(value) => <Approach approach={value} />}
                      onChange={(approach) => {
                        const signalGroupsForApproach = draft.signalGroups.filter(
                          (group) => group.trafficType !== 'PEDESTRIAN' && group.approach === approach,
                        );
                        patchLane(lane.id, {
                          approach,
                          signalGroupAssignments:
                            signalGroupsForApproach.length === 1
                              ? [{ signalGroupId: signalGroupsForApproach[0].id, mode: 'DEFAULT' }]
                              : lane.signalGroupAssignments.filter(
                                  (assignment) =>
                                    draft.signalGroups.find((group) => group.id === assignment.signalGroupId)
                                      ?.approach === approach,
                                ),
                        });
                      }}
                      options={(validApproaches.length > 0 ? validApproaches : approaches).map((approach) => ({
                        value: approach,
                        label: <Approach approach={approach} />,
                      }))}
                    />
                  </Box>
                  <Stack spacing={0.75}>
                    <Typography variant="subtitle2">Signalgruppen</Typography>
                    <Paper variant="outlined" sx={{ overflow: 'hidden' }}>
                      {renderLaneAssignmentRows(lane, showAssignmentControls)}
                    </Paper>
                  </Stack>
                  {selectedAssignments.length > 1 && !hasDefault && (
                    <FeedbackMessage severity="warning">
                      Bei mehreren Signalgruppen muss mindestens eine Standard-Signalgruppe gewählt werden.
                    </FeedbackMessage>
                  )}
                  <Stack spacing={1} sx={{ pt: 1 }}>
                    <Typography variant="subtitle2">Fahrspursignal</Typography>
                    <ToggleButtonGroup
                      exclusive
                      size="small"
                      sx={{ mb: 1 }}
                      value={lane.signalSource}
                      onChange={(_event, value) => {
                        if (!value) return;
                        patchLane(lane.id, {
                          signalSource: value,
                          signalGroupSignalId:
                            value === 'SIGNAL_GROUP'
                              ? (selectableSignalGroups[0]?.id ?? lane.signalGroupSignalId)
                              : undefined,
                        });
                      }}
                    >
                      <ToggleButton
                        value="OWN"
                        sx={{
                          '&.Mui-selected, &.Mui-selected:hover': selectedSignalGroupSx,
                        }}
                      >
                        Selbst definieren
                      </ToggleButton>
                      <ToggleButton
                        value="SIGNAL_GROUP"
                        disabled={selectableSignalGroups.length === 0}
                        sx={{
                          '&.Mui-selected, &.Mui-selected:hover': selectedSignalGroupSx,
                        }}
                      >
                        Aus Signalgruppe
                      </ToggleButton>
                    </ToggleButtonGroup>
                    {renderLaneSignalFields(lane)}
                  </Stack>
                </Stack>
              </Paper>
            );
          })}
        </Stack>
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', width: '100%' }}>
          <Button startIcon={<AddIcon />} variant="contained" onClick={addLane} disabled={validApproaches.length === 0}>
            Fahrspur hinzufügen
          </Button>
        </Box>
      </Stack>
    );
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
          onIntersectionNameChange={(name) => updateDraft({ name, luaVariableName: slug(name, 'kreuzung') })}
          onLuaVariableNameChange={(luaVariableName) => updateDraft({ luaVariableName })}
          onOptionalPositiveNumber={optionalPositiveNumber}
          onShowAdvancedIntersectionSettingsChange={setShowAdvancedIntersectionSettings}
        />
      );
    }
    if (activeStep === 2) return renderSignalGroupsStep();
    if (activeStep === 3) return renderLanesStep();
    if (activeStep === 4) {
      return (
        <IntersectionWizardPhasePlanStep
          draft={draft}
          ampelLabel={(ampelId) => draft.ampeln.find((ampel) => ampel.id === ampelId)?.name ?? ampelId}
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
              showCodePreview && !isSummaryStep ? { xs: '1fr', xl: 'minmax(0, 2fr) minmax(0, 1fr)' } : '1fr',
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
