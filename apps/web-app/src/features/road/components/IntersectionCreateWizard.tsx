import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import type { ReactNode } from 'react';
import Autocomplete from '@mui/material/Autocomplete';
import Badge from '@mui/material/Badge';
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
import TextField from '@mui/material/TextField';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import type { SxProps, Theme } from '@mui/material/styles';
import AddIcon from '@mui/icons-material/Add';
import DirectionsCarIcon from '@mui/icons-material/DirectionsCar';
import DirectionsWalkIcon from '@mui/icons-material/DirectionsWalk';
import TrafficIcon from '@mui/icons-material/Traffic';
import TramIcon from '@mui/icons-material/Tram';
import VerticalAlignCenterIcon from '@mui/icons-material/VerticalAlignCenter';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import {
  CeTypes,
  CommandEvent,
  IntersectionListRoom,
  RoadEvent,
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
  StructureAppDto,
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
import {
  buildAlignStructureSignalInstallerCommand,
  inferHousingKind,
  isBlendStructureName,
  isHousingStructureName,
  isSignalStructureName,
  parseInstallerTag,
  signalCountForHousingKind,
} from './structure-signal-installer/structureSignalInstallerLogic';

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
  const helperText = hasError ? <strong>{errorTexts.join(' ')}</strong> : props.infoText;
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
    showLuaCodeImmediately: false,
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

function sanitizeLuaIdentifier(value: string, fallback: string) {
  const ascii = value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^A-Za-z0-9_]+/g, '_')
    .replace(/^_+|_+$/g, '');
  const withFallback = ascii || fallback;
  return /^[A-Za-z_]/.test(withFallback) ? withFallback : `${fallback}_${withFallback}`;
}

function automaticIntersectionLuaVariableName(draft: IntersectionWizardDraftAppDto) {
  return /^c\d+$/i.test(draft.luaVariableName.trim()) ? draft.luaVariableName : 'c1';
}

function laneLuaDisplayName(
  lane: IntersectionWizardLaneAppDto,
  index: number,
  _intersectionPrefix: string,
  useManualLuaVariableNames: boolean,
) {
  if (useManualLuaVariableNames && lane.luaVariableName?.trim()) {
    return sanitizeLuaIdentifier(lane.luaVariableName, `lane${index + 1}`);
  }
  return `lane${index + 1}`;
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

function positiveSignalId(signalId: string | undefined) {
  const numeric = Number(signalId);
  return Number.isInteger(numeric) && numeric > 0 ? numeric : undefined;
}

function signalGroupRealEepSignalAmpels(
  group: IntersectionWizardSignalGroupAppDto,
  ampeln: IntersectionWizardAmpelAppDto[],
) {
  return group.ampelIds
    .map((ampelId) => ampeln.find((ampel) => ampel.id === ampelId))
    .filter((ampel): ampel is IntersectionWizardAmpelAppDto =>
      Boolean(ampel && !isStructureLightAmpel(ampel) && positiveSignalId(ampel.signalId) !== undefined),
    );
}

function signalGroupLaneSignalOptionsForLane(
  group: IntersectionWizardSignalGroupAppDto | undefined,
  lane: IntersectionWizardLaneAppDto,
  ampeln: IntersectionWizardAmpelAppDto[],
) {
  if (!group) return [];
  const laneSignalId = positiveSignalId(lane.signal.signalId);
  return signalGroupRealEepSignalAmpels(group, ampeln).map((ampel) => ({
    group,
    ampel,
    detected: laneSignalId !== undefined && positiveSignalId(ampel.signalId) === laneSignalId,
  }));
}

function laneSignalOptionValue(groupId: string, ampelId: string) {
  return `${groupId}|${ampelId}`;
}

function emptyLaneSignal(name: string): IntersectionWizardLaneSignalAppDto {
  return { name, modelName: 'Unsichtbar_2er', modelConstant: 'Unsichtbar_2er', lightStructures: [] };
}

type LightStructureKey =
  | 'structureBlend'
  | 'structureGreen'
  | 'structureHousing'
  | 'structureRed'
  | 'structureRequest'
  | 'structureYellow';

type LightStructureField = {
  key: LightStructureKey;
  label: string;
  optionKind: 'BLEND' | 'GREEN' | 'HOUSING' | 'RED' | 'REQUEST' | 'YELLOW';
  required?: boolean;
};

const lightStructureFields: LightStructureField[] = [
  { key: 'structureHousing', label: 'Gehäuse', optionKind: 'HOUSING' },
  { key: 'structureBlend', label: 'Blendschutz (optional)', optionKind: 'BLEND' },
  { key: 'structureRequest', label: 'Immobilie-Anforderung (optional)', optionKind: 'REQUEST' },
  { key: 'structureRed', label: 'Immobilie-Rot', optionKind: 'RED', required: true },
  { key: 'structureYellow', label: 'Immobilie-Gelb (optional)', optionKind: 'YELLOW' },
  { key: 'structureGreen', label: 'Immobilie-Grün', optionKind: 'GREEN', required: true },
];

function normalizeStructureText(value: string | undefined): string {
  return (value ?? '')
    .toLocaleLowerCase()
    .replace(/ä/g, 'ae')
    .replace(/ö/g, 'oe')
    .replace(/ü/g, 'ue')
    .replace(/ß/g, 'ss')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

function structureSearchText(structure: StructureAppDto): string {
  return `${structure.name} ${structure.gsbname ?? ''}`;
}

function sortedStructureNames(structures: StructureAppDto[], predicate: (structure: StructureAppDto) => boolean) {
  return Array.from(new Set(structures.filter(predicate).map((structure) => structure.name))).sort((a, b) =>
    a.localeCompare(b, undefined, { numeric: true }),
  );
}

function structureSignalTagPatch(
  tag: string | undefined,
): Partial<NonNullable<IntersectionWizardAmpelAppDto['lightStructures']>[number]> {
  const values = parseInstallerTag(tag);
  const green = values.g ?? values.F1 ?? values.F2 ?? values.F3 ?? values.F5;
  return {
    ...((values.F0 ?? values.r) ? { structureRed: values.F0 ?? values.r } : {}),
    ...((values.F4 ?? values.y) ? { structureYellow: values.F4 ?? values.y } : {}),
    ...(green ? { structureGreen: green } : {}),
    ...(values.A ? { structureRequest: values.A } : {}),
    ...(values.bl ? { structureBlend: values.bl } : {}),
  };
}

function structureMatchesLightTag(structure: StructureAppDto, selectedName: string, selectedTag: string) {
  if (selectedTag && structure.tag === selectedTag && isHousingStructureName(structureSearchText(structure)))
    return true;
  const values = parseInstallerTag(structure.tag);
  return Object.values(values).some((value) => value === selectedName);
}

function effectiveLaneSignalGroupAssignments(
  lane: IntersectionWizardLaneAppDto,
  signalGroups: IntersectionWizardSignalGroupAppDto[],
): IntersectionWizardLaneAppDto['signalGroupAssignments'] {
  const availableGroups = signalGroups.filter(
    (group) => group.trafficType !== 'PEDESTRIAN' && group.approach === lane.approach,
  );
  const availableGroupIds = new Set(availableGroups.map((group) => group.id));
  const currentAssignments = lane.signalGroupAssignments.filter((assignment) =>
    availableGroupIds.has(assignment.signalGroupId),
  );
  if (
    availableGroups.length === 1 &&
    !currentAssignments.some((assignment) => assignment.signalGroupId === availableGroups[0].id)
  ) {
    return [{ signalGroupId: availableGroups[0].id, mode: 'DEFAULT' }];
  }
  return currentAssignments;
}

function normalizeDraftLaneAssignments(draft: IntersectionWizardDraftAppDto): IntersectionWizardDraftAppDto {
  return {
    ...draft,
    lanes: draft.lanes.map((lane) => ({
      ...lane,
      signalGroupAssignments: effectiveLaneSignalGroupAssignments(lane, draft.signalGroups),
    })),
  };
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

function validationErrorCount(fields: Record<string, string[] | undefined> | undefined): number {
  return Object.values(fields ?? {}).reduce((count, errorTexts) => count + (errorTexts?.length ?? 0), 0);
}

function ampelNameForSignalGroup(
  group: IntersectionWizardSignalGroupAppDto,
  ampel: IntersectionWizardAmpelAppDto,
): string {
  return group.trafficType === 'PEDESTRIAN' ? (ampel.pedestrianName ?? ampel.name) : ampel.name;
}

function isVehicleSourceAmpel(ampel: IntersectionWizardAmpelAppDto): boolean {
  return ampel.trafficType !== 'PEDESTRIAN' && ampel.use !== 'PEDESTRIAN_ONLY';
}

function sourceSignalOptionLabel(ampel: IntersectionWizardAmpelAppDto): ReactNode {
  return (
    <>
      {ampel.name} verwenden{' '}
      <Box component="span" sx={{ color: 'text.secondary' }}>
        (Signal-ID: {ampel.signalId || '-'}, {modelValue(ampel) || '-'})
      </Box>
    </>
  );
}

function pedestrianSourceAmpel(
  group: IntersectionWizardSignalGroupAppDto,
  ampel: IntersectionWizardAmpelAppDto,
  ampeln: IntersectionWizardAmpelAppDto[],
): IntersectionWizardAmpelAppDto | undefined {
  if (group.trafficType !== 'PEDESTRIAN') return undefined;
  if (ampel.sourceAmpelId) return ampeln.find((entry) => entry.id === ampel.sourceAmpelId);
  return isVehicleSourceAmpel(ampel) && ampel.use === 'VEHICLE_AND_PEDESTRIAN' ? ampel : undefined;
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

type ValidationFields<T extends string> = Partial<Record<T, string[]>>;

type IntersectionWizardValidation = {
  ampelErrors: Record<
    string,
    ValidationFields<
      | 'model'
      | 'name'
      | 'signalId'
      | 'sourceAmpelId'
      | 'structureBlend'
      | 'structureGreen'
      | 'structureHousing'
      | 'structureRed'
      | 'structureRequest'
      | 'structureYellow'
    >
  >;
  errors: string[];
  laneErrors: Record<
    string,
    ValidationFields<
      | 'approach'
      | 'assignments'
      | 'name'
      | 'routeNames'
      | 'signalGroupSignalId'
      | 'signalId'
      | 'signalModel'
      | 'signalName'
    >
  >;
  phaseErrors: Record<string, ValidationFields<'greenTimeSeconds' | 'name' | 'signalGroupIds'>>;
  settingsErrors: ValidationFields<
    'greenTimeSeconds' | 'intersectionEepSaveId' | 'luaVariableName' | 'name' | 'staticCams' | 'tippStructure'
  >;
  signalGroupErrors: Record<string, ValidationFields<'ampelIds' | 'turnDirections'>>;
  stepErrorCounts: Record<number, number>;
  warnings: string[];
};

const luaIdentifierPattern = /^[A-Za-z_][A-Za-z0-9_]*$/;
const eepStructureNamePattern = /^#\d+/;
const eepStructureNameErrorText =
  'Gib den Lua-Namen der Immobilie aus den Objekteigenschaften in EEP ein, z.B. #321_...';
const eepSignalIdErrorText = 'Gib die Signal-ID aus den Objekteigenschaften in EEP an.';
type DuplicateTrafficLightOwner = {
  field: string;
  label: string;
  signalKind: 'LANE' | 'PEDESTRIAN' | 'TRAFFIC';
  signalGroupName?: string;
  stepIndex: number;
  target: ValidationFields<string>;
};

function createWizardValidation(): IntersectionWizardValidation {
  return {
    ampelErrors: {},
    errors: [],
    laneErrors: {},
    phaseErrors: {},
    settingsErrors: {},
    signalGroupErrors: {},
    stepErrorCounts: {},
    warnings: [],
  };
}

function addValidationError<T extends string>(
  validation: IntersectionWizardValidation,
  stepIndex: number,
  target: ValidationFields<T>,
  field: T,
  message: string,
) {
  target[field] = [...(target[field] ?? []), message];
  validation.errors.push(message);
  validation.stepErrorCounts[stepIndex] = (validation.stepErrorCounts[stepIndex] ?? 0) + 1;
}

function isPositiveIntegerValue(value: string | number | undefined): boolean {
  const numeric = typeof value === 'number' ? value : Number(value);
  return Number.isInteger(numeric) && numeric > 0;
}

function validateLuaIdentifier(value: string | undefined): boolean {
  return Boolean(value?.trim() && luaIdentifierPattern.test(value.trim()));
}

function modelValue(model: Pick<IntersectionWizardAmpelAppDto, 'modelConstant' | 'modelName'>): string {
  return model.modelConstant || model.modelName;
}

function validateIntersectionWizardDraft(
  draft: IntersectionWizardDraftAppDto,
  knownCameraNames: string[],
  knownRouteNames: string[],
  trafficLightModelOptions: TrafficLightModelOption[],
): IntersectionWizardValidation {
  const validation = createWizardValidation();
  const knownCameras = new Set(knownCameraNames);
  const knownRoutes = new Set(knownRouteNames);

  if (!draft.name.trim()) {
    addValidationError(validation, 1, validation.settingsErrors, 'name', 'Gib einen Kreuzungsnamen ein.');
  }
  if (!Number.isInteger(draft.intersectionEepSaveId ?? -1) || (draft.intersectionEepSaveId ?? -1) < -1) {
    addValidationError(
      validation,
      1,
      validation.settingsErrors,
      'intersectionEepSaveId',
      'Der EEP-Speicherplatz muss -1 oder eine positive Zahl sein.',
    );
  }
  if (draft.greenTimeSeconds !== undefined && !isPositiveIntegerValue(draft.greenTimeSeconds)) {
    addValidationError(
      validation,
      1,
      validation.settingsErrors,
      'greenTimeSeconds',
      'Die Standard-Grünzeit muss eine positive ganze Zahl sein.',
    );
  }
  if (draft.tippStructure?.trim() && !eepStructureNamePattern.test(draft.tippStructure.trim())) {
    addValidationError(validation, 1, validation.settingsErrors, 'tippStructure', eepStructureNameErrorText);
  }
  if (draft.manualLuaVariableNames && !validateLuaIdentifier(draft.luaVariableName)) {
    addValidationError(
      validation,
      1,
      validation.settingsErrors,
      'luaVariableName',
      'Die Lua-Variable muss mit einem Buchstaben oder _ beginnen und darf nur Buchstaben, Zahlen und _ enthalten.',
    );
  }
  (draft.staticCams ?? []).forEach((cameraName) => {
    if (knownCameras.size > 0 && cameraName.trim() && !knownCameras.has(cameraName)) {
      validation.warnings.push(`Kamera "${cameraName}" ist in EEP nicht bekannt. Prüfe die Schreibweise.`);
    }
  });

  if (draft.signalGroups.length === 0) {
    validation.errors.push('Lege mindestens eine Ampelgruppe an.');
    validation.stepErrorCounts[2] = (validation.stepErrorCounts[2] ?? 0) + 1;
  }

  const signalIdOwners = new Map<number, DuplicateTrafficLightOwner[]>();
  const ampelNameOwners = new Map<string, DuplicateTrafficLightOwner[]>();
  function registerSignalId(
    signalId: string | undefined,
    owner: string,
    stepIndex: number,
    target: ValidationFields<string>,
    field: string,
    signalKind: DuplicateTrafficLightOwner['signalKind'],
    signalGroupName?: string,
  ) {
    const numeric = positiveSignalId(signalId);
    if (numeric === undefined) return;
    signalIdOwners.set(numeric, [
      ...(signalIdOwners.get(numeric) ?? []),
      { field, label: owner, signalGroupName, signalKind, stepIndex, target },
    ]);
  }
  function registerAmpelName(
    name: string | undefined,
    _owner: string,
    stepIndex: number,
    target: ValidationFields<string>,
    field: string,
    signalGroupName: string,
  ) {
    const trimmedName = name?.trim();
    if (!trimmedName) return;
    const key = trimmedName.toLocaleLowerCase();
    ampelNameOwners.set(key, [
      ...(ampelNameOwners.get(key) ?? []),
      { field, label: trimmedName, signalGroupName, stepIndex, target },
    ]);
  }

  draft.signalGroups.forEach((group) => {
    const groupErrors = (validation.signalGroupErrors[group.id] = validation.signalGroupErrors[group.id] ?? {});
    const groupAmpeln = group.ampelIds
      .map((ampelId) => draft.ampeln.find((ampel) => ampel.id === ampelId))
      .filter((ampel): ampel is IntersectionWizardAmpelAppDto => Boolean(ampel));
    const signalAmpeln = groupAmpeln.filter((ampel) => !isStructureLightAmpel(ampel));
    const structureAmpeln = groupAmpeln.filter(isStructureLightAmpel);
    const hasAssignedLaneSignal = draft.lanes.some(
      (lane) =>
        effectiveLaneSignalGroupAssignments(lane, draft.signalGroups).some(
          (assignment) => assignment.signalGroupId === group.id,
        ) && positiveSignalId(lane.signal.signalId) !== undefined,
    );

    if (group.trafficType !== 'PEDESTRIAN' && group.turnDirections.length === 0) {
      addValidationError(
        validation,
        2,
        groupErrors,
        'turnDirections',
        `${group.name}: Wähle mindestens eine Richtung.`,
      );
    }
    if (signalAmpeln.length === 0 && !(structureAmpeln.length > 0 && hasAssignedLaneSignal)) {
      addValidationError(
        validation,
        2,
        groupErrors,
        'ampelIds',
        `${group.name}: Füge mindestens eine EEP-Ampel hinzu.`,
      );
    }

    groupAmpeln.forEach((ampel) => {
      const ampelErrors = (validation.ampelErrors[ampel.id] = validation.ampelErrors[ampel.id] ?? {});
      const effectiveAmpelName = ampelNameForSignalGroup(group, ampel);
      if (!effectiveAmpelName.trim()) {
        addValidationError(validation, 2, ampelErrors, 'name', 'Gib einen Namen ein.');
      } else {
        registerAmpelName(effectiveAmpelName, effectiveAmpelName, 2, ampelErrors, 'name', group.name);
      }
      if (isStructureLightAmpel(ampel)) {
        const structure = ampel.lightStructures?.[0];
        if (!structure?.structureRed?.trim()) {
          addValidationError(validation, 2, ampelErrors, 'structureRed', 'Gib die Immobilie für Rot ein.');
        } else if (!eepStructureNamePattern.test(structure.structureRed.trim())) {
          addValidationError(validation, 2, ampelErrors, 'structureRed', eepStructureNameErrorText);
        }
        if (!structure?.structureGreen?.trim()) {
          addValidationError(validation, 2, ampelErrors, 'structureGreen', 'Gib die Immobilie für Grün ein.');
        } else if (!eepStructureNamePattern.test(structure.structureGreen.trim())) {
          addValidationError(validation, 2, ampelErrors, 'structureGreen', eepStructureNameErrorText);
        }
        if (structure?.structureYellow?.trim() && !eepStructureNamePattern.test(structure.structureYellow.trim())) {
          addValidationError(validation, 2, ampelErrors, 'structureYellow', eepStructureNameErrorText);
        }
        if (structure?.structureRequest?.trim() && !eepStructureNamePattern.test(structure.structureRequest.trim())) {
          addValidationError(validation, 2, ampelErrors, 'structureRequest', eepStructureNameErrorText);
        }
        if (structure?.structureHousing?.trim() && !eepStructureNamePattern.test(structure.structureHousing.trim())) {
          addValidationError(validation, 2, ampelErrors, 'structureHousing', eepStructureNameErrorText);
        }
        if (structure?.structureBlend?.trim() && !eepStructureNamePattern.test(structure.structureBlend.trim())) {
          addValidationError(validation, 2, ampelErrors, 'structureBlend', eepStructureNameErrorText);
        }
        return;
      }
      if (group.trafficType === 'PEDESTRIAN' && ampel.sourceAmpelId) {
        const source = draft.ampeln.find((entry) => entry.id === ampel.sourceAmpelId);
        if (!source || isStructureLightAmpel(source)) {
          addValidationError(validation, 2, ampelErrors, 'sourceAmpelId', 'Wähle eine vorhandene Fahrzeug-Ampel.');
        }
        return;
      }
      if (!isPositiveIntegerValue(ampel.signalId)) {
        addValidationError(validation, 2, ampelErrors, 'signalId', eepSignalIdErrorText);
      } else {
        registerSignalId(
          ampel.signalId,
          effectiveAmpelName || group.name,
          2,
          ampelErrors,
          'signalId',
          group.trafficType === 'PEDESTRIAN' ? 'PEDESTRIAN' : 'TRAFFIC',
          group.name,
        );
      }
      const selectedModel = modelValue(ampel);
      if (!selectedModel) {
        addValidationError(validation, 2, ampelErrors, 'model', 'Wähle ein Signal-Modell.');
      }
    });
  });

  if (draft.lanes.length === 0) {
    validation.errors.push('Lege mindestens eine Fahrspur an.');
    validation.stepErrorCounts[3] = (validation.stepErrorCounts[3] ?? 0) + 1;
  }

  draft.lanes.forEach((lane) => {
    const laneErrors = (validation.laneErrors[lane.id] = validation.laneErrors[lane.id] ?? {});
    const availableGroups = draft.signalGroups.filter(
      (group) => group.trafficType !== 'PEDESTRIAN' && group.approach === lane.approach,
    );
    const effectiveAssignments = effectiveLaneSignalGroupAssignments(lane, draft.signalGroups);
    const assignedExistingGroups = effectiveAssignments
      .map((assignment) => ({
        assignment,
        group: draft.signalGroups.find((group) => group.id === assignment.signalGroupId),
      }))
      .filter((entry): entry is typeof entry & { group: IntersectionWizardSignalGroupAppDto } => Boolean(entry.group));

    if (!lane.name.trim()) {
      addValidationError(validation, 3, laneErrors, 'name', 'Gib einen Fahrspurnamen ein.');
    }
    if (availableGroups.length === 0) {
      addValidationError(
        validation,
        3,
        laneErrors,
        'approach',
        `${lane.name || 'Fahrspur'}: Diese Zufahrt hat keine Ampelgruppe.`,
      );
    }
    if (assignedExistingGroups.length === 0) {
      addValidationError(
        validation,
        3,
        laneErrors,
        'assignments',
        `${lane.name || 'Fahrspur'}: Wähle mindestens eine Ampelgruppe.`,
      );
    }
    if (
      assignedExistingGroups.length > 1 &&
      !assignedExistingGroups.some(({ assignment }) => assignment.mode === 'DEFAULT')
    ) {
      addValidationError(
        validation,
        3,
        laneErrors,
        'assignments',
        `${lane.name || 'Fahrspur'}: Wähle bei mehreren Ampelgruppen mindestens eine Standard-Ampelgruppe.`,
      );
    }
    assignedExistingGroups.forEach(({ assignment }) => {
      const routeNames = (assignment.routeNames ?? []).map((routeName) => routeName.trim()).filter(Boolean);
      if ((assignment.mode === 'ONLY' || assignment.mode === 'ALSO') && routeNames.length === 0) {
        addValidationError(
          validation,
          3,
          laneErrors,
          'routeNames',
          `${lane.name || 'Fahrspur'}: Gib mindestens eine Route ein.`,
        );
      }
      routeNames.forEach((routeName) => {
        if (knownRoutes.size > 0 && !knownRoutes.has(routeName)) {
          validation.warnings.push(`Route "${routeName}" ist in EEP nicht bekannt. Prüfe die Schreibweise.`);
        }
      });
    });

    if (lane.signalSource === 'SIGNAL_GROUP') {
      const signalGroup = assignedExistingGroups.find(({ group }) => group.id === lane.signalGroupSignalId)?.group;
      const signalOptions = signalGroupLaneSignalOptionsForLane(signalGroup, lane, draft.ampeln);
      const hasSelectedSignal = signalOptions.some(
        ({ ampel }) => positiveSignalId(ampel.signalId) === positiveSignalId(lane.signal.signalId),
      );
      if (!signalGroup || !hasSelectedSignal) {
        addValidationError(
          validation,
          3,
          laneErrors,
          'signalGroupSignalId',
          `${lane.name || 'Fahrspur'}: Wähle ein Fahrspursignal aus einer zugeordneten Ampelgruppe.`,
        );
      }
    } else {
      if (!lane.signal.name.trim()) {
        addValidationError(validation, 3, laneErrors, 'signalName', 'Gib einen Namen für das Fahrspursignal ein.');
      }
      if (!isPositiveIntegerValue(lane.signal.signalId)) {
        addValidationError(validation, 3, laneErrors, 'signalId', eepSignalIdErrorText);
      } else {
        registerSignalId(
          lane.signal.signalId,
          `${lane.name || 'Fahrspur'} Fahrspursignal`,
          3,
          laneErrors,
          'signalId',
          'LANE',
        );
      }
      const selectedModel = modelValue(lane.signal);
      if (!selectedModel) {
        addValidationError(validation, 3, laneErrors, 'signalModel', 'Wähle ein Signal-Modell.');
      }
    }
  });

  signalIdOwners.forEach((owners, signalId) => {
    if (owners.length <= 1) return;
    // One EEP signal may intentionally show both the vehicle/tram light and the pedestrian light.
    if (
      owners.length === 2 &&
      owners.some((owner) => owner.signalKind === 'TRAFFIC') &&
      owners.some((owner) => owner.signalKind === 'PEDESTRIAN')
    ) {
      return;
    }
    owners.forEach((owner) => {
      const otherOwner = owners.find((candidate) => candidate !== owner);
      const otherText = otherOwner?.signalGroupName
        ? `${otherOwner.label} in Ampelgruppe ${otherOwner.signalGroupName}`
        : (otherOwner?.label ?? 'eine andere Ampel');
      addValidationError(
        validation,
        owner.stepIndex,
        owner.target,
        owner.field,
        `EEP-Signal-ID ${signalId} wird hier und für ${otherText} definiert.`,
      );
    });
  });
  ampelNameOwners.forEach((owners) => {
    if (owners.length <= 1) return;
    owners.forEach((owner) => {
      const otherOwner = owners.find((candidate) => candidate !== owner);
      addValidationError(
        validation,
        owner.stepIndex,
        owner.target,
        owner.field,
        `Ampelname "${owner.label}" wird hier und für ${otherOwner?.label ?? 'eine andere Ampel'} in Ampelgruppe ${
          otherOwner?.signalGroupName ?? 'einer anderen Ampelgruppe'
        } definiert.`,
      );
    });
  });

  if (draft.phases.length === 0) {
    validation.errors.push('Lege mindestens eine Ampelphase an.');
    validation.stepErrorCounts[4] = (validation.stepErrorCounts[4] ?? 0) + 1;
  }
  draft.phases.forEach((phase) => {
    const phaseErrors = (validation.phaseErrors[phase.id] = validation.phaseErrors[phase.id] ?? {});
    if (!phase.name.trim()) {
      addValidationError(validation, 4, phaseErrors, 'name', 'Gib einen Phasennamen ein.');
    }
    if (phase.greenTimeSeconds !== undefined && !isPositiveIntegerValue(phase.greenTimeSeconds)) {
      addValidationError(
        validation,
        4,
        phaseErrors,
        'greenTimeSeconds',
        'Die Grünzeit muss eine positive ganze Zahl sein.',
      );
    }
    if (phase.signalGroupIds.some((signalGroupId) => !draft.signalGroups.some((group) => group.id === signalGroupId))) {
      addValidationError(
        validation,
        4,
        phaseErrors,
        'signalGroupIds',
        'Diese Phase enthält eine gelöschte Ampelgruppe.',
      );
    }
  });
  const signalGroupsWithoutGreenPhase = draft.signalGroups.filter(
    (group) => draft.phases.length > 0 && !draft.phases.some((phase) => phase.signalGroupIds.includes(group.id)),
  );
  if (signalGroupsWithoutGreenPhase.length > 0) {
    validation.errors.push(
      `Jede Ampelgruppe braucht mindestens eine grüne Phase. Wähle Grün für: ${signalGroupsWithoutGreenPhase
        .map((group) => group.name || group.id)
        .join(', ')}.`,
    );
    validation.stepErrorCounts[4] = (validation.stepErrorCounts[4] ?? 0) + 1;
  }

  return validation;
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
  const [structures, setStructures] = useState<StructureAppDto[]>([]);
  const [trafficLightModels, setTrafficLightModels] = useState<Record<string, TrafficLightModelAppDto>>({});
  const [showAdvancedIntersectionSettings, setShowAdvancedIntersectionSettings] = useState(false);
  const [sendPreparationSettings, setSendPreparationSettings] = useState(false);
  const [expandedAmpelId, setExpandedAmpelId] = useState('');
  const signalLookupTimers = useRef<Record<string, number>>({});
  const latestSignalLookupValues = useRef<Record<string, string>>({});
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
  const structureByName = useMemo(
    () => new Map(structures.map((structure) => [structure.name, structure])),
    [structures],
  );
  const housingStructureOptions = useMemo(
    () => sortedStructureNames(structures, (structure) => isHousingStructureName(structureSearchText(structure))),
    [structures],
  );
  const blendStructureOptions = useMemo(
    () => sortedStructureNames(structures, (structure) => isBlendStructureName(structureSearchText(structure))),
    [structures],
  );
  const requestStructureOptions = useMemo(
    () =>
      sortedStructureNames(structures, (structure) => {
        const text = normalizeStructureText(structureSearchText(structure));
        return isSignalStructureName(text) && (text.includes('signal a') || text.includes('anforderung'));
      }),
    [structures],
  );
  const redStructureOptions = useMemo(
    () =>
      sortedStructureNames(structures, (structure) => {
        const text = normalizeStructureText(structureSearchText(structure));
        return isSignalStructureName(text) && text.includes('halt') && !text.includes('anhalten');
      }),
    [structures],
  );
  const yellowStructureOptions = useMemo(
    () =>
      sortedStructureNames(structures, (structure) => {
        const text = normalizeStructureText(structureSearchText(structure));
        return isSignalStructureName(text) && (text.includes('anhalten') || text.includes('gelb'));
      }),
    [structures],
  );
  const greenStructureOptions = useMemo(
    () =>
      sortedStructureNames(structures, (structure) => {
        const text = normalizeStructureText(structureSearchText(structure));
        return (
          isSignalStructureName(text) &&
          (text.includes('geradeaus') ||
            text.includes('rechts') ||
            text.includes('links') ||
            text.includes('vorfahrt beachten') ||
            text.includes('gruen'))
        );
      }),
    [structures],
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
  const validation = useMemo(
    () => validateIntersectionWizardDraft(draft, scenarioStaticCameras, routeOptions, trafficLightModelOptions),
    [draft, routeOptions, scenarioStaticCameras, trafficLightModelOptions],
  );
  const previewErrors = useMemo(() => Array.from(new Set(validation.errors)), [validation.errors]);
  const previewWarnings = useMemo(() => [...validation.warnings, ...warnings], [validation.warnings, warnings]);
  const hasBlockingValidationErrors = validation.errors.length > 0;

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
  useApiDataRoomHandler(CeTypes.HubStructure, (payload: string) => {
    const data = JSON.parse(payload) as Record<string, StructureAppDto>;
    setStructures(Object.values(data).sort((a, b) => a.name.localeCompare(b.name, undefined, { numeric: true })));
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
          body: JSON.stringify(normalizeDraftLaneAssignments(draft)),
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
        body: JSON.stringify({ ...normalizeDraftLaneAssignments(draftToPersist), generatedLua }),
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

  useEffect(
    () => () => {
      Object.values(signalLookupTimers.current).forEach((timer) => window.clearTimeout(timer));
    },
    [],
  );

  async function lookupSignal(signalId: string): Promise<IntersectionWizardSignalLookupAppDto | undefined> {
    if (!signalId.trim()) return undefined;
    const response = await fetch(route(`/signals/${encodeURIComponent(signalId.trim())}`, socketUrl));
    if (!response.ok) return undefined;
    return (await response.json()) as IntersectionWizardSignalLookupAppDto;
  }

  function scheduleSignalLookup(key: string, signalId: string, lookup: () => void) {
    latestSignalLookupValues.current[key] = signalId.trim();
    const existingTimer = signalLookupTimers.current[key];
    if (existingTimer !== undefined) window.clearTimeout(existingTimer);
    if (positiveSignalId(signalId) === undefined) return;
    signalLookupTimers.current[key] = window.setTimeout(lookup, 300);
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
    return nextAmpelNameWithUsedNames(
      prefix,
      draft.ampeln.flatMap((ampel) => [ampel.name, ampel.pedestrianName ?? '']),
    );
  }

  function nextAmpelNameWithUsedNames(prefix: string, usedNames: string[]) {
    const usedNumbers = usedNames
      .map((name) => new RegExp(`^${prefix}(\\d+)$`, 'i').exec(name.trim())?.[1])
      .filter((value): value is string => Boolean(value))
      .map(Number);
    const used = new Set(usedNumbers);
    let nextNumber = 1;
    while (used.has(nextNumber)) nextNumber += 1;
    return `${prefix}${nextNumber}`;
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
    const changingToPedestrian = group.trafficType !== 'PEDESTRIAN' && nextGroup.trafficType === 'PEDESTRIAN';
    if (changingToPedestrian) {
      const usedNames = nextAmpeln.flatMap((ampel) => [ampel.name, ampel.pedestrianName ?? '']);
      nextAmpeln = nextAmpeln.map((ampel) => {
        if (!ampelIds.includes(ampel.id) || isStructureLightAmpel(ampel)) return ampel;
        const name = nextAmpelNameWithUsedNames('F', usedNames);
        usedNames.push(name);
        return {
          ...ampel,
          name,
          pedestrianName: undefined,
          sourceAmpelId: undefined,
          trafficType: 'PEDESTRIAN',
          use: 'PEDESTRIAN_ONLY',
          ...defaultModelForType('PEDESTRIAN'),
        };
      });
    }
    if (group.trafficType !== nextGroup.trafficType && ampelIds.length === 0) {
      const first = createAmpel(nextGroup.trafficType);
      nextAmpeln = [...nextAmpeln, first];
      ampelIds = [first.id];
    }
    const signalAmpelIds = ampelIds.filter((ampelId) => {
      const ampel = nextAmpeln.find((entry) => entry.id === ampelId);
      return Boolean(ampel && !isStructureLightAmpel(ampel));
    });
    if (nextGroup.trafficType === 'PEDESTRIAN' && signalAmpelIds.length < 2) {
      const usedNames = nextAmpeln.flatMap((ampel) => [ampel.name, ampel.pedestrianName ?? '']);
      const missing = Array.from({ length: 2 - signalAmpelIds.length }).map(() => {
        const name = nextAmpelNameWithUsedNames('F', usedNames);
        usedNames.push(name);
        return createAmpel('PEDESTRIAN', name);
      });
      nextAmpeln = [...nextAmpeln, ...missing];
      ampelIds = [...ampelIds, ...missing.map((ampel) => ampel.id)];
    }
    const nextSignalGroups = draft.signalGroups.map((entry) =>
      entry.id === id ? { ...nextGroup, ampelIds, pedestrianCrossingName: nextGroup.pedestrianCrossingName } : entry,
    );
    updateDraft({
      ampeln: nextAmpeln,
      signalGroups: nextSignalGroups,
      lanes: draft.lanes.map((lane) => ({
        ...lane,
        signalGroupSignalId: nextSignalGroups.some(
          (group) => group.id === lane.signalGroupSignalId && group.approach === lane.approach,
        )
          ? lane.signalGroupSignalId
          : undefined,
        signalGroupAssignments: effectiveLaneSignalGroupAssignments(lane, nextSignalGroups),
      })),
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

  function withAutomaticPedestrianSourceMatches(
    ampeln: IntersectionWizardAmpelAppDto[],
    changedAmpel: IntersectionWizardAmpelAppDto,
    signalId: string,
  ) {
    const numericSignalId = positiveSignalId(signalId);
    if (numericSignalId === undefined) return ampeln;
    if (isVehicleSourceAmpel(changedAmpel)) {
      return ampeln.map((ampel) =>
        ampel.id !== changedAmpel.id &&
        ampel.trafficType === 'PEDESTRIAN' &&
        !ampel.sourceAmpelId &&
        positiveSignalId(ampel.signalId) === numericSignalId
          ? { ...ampel, sourceAmpelId: changedAmpel.id, signalId: undefined, modelName: '', modelConstant: '' }
          : ampel,
      );
    }
    if (changedAmpel.trafficType !== 'PEDESTRIAN' || changedAmpel.sourceAmpelId) return ampeln;
    const sourceAmpel = ampeln.find(
      (ampel) =>
        ampel.id !== changedAmpel.id &&
        !isStructureLightAmpel(ampel) &&
        isVehicleSourceAmpel(ampel) &&
        positiveSignalId(ampel.signalId) === numericSignalId,
    );
    if (!sourceAmpel) return ampeln;
    return ampeln.map((ampel) =>
      ampel.id === changedAmpel.id
        ? { ...ampel, sourceAmpelId: sourceAmpel.id, signalId: undefined, modelName: '', modelConstant: '' }
        : ampel,
    );
  }

  async function updateAmpelSignalId(ampelId: string, signalId: string) {
    const lookupKey = `ampel:${ampelId}`;
    const lookupSignalId = signalId.trim();
    latestSignalLookupValues.current[lookupKey] = lookupSignalId;
    const lookup = await lookupSignal(lookupSignalId);
    if (latestSignalLookupValues.current[lookupKey] !== lookupSignalId) return;
    const signalPatch = {
      signalId,
      ...(lookup?.suggestedTrafficLightModel ? { modelName: lookup.suggestedTrafficLightModel } : {}),
      ...(lookup?.suggestedTrafficLightModelConstant
        ? { modelConstant: lookup.suggestedTrafficLightModelConstant }
        : {}),
    };
    setDraft((current) => {
      const currentAmpel = current.ampeln.find((entry) => entry.id === ampelId);
      if (!currentAmpel) return current;
      return {
        ...current,
        ampeln: withAutomaticPedestrianSourceMatches(
          current.ampeln.map((entry) => (entry.id === ampelId ? { ...entry, ...signalPatch } : entry)),
          { ...currentAmpel, ...signalPatch },
          signalId,
        ),
        updatedAt: new Date().toISOString(),
      };
    });
  }

  async function updateLaneSignalId(laneId: string, signalId: string) {
    const lookupKey = `lane:${laneId}`;
    const lookupSignalId = signalId.trim();
    latestSignalLookupValues.current[lookupKey] = lookupSignalId;
    const lookup = await lookupSignal(lookupSignalId);
    if (latestSignalLookupValues.current[lookupKey] !== lookupSignalId) return;
    setDraft((current) => ({
      ...current,
      lanes: current.lanes.map((lane) =>
        lane.id === laneId
          ? {
              ...lane,
              signal: {
                ...lane.signal,
                signalId,
                ...(lookup?.suggestedTrafficLightModel ? { modelName: lookup.suggestedTrafficLightModel } : {}),
                ...(lookup?.suggestedTrafficLightModelConstant
                  ? { modelConstant: lookup.suggestedTrafficLightModelConstant }
                  : {}),
              },
            }
          : lane,
      ),
      updatedAt: new Date().toISOString(),
    }));
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

  function updateAmpelLightStructure(ampel: IntersectionWizardAmpelAppDto, key: LightStructureKey, value: string) {
    const selectedStructure = structureByName.get(value);
    const selectedTag = selectedStructure?.tag ?? '';
    const housingFromSelection = key === 'structureHousing' && selectedStructure ? selectedStructure : undefined;
    const relatedHousing =
      housingFromSelection ?? structures.find((structure) => structureMatchesLightTag(structure, value, selectedTag));
    const sourceTag = relatedHousing?.tag || selectedTag;
    const tagPatch = structureSignalTagPatch(sourceTag);
    const baseStructure =
      key === 'structureHousing' && selectedStructure
        ? {
            structureBlend: '',
            structureGreen: '',
            structureRed: '',
            structureRequest: '',
            structureYellow: '',
          }
        : (ampel.lightStructures?.[0] ?? {});
    const structure = {
      ...baseStructure,
      ...tagPatch,
      ...(relatedHousing ? { structureHousing: relatedHousing.name } : {}),
      [key]: value,
    };
    patchAmpel(ampel.id, { lightStructures: [structure] });
  }

  function structureOptionsForField(optionKind: LightStructureField['optionKind']) {
    if (optionKind === 'HOUSING') return housingStructureOptions;
    if (optionKind === 'BLEND') return blendStructureOptions;
    if (optionKind === 'REQUEST') return requestStructureOptions;
    if (optionKind === 'RED') return redStructureOptions;
    if (optionKind === 'YELLOW') return yellowStructureOptions;
    return greenStructureOptions;
  }

  function alignStructureAmpelAtHousing(ampel: IntersectionWizardAmpelAppDto) {
    const structure = ampel.lightStructures?.[0];
    const housingName = structure?.structureHousing?.trim();
    if (!structure || !housingName) return;
    const housing = structureByName.get(housingName);
    const housingKind = inferHousingKind(housingName);
    if (!housing || !housingKind || signalCountForHousingKind(housingKind) === 0) return;
    const signals = [
      structure.structureRequest ?? '',
      structure.structureRed ?? '',
      structure.structureYellow ?? '',
      structure.structureGreen ?? '',
    ];
    socket.emit(
      RoadEvent.AlignStructureSignalInstaller,
      buildAlignStructureSignalInstallerCommand(housing, housingKind, signals, structure.structureBlend ?? ''),
    );
    setStatus('Ausrichtungsbefehl wurde an EEP gesendet.');
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
    if (!generatedLua || activeStep !== steps.length - 1 || hasBlockingValidationErrors) return;
    void navigator.clipboard.writeText(generatedLua);
    setStatus('Vollständiger Lua-Code kopiert.');
  }

  function copyIntersectionLua() {
    if (!generatedLua || activeStep !== steps.length - 1 || hasBlockingValidationErrors) return;
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
        Boolean(
          entry &&
          !isStructureLightAmpel(entry) &&
          isVehicleSourceAmpel(entry) &&
          (entry.id !== ampel.id || pedestrianSourceAmpel(group, ampel, draft.ampeln)?.id === entry.id),
        ),
      );
    const uniqueSameApproachAmpeln = sameApproachAmpeln.filter(
      (entry, index, entries) => entries.findIndex((candidate) => candidate.id === entry.id) === index,
    );
    if (!ampel.sourceAmpelId || uniqueSameApproachAmpeln.some((entry) => entry.id === ampel.sourceAmpelId)) {
      return uniqueSameApproachAmpeln;
    }
    const selected = draft.ampeln.find((entry) => entry.id === ampel.sourceAmpelId);
    return selected && !isStructureLightAmpel(selected) && isVehicleSourceAmpel(selected)
      ? [selected, ...uniqueSameApproachAmpeln]
      : uniqueSameApproachAmpeln;
  }

  function renderTurnDirectionToggle(
    group: IntersectionWizardSignalGroupAppDto,
    sx?: SxProps<Theme>,
    errorTexts?: string[],
  ) {
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
        errorTexts={errorTexts}
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
    const errors = validation.ampelErrors[ampel.id] ?? {};
    const nameValue = ampelNameForSignalGroup(group, ampel);
    const namePatch =
      group.trafficType === 'PEDESTRIAN'
        ? (name: string) => (isVehicleSourceAmpel(ampel) ? { pedestrianName: name } : { name, pedestrianName: name })
        : (name: string) => ({ name });
    const sourceAmpel = pedestrianSourceAmpel(group, ampel, draft.ampeln);
    return (
      <Stack spacing={1.25} sx={{ pt: 3, pb: 1.5, maxWidth: 720 }}>
        <FormTextfield
          label="Name"
          value={nameValue}
          size="small"
          infoText="Lua-Variablenname der Ampel."
          errorTexts={errors.name}
          inputProps={{ maxLength: 8, 'aria-label': `Ampelname ${nameValue}` }}
          onChange={(event) => patchAmpel(ampel.id, namePatch(event.target.value))}
        />
        {group.trafficType === 'PEDESTRIAN' && (
          <CompactToggleField
            label="Signal definieren"
            errorTexts={errors.sourceAmpelId}
            infoText="Vorhandene Ampeln mit Fußgängersignalen wiederverwenden"
          >
            <FormControl size="small" fullWidth error={Boolean(errors.sourceAmpelId?.length)}>
              <Select
                value={sourceAmpel?.id ?? '__OWN__'}
                inputProps={{ 'aria-label': `Quelle ${ampel.name}` }}
                onChange={(event) => {
                  const sourceAmpelId = event.target.value === '__OWN__' ? undefined : event.target.value;
                  if (sourceAmpelId === ampel.id) return;
                  patchAmpel(ampel.id, {
                    sourceAmpelId,
                    ...(sourceAmpelId ? { signalId: undefined, modelName: '', modelConstant: '' } : {}),
                    ...(!sourceAmpelId && !modelSelectValue(ampel) ? defaultModelForType('PEDESTRIAN') : {}),
                  });
                }}
              >
                <MenuItem value="__OWN__">Eigenes Signal</MenuItem>
                {sourceOptions.map((option) => (
                  <MenuItem key={option.id} value={option.id}>
                    {sourceSignalOptionLabel(option)}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </CompactToggleField>
        )}
        {!sourceAmpel && (
          <>
            <FormTextfield
              label="Signal-ID"
              value={ampel.signalId ?? ''}
              size="small"
              infoText="Signal-ID aus den Objekteigenschaften in EEP."
              errorTexts={errors.signalId}
              inputProps={{ inputMode: 'numeric', 'aria-label': `Signal-ID ${ampel.name}` }}
              onBlur={(event) => void updateAmpelSignalId(ampel.id, event.target.value)}
              onChange={(event) => {
                const signalId = event.target.value;
                patchAmpel(ampel.id, { signalId });
                scheduleSignalLookup(`ampel:${ampel.id}`, signalId, () => void updateAmpelSignalId(ampel.id, signalId));
              }}
            />
            <CompactToggleField
              label="Signal-Modell"
              errorTexts={errors.model}
              infoText="Notwendig für die Anzeige von rot, gelb, grün, usw."
            >
              <FormControl size="small" fullWidth error={Boolean(errors.model?.length)}>
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
          </>
        )}
      </Stack>
    );
  }

  function renderStructureAmpelEditor(ampel: IntersectionWizardAmpelAppDto) {
    const errors = validation.ampelErrors[ampel.id] ?? {};
    const structure = ampel.lightStructures?.[0] ?? {};
    const housing = structure.structureHousing ? structureByName.get(structure.structureHousing) : undefined;
    const housingKind = structure.structureHousing ? inferHousingKind(structure.structureHousing) : undefined;
    const canAlignAtHousing = Boolean(
      housing &&
      housingKind &&
      (structure.structureRed || structure.structureGreen || structure.structureYellow || structure.structureRequest),
    );
    return (
      <Stack spacing={1.25} sx={{ mt: 1, py: 1.5, maxWidth: 720 }}>
        <FormTextfield
          label="Name"
          value={ampel.name}
          size="small"
          infoText="Lua-Variablenname der Immobilien-Ampel."
          errorTexts={errors.name}
          inputProps={{ maxLength: 16, 'aria-label': `Ampelname ${ampel.name}` }}
          onChange={(event) => patchAmpel(ampel.id, { name: event.target.value })}
        />
        {lightStructureFields.map((field) => {
          const errorTexts = errors[field.key];
          return (
            <CompactToggleField
              key={field.key}
              label={field.label}
              infoText="Vollständiger Immobilienname aus EEP."
              errorTexts={errorTexts}
            >
              <Autocomplete<string, false, false, true>
                freeSolo
                options={structureOptionsForField(field.optionKind)}
                value={structure[field.key] ?? ''}
                inputValue={structure[field.key] ?? ''}
                onChange={(_event, value) => updateAmpelLightStructure(ampel, field.key, value ?? '')}
                onInputChange={(_event, value, reason) => {
                  if (reason === 'input' || reason === 'clear') updateAmpelLightStructure(ampel, field.key, value);
                }}
                renderInput={(params) => (
                  <TextField
                    {...params}
                    size="small"
                    error={Boolean(errorTexts?.length)}
                    inputProps={{ ...params.inputProps, 'aria-label': `${field.label} ${ampel.name}` }}
                  />
                )}
              />
            </CompactToggleField>
          );
        })}
        {canAlignAtHousing && (
          <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
            <Button
              size="small"
              variant="outlined"
              startIcon={<VerticalAlignCenterIcon />}
              onClick={() => alignStructureAmpelAtHousing(ampel)}
            >
              An Gehäuse ausrichten
            </Button>
          </Box>
        )}
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
                ampeln.map((ampel) => {
                  const isExpanded = expandedAmpelId === ampel.id;
                  const errorCount = validationErrorCount(validation.ampelErrors[ampel.id]);
                  const displayName = ampelNameForSignalGroup(group, ampel);
                  const sourceAmpel = pedestrianSourceAmpel(group, ampel, draft.ampeln);
                  return (
                    <ExpandableEditorTableRow
                      key={ampel.id}
                      ariaLabel={displayName}
                      expanded={isExpanded}
                      dataCellCount={3}
                      deletable={group.ampelIds.length > 1}
                      editor={renderSignalAmpelEditor(group, ampel)}
                      onDelete={() => removeAmpelFromGroup(group, ampel.id)}
                      onToggle={() => toggleExpandedAmpel(ampel.id)}
                    >
                      <TableCell>
                        <Badge
                          anchorOrigin={{ horizontal: 'left', vertical: 'top' }}
                          badgeContent={errorCount}
                          color="error"
                          invisible={isExpanded || errorCount === 0}
                          sx={{ pl: errorCount > 0 && !isExpanded ? 2 : 0, '& .MuiBadge-badge': { left: 0, top: 2 } }}
                        >
                          <Box component="span">{displayName || '-'}</Box>
                        </Badge>
                      </TableCell>
                      <TableCell>{sourceAmpel?.signalId || ampel.signalId || '-'}</TableCell>
                      <TableCell>
                        {sourceAmpel ? `${sourceAmpel.name} als ${displayName}` : modelSelectValue(ampel) || '-'}
                      </TableCell>
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
                <TableCell>Gehäuse</TableCell>
                <TableCell>Blende</TableCell>
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
                  <TableCell colSpan={9} sx={{ color: 'text.secondary' }}>
                    Noch keine EEP-Immobilien-Ampel hinzugefügt.
                  </TableCell>
                </TableRow>
              ) : (
                ampeln.map((ampel) => {
                  const isExpanded = expandedAmpelId === ampel.id;
                  const errorCount = validationErrorCount(validation.ampelErrors[ampel.id]);
                  const structure = ampel.lightStructures?.[0];
                  return (
                    <ExpandableEditorTableRow
                      key={ampel.id}
                      ariaLabel={ampel.name}
                      expanded={isExpanded}
                      dataCellCount={7}
                      deletable={group.ampelIds.length > 1}
                      editor={renderStructureAmpelEditor(ampel)}
                      onDelete={() => removeAmpelFromGroup(group, ampel.id)}
                      onToggle={() => toggleExpandedAmpel(ampel.id)}
                    >
                      <TableCell>
                        <Badge
                          anchorOrigin={{ horizontal: 'left', vertical: 'top' }}
                          badgeContent={errorCount}
                          color="error"
                          invisible={isExpanded || errorCount === 0}
                          sx={{ pl: errorCount > 0 && !isExpanded ? 2 : 0, '& .MuiBadge-badge': { left: 0, top: 2 } }}
                        >
                          <Box component="span">{ampel.name || '-'}</Box>
                        </Badge>
                      </TableCell>
                      <TableCell>{compactStructureName(structure?.structureHousing)}</TableCell>
                      <TableCell>{compactStructureName(structure?.structureBlend)}</TableCell>
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
        <Stack spacing={2} sx={{ bgcolor: 'grey.50', p: 1.5, borderRadius: 1 }}>
          {draft.signalGroups.length === 0 && (
            <FeedbackMessage severity="info">Lege mindestens eine Ampelgruppe an.</FeedbackMessage>
          )}
          {draft.signalGroups.map((group) => {
            const groupErrors = validation.signalGroupErrors[group.id] ?? {};
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
                  {[...(groupErrors.ampelIds ?? []), ...(groupErrors.turnDirections ?? [])].map((errorText) => (
                    <FeedbackMessage key={errorText} severity="error">
                      {errorText}
                    </FeedbackMessage>
                  ))}
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
                      {group.trafficType !== 'PEDESTRIAN' &&
                        renderTurnDirectionToggle(group, undefined, groupErrors.turnDirections)}
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
    const errors = validation.laneErrors[lane.id] ?? {};
    const effectiveAssignments = effectiveLaneSignalGroupAssignments(lane, draft.signalGroups);
    const selectableSignalGroupOptions = effectiveAssignments
      .map((assignment) => draft.signalGroups.find((group) => group.id === assignment.signalGroupId))
      .flatMap((group) => signalGroupLaneSignalOptionsForLane(group, lane, draft.ampeln));
    const selectedLaneSignalOption =
      selectableSignalGroupOptions.find(
        ({ group, ampel }) =>
          group.id === lane.signalGroupSignalId &&
          positiveSignalId(ampel.signalId) === positiveSignalId(lane.signal.signalId),
      ) ??
      selectableSignalGroupOptions.find(({ group }) => group.id === lane.signalGroupSignalId) ??
      selectableSignalGroupOptions.find(({ detected }) => detected);
    if (lane.signalSource === 'SIGNAL_GROUP') {
      return (
        <FormControl size="small" fullWidth error={Boolean(errors.signalGroupSignalId?.length)}>
          <Select
            value={
              selectedLaneSignalOption
                ? laneSignalOptionValue(selectedLaneSignalOption.group.id, selectedLaneSignalOption.ampel.id)
                : ''
            }
            inputProps={{ 'aria-label': `Fahrspursignal ${lane.name}` }}
            onChange={(event) => {
              const selectedOption = selectableSignalGroupOptions.find(
                ({ group, ampel }) => laneSignalOptionValue(group.id, ampel.id) === event.target.value,
              );
              if (!selectedOption) return;
              patchLane(lane.id, {
                signalGroupSignalId: selectedOption.group.id,
                signal: {
                  ...lane.signal,
                  name: ampelNameForSignalGroup(selectedOption.group, selectedOption.ampel),
                  signalId: selectedOption.ampel.signalId,
                  modelName: selectedOption.ampel.modelName,
                  modelConstant: selectedOption.ampel.modelConstant,
                  lightStructures: selectedOption.ampel.lightStructures,
                  axisStructures: selectedOption.ampel.axisStructures,
                },
              });
            }}
          >
            {selectableSignalGroupOptions.map(({ group, ampel }) => (
              <MenuItem key={`${group.id}-${ampel.id}`} value={laneSignalOptionValue(group.id, ampel.id)}>
                {group.name} ({ampelNameForSignalGroup(group, ampel)})
              </MenuItem>
            ))}
          </Select>
          {errors.signalGroupSignalId?.length && (
            <FormHelperText>
              <strong>{errors.signalGroupSignalId.join(' ')}</strong>
            </FormHelperText>
          )}
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
          errorTexts={errors.signalName}
          onChange={(event) => patchLane(lane.id, { signal: { ...lane.signal, name: event.target.value } })}
        />
        <FormTextfield
          label="Signal-ID"
          value={lane.signal.signalId ?? ''}
          size="small"
          infoText="Signal-ID aus den Objekteigenschaften in EEP."
          errorTexts={errors.signalId}
          inputProps={{ inputMode: 'numeric' }}
          onBlur={(event) => void updateLaneSignalId(lane.id, event.target.value)}
          onChange={(event) => {
            const signalId = event.target.value;
            patchLane(lane.id, { signal: { ...lane.signal, signalId } });
            scheduleSignalLookup(`lane:${lane.id}`, signalId, () => void updateLaneSignalId(lane.id, signalId));
          }}
        />
        <FormControl size="small" fullWidth error={Boolean(errors.signalModel?.length)}>
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
          {errors.signalModel?.length && (
            <FormHelperText>
              <strong>{errors.signalModel.join(' ')}</strong>
            </FormHelperText>
          )}
        </FormControl>
      </Box>
    );
  }

  function renderLaneAssignmentRows(lane: IntersectionWizardLaneAppDto, showAssignmentControls: boolean) {
    const availableGroups = availableSignalGroupsForLane(lane);
    const showSelectionCheckboxes = availableGroups.length > 1;
    const laneErrors = validation.laneErrors[lane.id] ?? {};
    const effectiveAssignments = effectiveLaneSignalGroupAssignments(lane, draft.signalGroups);
    return availableSignalGroupsForLane(lane).map((group) => {
      const assignment = effectiveAssignments.find((entry) => entry.signalGroupId === group.id);
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
                      <MenuItem value="DEFAULT">Standard-Ampelgruppe</MenuItem>
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
                      renderInput={(params) => (
                        <FormTextfield
                          {...params}
                          errorTexts={laneErrors.routeNames}
                          infoText="Routen für diese Zuweisung."
                        />
                      )}
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
    const nonPedestrianSignalGroups = draft.signalGroups.filter((group) => group.trafficType !== 'PEDESTRIAN');
    const signalGroupsWithoutMatchingLane = nonPedestrianSignalGroups.filter(
      (group) => !draft.lanes.some((lane) => lane.approach === group.approach),
    );
    const signalGroupsWithoutLaneAssignment = nonPedestrianSignalGroups.filter(
      (group) =>
        !draft.lanes.some((lane) =>
          effectiveLaneSignalGroupAssignments(lane, draft.signalGroups).some(
            (assignment) => assignment.signalGroupId === group.id,
          ),
        ),
    );
    const validApproaches = Array.from(new Set(nonPedestrianSignalGroups.map((group) => group.approach)));
    return (
      <Stack spacing={2}>
        <Stack direction="row" spacing={1} alignItems="center">
          <IconHeadline text="Fahrspuren" variant="h6" />
        </Stack>
        <Stack spacing={2} sx={{ bgcolor: 'grey.50', p: 1.5, borderRadius: 1 }}>
          {validApproaches.length === 0 && (
            <FeedbackMessage severity="warning">
              Lege zuerst mindestens eine Fahrzeug- oder Tram/Bus-Ampelgruppe an.
            </FeedbackMessage>
          )}
          {validApproaches.length > 0 && draft.lanes.length === 0 && (
            <FeedbackMessage severity="info">Lege mindestens eine Fahrspur an.</FeedbackMessage>
          )}
          {signalGroupsWithoutMatchingLane.length > 0 && (
            <FeedbackMessage severity="warning">
              Lege für diese Ampelgruppen eine Fahrspur mit gleicher Zufahrt an:{' '}
              {signalGroupsWithoutMatchingLane.map((group) => group.name).join(', ')}.
            </FeedbackMessage>
          )}
          {signalGroupsWithoutLaneAssignment.length > 0 && (
            <FeedbackMessage severity="warning">
              Wähle diese Ampelgruppen in den passenden Fahrspuren aus:{' '}
              {signalGroupsWithoutLaneAssignment.map((group) => group.name).join(', ')}.
            </FeedbackMessage>
          )}
          {draft.lanes.map((lane, laneIndex) => {
            const laneErrors = validation.laneErrors[lane.id] ?? {};
            const selectedAssignments = effectiveLaneSignalGroupAssignments(lane, draft.signalGroups);
            const showAssignmentControls = selectedAssignments.length > 1;
            const hasDefault = selectedAssignments.some((assignment) => assignment.mode === 'DEFAULT');
            const selectableSignalGroupOptions = selectedAssignments
              .map((assignment) => draft.signalGroups.find((group) => group.id === assignment.signalGroupId))
              .flatMap((group) => signalGroupLaneSignalOptionsForLane(group, lane, draft.ampeln));
            const defaultLaneSignalOption =
              selectableSignalGroupOptions.find(({ detected }) => detected) ?? selectableSignalGroupOptions[0];
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
                  {laneErrors.assignments?.map((errorText) => (
                    <FeedbackMessage key={errorText} severity="error">
                      {errorText}
                    </FeedbackMessage>
                  ))}
                  <IconHeadlineDelete
                    text={`Fahrspur ${lane.name} (${laneLuaDisplayName(
                      lane,
                      laneIndex,
                      draft.manualLuaVariableNames
                        ? draft.luaVariableName
                        : automaticIntersectionLuaVariableName(draft),
                      draft.manualLuaVariableNames === true,
                    )})`}
                    icon={<DirectionsCarIcon />}
                    variant="h6"
                    ariaLabel={`Fahrspur ${lane.name} löschen`}
                    onDelete={() => removeLane(lane.id)}
                  />
                  <WizardSectionTitle helper="Diese Angaben gelten für diese Fahrspur.">
                    Standort und Gültigkeit
                  </WizardSectionTitle>
                  <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' }, pt: 1, gap: 1.5 }}>
                    <FormTextfield
                      label="Fahrspurname"
                      value={lane.name}
                      size="small"
                      infoText="Name der Fahrspur im generierten Lua-Code."
                      errorTexts={laneErrors.name}
                      onChange={(event) => patchLane(lane.id, { name: event.target.value })}
                    />
                    <FormSelect
                      id={`${lane.id}-approach`}
                      label="Zufahrt"
                      value={lane.approach}
                      size="small"
                      infoText="Nur Richtungen mit Ampelgruppen können genutzt werden."
                      errorTexts={laneErrors.approach}
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
                    <WizardSectionTitle helper="Wähle Ampelgruppen deren Grün für diese Fahrspur gilt.">
                      Ampelgruppen
                    </WizardSectionTitle>
                    <Paper variant="outlined" sx={{ overflow: 'hidden' }}>
                      {renderLaneAssignmentRows(lane, showAssignmentControls)}
                    </Paper>
                  </Stack>
                  {selectedAssignments.length > 1 && !hasDefault && (
                    <FeedbackMessage severity={laneErrors.assignments?.length ? 'error' : 'warning'}>
                      Bei mehreren Ampelgruppen muss mindestens eine Standard-Ampelgruppe gewählt werden.
                    </FeedbackMessage>
                  )}
                  <Stack spacing={1} sx={{ pt: 1 }}>
                    <WizardSectionTitle helper="Gib das EEP-Signal an, dass diese Fahrspur steuert.">
                      Fahrspursignal
                    </WizardSectionTitle>
                    <ToggleButtonGroup
                      exclusive
                      size="small"
                      value={lane.signalSource}
                      onChange={(_event, value) => {
                        if (!value) return;
                        patchLane(lane.id, {
                          signalSource: value,
                          signalGroupSignalId:
                            value === 'SIGNAL_GROUP'
                              ? (defaultLaneSignalOption?.group.id ?? lane.signalGroupSignalId)
                              : undefined,
                          ...(value === 'SIGNAL_GROUP' && defaultLaneSignalOption
                            ? {
                                signal: {
                                  ...lane.signal,
                                  name: ampelNameForSignalGroup(
                                    defaultLaneSignalOption.group,
                                    defaultLaneSignalOption.ampel,
                                  ),
                                  signalId: defaultLaneSignalOption.ampel.signalId,
                                  modelName: defaultLaneSignalOption.ampel.modelName,
                                  modelConstant: defaultLaneSignalOption.ampel.modelConstant,
                                  lightStructures: defaultLaneSignalOption.ampel.lightStructures,
                                  axisStructures: defaultLaneSignalOption.ampel.axisStructures,
                                },
                              }
                            : {}),
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
                        disabled={selectableSignalGroupOptions.length === 0}
                        sx={{
                          '&.Mui-selected, &.Mui-selected:hover': selectedSignalGroupSx,
                        }}
                      >
                        Aus Ampelgruppe
                      </ToggleButton>
                    </ToggleButtonGroup>
                    <Box sx={{ pt: 1 }}>{renderLaneSignalFields(lane)}</Box>
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
          errorTexts={validation.settingsErrors}
          showAdvancedIntersectionSettings={showAdvancedIntersectionSettings}
          storageSlotOptions={storageSlotOptions}
          onDraftPatch={updateDraft}
          onIntersectionNameChange={(name) => updateDraft({ name })}
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
          phaseErrors={validation.phaseErrors}
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
  const showCodePreview = (draft.showLuaCodeImmediately ?? false) || isSummaryStep;

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
              steps={wizardSteps.map((label, index) => ({
                label,
                errorCount: index <= activeStep - 1 ? (validation.stepErrorCounts[index + 1] ?? 0) : 0,
              }))}
              onStepSelect={(index) => void persistAndNavigate(index + 1)}
            />
            {navigationButtons()}
            <Paper sx={{ p: 3 }}>{stepContent()}</Paper>
            {showCodePreview && isSummaryStep && (
              <IntersectionWizardCodePreview
                errors={previewErrors}
                lua={generatedLua}
                warnings={previewWarnings}
                copyEnabled={!hasBlockingValidationErrors}
                onCopyIntersection={copyIntersectionLua}
                onCopyAll={copyAllLua}
                fullWidth
              />
            )}
            {navigationButtons()}
          </Stack>
          {showCodePreview && !isSummaryStep && (
            <IntersectionWizardCodePreview
              errors={previewErrors}
              lua={generatedLua}
              warnings={previewWarnings}
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
