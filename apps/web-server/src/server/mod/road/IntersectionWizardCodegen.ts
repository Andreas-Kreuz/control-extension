import {
  IntersectionAppDto,
  IntersectionLaneAppDto,
  IntersectionTrafficLightAppDto,
  IntersectionWizardAmpelAppDto,
  IntersectionWizardApproach,
  IntersectionWizardDraftAppDto,
  IntersectionWizardLaneAppDto,
  IntersectionWizardLaneSignalAppDto,
  IntersectionWizardSignalGroupAppDto,
  IntersectionWizardTrafficType,
  IntersectionWizardTurnDirection,
} from '@ce/web-shared';

const turnDirectionSuffix: Record<IntersectionWizardTurnDirection, string> = {
  LEFT: 'Left',
  HALF_LEFT: 'HalfLeft',
  STRAIGHT: 'Straight',
  HALF_RIGHT: 'HalfRight',
  RIGHT: 'Right',
};

const turnDirectionOrder: Record<IntersectionWizardTurnDirection, number> = {
  LEFT: 0,
  HALF_LEFT: 1,
  STRAIGHT: 2,
  HALF_RIGHT: 3,
  RIGHT: 4,
};

const approachNameSuffix: Record<IntersectionWizardApproach, string> = {
  NORTH: 'North',
  NORTH_EAST: 'NorthEast',
  EAST: 'East',
  SOUTH_EAST: 'SouthEast',
  SOUTH: 'South',
  SOUTH_WEST: 'SouthWest',
  WEST: 'West',
  NORTH_WEST: 'NorthWest',
};

const trafficTypeSuffix: Record<IntersectionWizardTrafficType, string> = {
  CAR: 'Car',
  TRAM: 'Tram',
  PEDESTRIAN: 'Ped',
};

const trafficTypeSignalFunction: Record<IntersectionWizardTrafficType, string> = {
  CAR: 'addVehicleSignals',
  TRAM: 'addTramSignals',
  PEDESTRIAN: 'addPedestrianSignals',
};

const trafficTypeLuaType: Record<IntersectionWizardTrafficType, string> = {
  CAR: 'Lane.Type.CAR',
  TRAM: 'Lane.Type.TRAM',
  PEDESTRIAN: 'Lane.Type.PEDESTRIAN',
};

const routeRuleCall = {
  ONLY: 'driveOnlyOnSignalGroups',
  ALSO: 'driveAlsoOnSignalGroups',
} as const;

type LegacyTrafficType = IntersectionWizardTrafficType | 'BUS' | 'BICYCLE' | 'NORMAL';

interface LegacyDraftInput extends Partial<IntersectionWizardDraftAppDto> {
  pedestrianCrossings?: {
    id: string;
    name: string;
    luaVariableName?: string;
    approach?: IntersectionWizardApproach;
    heading?: IntersectionWizardApproach;
    signalGroupId: string;
  }[];
  routeRules?: {
    id: string;
    laneId: string;
    routeNames: string[];
    signalGroupIds: string[];
    mode: 'ONLY' | 'ALSO';
    showRequests: boolean;
  }[];
  defaultRequestDisplays?: { laneId: string; signalGroupId: string }[];
}

function sanitizeIdentifier(value: string, fallback: string): string {
  const ascii = value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^A-Za-z0-9_]+/g, '_')
    .replace(/^_+|_+$/g, '');
  const withFallback = ascii || fallback;
  return /^[A-Za-z_]/.test(withFallback) ? withFallback : `${fallback}_${withFallback}`;
}

function luaString(value: string): string {
  return `"${value.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`;
}

function lowerFirst(value: string): string {
  return value.charAt(0).toLowerCase() + value.slice(1);
}

function upperFirst(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1);
}

function uniqueIdentifier(preferred: string, fallback: string, used: Set<string>): string {
  const base = sanitizeIdentifier(preferred, fallback);
  let candidate = base;
  let suffix = 2;
  while (used.has(candidate)) {
    candidate = `${base}_${suffix}`;
    suffix += 1;
  }
  used.add(candidate);
  return candidate;
}

function ampelVariableName(
  ampel: IntersectionWizardAmpelAppDto,
  index: number,
  intersectionPrefix: string,
  used: Set<string>,
): string {
  const suffix = upperFirst(sanitizeIdentifier(trafficLightName(ampel), `K${index + 1}`));
  return uniqueIdentifier(`${intersectionPrefix}${suffix}`, `${intersectionPrefix}K${index + 1}`, used);
}

function laneSignalVariableName(index: number, intersectionPrefix: string, used: Set<string>): string {
  return uniqueIdentifier(`${intersectionPrefix}Lane${index + 1}Signal`, `lane${index + 1}Signal`, used);
}

function laneVariableName(
  lane: IntersectionWizardLaneAppDto,
  index: number,
  intersectionPrefix: string,
  used: Set<string>,
  useManualLuaVariableNames: boolean,
): string {
  if (useManualLuaVariableNames && lane.luaVariableName?.trim()) {
    return uniqueIdentifier(lane.luaVariableName, `lane${index + 1}`, used);
  }
  return uniqueIdentifier(`${intersectionPrefix}Lane${index + 1}`, `lane${index + 1}`, used);
}

function pedestrianCrossingVariableName(
  group: IntersectionWizardSignalGroupAppDto,
  index: number,
  intersectionPrefix: string,
  used: Set<string>,
  useManualLuaVariableNames: boolean,
): string {
  if (useManualLuaVariableNames && group.pedestrianCrossingLuaVariableName?.trim()) {
    return uniqueIdentifier(group.pedestrianCrossingLuaVariableName, `pedCrossing${index + 1}`, used);
  }
  const prefix = lowerFirst(sanitizeIdentifier(intersectionPrefix, 'kreuzung'));
  const base = `${prefix}Ped${approachNameSuffix[group.approach]}`;
  let candidate = base;
  let suffix = 2;
  while (used.has(candidate)) {
    candidate = `${base}${suffix}`;
    suffix += 1;
  }
  used.add(candidate);
  return candidate;
}

function signalGroupVariableName(
  group: IntersectionWizardSignalGroupAppDto,
  index: number,
  intersectionPrefix: string,
  used: Set<string>,
  useManualLuaVariableNames: boolean,
): string {
  return uniqueIdentifier(
    useManualLuaVariableNames && group.luaVariableName?.trim()
      ? group.luaVariableName
      : `${intersectionPrefix}${upperFirst(group.name)}`,
    `sg${index + 1}`,
    used,
  );
}

function isApproach(value: string | undefined): value is IntersectionWizardApproach {
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

function normalizeApproach(approach: string | undefined, legacyHeading?: string): IntersectionWizardApproach {
  if (isApproach(approach)) return approach;
  if (isApproach(legacyHeading)) return oppositeApproach[legacyHeading];
  return 'SOUTH';
}

function normalizeTrafficType(type: string | undefined): IntersectionWizardTrafficType {
  if (type === 'TRAM' || type === 'BUS') return 'TRAM';
  if (type === 'PEDESTRIAN') return 'PEDESTRIAN';
  return 'CAR';
}

function normalizeDirection(direction: string): IntersectionWizardTurnDirection | undefined {
  if (direction === 'LEFT') return 'LEFT';
  if (direction === 'HALF_LEFT' || direction === 'HALF-LEFT') return 'HALF_LEFT';
  if (direction === 'STRAIGHT') return 'STRAIGHT';
  if (direction === 'HALF_RIGHT' || direction === 'HALF-RIGHT') return 'HALF_RIGHT';
  if (direction === 'RIGHT') return 'RIGHT';
  return undefined;
}

function normalizeDirections(directions: string[] | undefined): IntersectionWizardTurnDirection[] {
  const normalized = (directions ?? [])
    .map(normalizeDirection)
    .filter((direction): direction is IntersectionWizardTurnDirection => direction !== undefined);
  return normalized.length > 0 ? normalized : ['STRAIGHT'];
}

function normalizeOptionalDirections(directions: string[] | undefined): IntersectionWizardTurnDirection[] | undefined {
  if (!directions) return undefined;
  return directions
    .map(normalizeDirection)
    .filter((direction): direction is IntersectionWizardTurnDirection => direction !== undefined);
}

function directionWordsFromText(value: string | undefined): IntersectionWizardTurnDirection[] {
  const text = (value ?? '').toLocaleLowerCase();
  const directions: IntersectionWizardTurnDirection[] = [];
  if (text.includes('links') || text.includes('left')) directions.push('LEFT');
  if (text.includes('geradeaus') || text.includes('straight')) directions.push('STRAIGHT');
  if (text.includes('rechts') || text.includes('right')) directions.push('RIGHT');
  return directions;
}

function inferTurnDirectionsFromGreenLightStructures(
  ampeln: IntersectionWizardAmpelAppDto[],
  ampelIds: string[],
): IntersectionWizardTurnDirection[] {
  const directions = new Set<IntersectionWizardTurnDirection>();
  ampelIds.forEach((ampelId) => {
    const ampel = ampeln.find((entry) => entry.id === ampelId);
    ampel?.lightStructures?.forEach((structure) => {
      directionWordsFromText(structure.structureGreen).forEach((direction) => directions.add(direction));
    });
  });
  return orderedTurnDirections(Array.from(directions));
}

function orderedTurnDirections(directions: IntersectionWizardTurnDirection[]): IntersectionWizardTurnDirection[] {
  return [...directions].sort((a, b) => turnDirectionOrder[a] - turnDirectionOrder[b]);
}

export function signalGroupName(
  approach: IntersectionWizardApproach,
  trafficType: IntersectionWizardTrafficType,
  turnDirections: IntersectionWizardTurnDirection[],
): string {
  const directionSuffix =
    trafficType === 'PEDESTRIAN'
      ? ''
      : orderedTurnDirections(turnDirections)
          .map((direction) => turnDirectionSuffix[direction])
          .join('');
  return `sg${approachNameSuffix[approach]}${trafficTypeSuffix[trafficType]}${directionSuffix}`;
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

function luaTurnDirections(directions: IntersectionWizardTurnDirection[]): string {
  return directions.map((direction) => `Lane.Directions.${direction}`).join(', ');
}

function automaticIntersectionVariableName(draft: IntersectionWizardDraftAppDto): string {
  return /^c\d+$/i.test(draft.luaVariableName.trim()) ? draft.luaVariableName : 'c1';
}

function modelExpression(model: { modelConstant?: string; modelName?: string }): string {
  if (model.modelConstant) return `TrafficLightModel.${model.modelConstant}`;
  if (model.modelName === 'NO SIGNAL MODEL') return 'TrafficLightModel.NONE';
  return `TrafficLightModel.${sanitizeIdentifier(model.modelName ?? 'JS2_3er_mit_FG', 'JS2_3er_mit_FG')}`;
}

function luaValue(value: string | number | undefined): string {
  if (value === undefined) return 'nil';
  if (typeof value === 'number') return String(value);
  return luaString(value);
}

function positiveSignalId(signalId: string | undefined): number | undefined {
  const numeric = Number(signalId);
  return Number.isInteger(numeric) && numeric > 0 ? numeric : undefined;
}

function ampelKind(ampel: IntersectionWizardAmpelAppDto): NonNullable<IntersectionWizardAmpelAppDto['kind']> {
  if (ampel.kind) return ampel.kind;
  return positiveSignalId(ampel.signalId) === undefined && lightStructures(ampel).length > 0
    ? 'STRUCTURE_LIGHT'
    : 'SIGNAL';
}

function trafficLightName(ampel: IntersectionWizardAmpelAppDto): string {
  return ampel.trafficType === 'PEDESTRIAN' || ampel.use === 'PEDESTRIAN_ONLY'
    ? (ampel.pedestrianName ?? ampel.name)
    : ampel.name;
}

function lightStructures(ampel: IntersectionWizardAmpelAppDto | IntersectionWizardLaneSignalAppDto) {
  return ampel.lightStructures ?? [];
}

function isPlainLightStructure(ampel: IntersectionWizardAmpelAppDto | IntersectionWizardLaneSignalAppDto): boolean {
  if ('kind' in ampel && ampelKind(ampel) === 'STRUCTURE_LIGHT') return lightStructures(ampel).length > 0;
  return (
    positiveSignalId(ampel.signalId) === undefined &&
    lightStructures(ampel).length > 0 &&
    (ampel.axisStructures ?? []).length === 0
  );
}

function trafficLightBaseConstructor(ampel: IntersectionWizardAmpelAppDto): string {
  if (ampelKind(ampel) === 'STRUCTURE_LIGHT') {
    const structure = ampel.lightStructures?.[0] ?? {};
    return plainLightStructureConstructor(ampel.name, structure);
  }
  const signalId = positiveSignalId(ampel.signalId) ?? 0;
  return `TrafficLight:newForSignal(${luaString(trafficLightName(ampel))}, ${signalId}, ${modelExpression(ampel)})`;
}

function laneSignalBaseConstructor(signal: IntersectionWizardLaneSignalAppDto): string {
  if (isPlainLightStructure(signal)) {
    const structure = signal.lightStructures?.[0] ?? {};
    return plainLightStructureConstructor(signal.name, structure);
  }
  return `TrafficLight:newForSignal(${luaString(signal.name)}, ${
    positiveSignalId(signal.signalId) ?? 0
  }, ${modelExpression(signal)})`;
}

function plainLightStructureConstructor(
  name: string,
  structure: NonNullable<IntersectionWizardAmpelAppDto['lightStructures']>[number],
) {
  const args = [
    luaValue(structure.structureRed),
    luaValue(structure.structureGreen),
    luaValue(structure.structureYellow),
    luaValue(structure.structureRequest),
  ];
  if (structure.structureHousing || structure.structureBlend) {
    args.push(luaValue(structure.structureHousing), luaValue(structure.structureBlend));
  }
  return `TrafficLight:newForLightStructure(${luaString(name)},\n    ${args.join(',\n    ')}\n)`;
}

function axisStructureCalls(ampel: IntersectionWizardAmpelAppDto | IntersectionWizardLaneSignalAppDto): string[] {
  return (ampel.axisStructures ?? []).map(
    (structure) =>
      `addAxisStructure(${[
        luaValue(structure.structureName),
        luaValue(structure.axisName),
        luaValue(structure.positionDefault),
        luaValue(structure.positionRed),
        luaValue(structure.positionGreen),
        luaValue(structure.positionYellow),
        luaValue(structure.positionRedYellow),
        luaValue(structure.positionPedestrian),
      ].join(', ')})`,
  );
}

function trafficLightChainCalls(ampel: IntersectionWizardAmpelAppDto | IntersectionWizardLaneSignalAppDto): string[] {
  return axisStructureCalls(ampel);
}

function sortedDeclarationLines(entries: { variable: string; line: string }[]): string[] {
  return entries
    .sort((a, b) => a.variable.localeCompare(b.variable, undefined, { numeric: true }))
    .map((entry) => entry.line);
}

function chainCall(base: string, calls: string[]): string {
  if (calls.length === 0) return base;
  return `${base}\n${calls.map((call) => `    :${call}`).join('\n')}`;
}

function phaseCall(
  intersectionVar: string,
  phaseName: string,
  groupVarList: string[],
  greenTimeSeconds?: number,
): string {
  const newPhase =
    greenTimeSeconds !== undefined
      ? `${intersectionVar}:newPhase(${luaString(phaseName)}, ${greenTimeSeconds})`
      : `${intersectionVar}:newPhase(${luaString(phaseName)})`;
  if (groupVarList.length <= 1) return chainCall(newPhase, [`addSignalGroups(${groupVarList.join(', ')})`]);
  return chainCall(newPhase, [`addSignalGroups(\n        ${groupVarList.join(',\n        ')}\n    )`]);
}

function intersectionConstructor(draft: IntersectionWizardDraftAppDto): string {
  const args = [luaString(draft.name)];
  if (draft.greenTimeSeconds !== undefined) args.push(String(draft.greenTimeSeconds));
  return `Intersection:new(${args.join(', ')})`;
}

function staticCamsCall(draft: IntersectionWizardDraftAppDto): string[] {
  const staticCams = (draft.staticCams ?? []).filter((cameraName) => cameraName.trim());
  if (staticCams.length === 0) return [];
  if (staticCams.length === 1) return [`addStaticCams(${luaString(staticCams[0]!)})`];
  return [`addStaticCams(\n        ${staticCams.map(luaString).join(',\n        ')}\n    )`];
}

function intersectionChainCalls(draft: IntersectionWizardDraftAppDto, variableName: string): string[] {
  return [
    `setScriptVariableName(${luaString(variableName)})`,
    ...(draft.tippStructure ? [`setTippStructure(${luaString(draft.tippStructure)})`] : []),
    `withStorage(${draft.intersectionEepSaveId ?? -1})`,
    ...staticCamsCall(draft),
    ...(draft.switchInStrictOrder ? ['setSwitchInStrictOrder(true)'] : []),
  ];
}

function indentBlock(lines: string[]): string[] {
  return lines.map((line) =>
    line
      .split('\n')
      .map((part) => (part ? `    ${part}` : part))
      .join('\n'),
  );
}

function assignedGroups(draft: IntersectionWizardDraftAppDto, lane: IntersectionWizardLaneAppDto) {
  return lane.signalGroupAssignments
    .map((assignment) => ({
      assignment,
      group: draft.signalGroups.find((signalGroup) => signalGroup.id === assignment.signalGroupId),
    }))
    .filter((entry): entry is typeof entry & { group: IntersectionWizardSignalGroupAppDto } => Boolean(entry.group));
}

function laneTrafficType(
  draft: IntersectionWizardDraftAppDto,
  lane: IntersectionWizardLaneAppDto,
): IntersectionWizardTrafficType {
  const groupTypes = assignedGroups(draft, lane)
    .map((entry) => entry.group.trafficType)
    .filter((type) => type !== 'PEDESTRIAN');
  return groupTypes.find((type) => type === 'TRAM') ?? groupTypes[0] ?? 'CAR';
}

function derivedLaneApproachFromSignalGroups(
  signalGroups: IntersectionWizardSignalGroupAppDto[],
  lane: IntersectionWizardLaneAppDto,
): IntersectionWizardApproach {
  return (
    lane.signalGroupAssignments
      .map((assignment) => signalGroups.find((signalGroup) => signalGroup.id === assignment.signalGroupId))
      .find((group) => group?.trafficType !== 'PEDESTRIAN')?.approach ?? lane.approach
  );
}

function signalGroupAddCall(group: IntersectionWizardSignalGroupAppDto, signalVars: string[]): string {
  return `${trafficTypeSignalFunction[group.trafficType]}(${signalVars.join(', ')})`;
}

function signalGroupLaneSignalAmpelIds(
  draft: IntersectionWizardDraftAppDto,
  group: IntersectionWizardSignalGroupAppDto,
): string[] {
  const positiveSignalAmpelIds = group.ampelIds.filter((ampelId) => {
    const ampel = draft.ampeln.find((entry) => entry.id === ampelId);
    return Boolean(ampel && ampelKind(ampel) !== 'STRUCTURE_LIGHT' && positiveSignalId(ampel.signalId) !== undefined);
  });
  if (positiveSignalAmpelIds.length > 0) return positiveSignalAmpelIds;
  return group.ampelIds.length === 1 ? group.ampelIds : [];
}

function signalGroupLaneSignalAmpelId(
  draft: IntersectionWizardDraftAppDto,
  group: IntersectionWizardSignalGroupAppDto,
  lane: IntersectionWizardLaneAppDto,
): string | undefined {
  const laneSignalId = positiveSignalId(lane.signal.signalId);
  if (laneSignalId !== undefined) {
    const matchingAmpelId = group.ampelIds.find((ampelId) => {
      const ampel = draft.ampeln.find((entry) => entry.id === ampelId);
      return Boolean(
        ampel && ampelKind(ampel) !== 'STRUCTURE_LIGHT' && positiveSignalId(ampel.signalId) === laneSignalId,
      );
    });
    if (matchingAmpelId) return matchingAmpelId;
  }
  const signalAmpelIds = signalGroupLaneSignalAmpelIds(draft, group);
  return signalAmpelIds.length === 1 ? signalAmpelIds[0] : undefined;
}

function signalGroupMetadataCalls(group: IntersectionWizardSignalGroupAppDto, variableName: string): string[] {
  return [
    `setScriptVariableName(${luaString(variableName)})`,
    `setApproach(Lane.Approach.${group.approach})`,
    ...(group.trafficType === 'PEDESTRIAN' || group.turnDirections.length === 0
      ? []
      : [`setTurnDirections(${luaTurnDirections(group.turnDirections)})`]),
  ];
}

export function generateIntersectionWizardLua(draft: IntersectionWizardDraftAppDto): {
  lua: string;
  warnings: string[];
} {
  const useManualLuaVariableNames = draft.manualLuaVariableNames === true;
  const prefix = useManualLuaVariableNames
    ? sanitizeIdentifier(draft.luaVariableName || 'kreuzung', 'kreuzung')
    : lowerFirst(sanitizeIdentifier(automaticIntersectionVariableName(draft), 'c1'));
  const crossingCommentName = draft.name.trim() ? ` (${draft.name.trim()})` : '';
  const warnings: string[] = [];
  const vehicleAmpelVars = new Map<string, string>();
  const pedestrianAmpelVars = new Map<string, string>();
  const lightStructureAmpelVars = new Map<string, string[]>();
  const groupVars = new Map<string, string>();
  const laneVars = new Map<string, string>();
  const laneSignalVars = new Map<string, string>();
  const pedestrianCrossingVars = new Map<string, string>();
  const usedAmpelVars = new Set<string>();
  const usedLaneVars = new Set<string>();
  const usedGroupVars = new Set<string>();
  const usedCrossingVars = new Set<string>();

  draft.lanes.forEach((lane, index) => {
    laneVars.set(lane.id, laneVariableName(lane, index, prefix, usedLaneVars, useManualLuaVariableNames));
  });

  const lines: string[] = [
    '-- Von der Control Extension erzeugter Kreuzungs-Setup-Code',
    'local Lane = require("ce.mods.road.Lane")',
    'local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")',
    'local Intersection = require("ce.mods.road.Intersection")',
    'local TrafficLight = require("ce.mods.road.TrafficLight")',
    'local TrafficLightModel = require("ce.mods.road.TrafficLightModel")',
    '',
    `-- START Kreuzung ${prefix}${crossingCommentName}`,
    'do',
  ];
  const bodyLines: string[] = [
    '-- Kreuzung',
    `local ${prefix} = ${chainCall(intersectionConstructor(draft), intersectionChainCalls(draft, prefix))}`,
    '',
    '-- Ampeln',
  ];
  const ampelLines: { variable: string; line: string }[] = [];
  const pedestrianAmpelLines: { variable: string; line: string }[] = [];

  draft.ampeln.forEach((ampel, index) => {
    if (ampel.use === 'PEDESTRIAN_ONLY' || ampel.trafficType === 'PEDESTRIAN') return;
    const variable = ampelVariableName(ampel, index, prefix, usedAmpelVars);
    ampelLines.push({
      variable,
      line: `local ${variable} = ${chainCall(trafficLightBaseConstructor(ampel), trafficLightChainCalls(ampel))}`,
    });
    vehicleAmpelVars.set(ampel.id, variable);
    if (ampel.use === 'VEHICLE_AND_PEDESTRIAN') {
      const pedestrianVariable = uniqueIdentifier(
        `${prefix}${upperFirst(sanitizeIdentifier(ampel.pedestrianName || `F${index + 1}`, `F${index + 1}`))}`,
        `${prefix}F${index + 1}`,
        usedAmpelVars,
      );
      pedestrianAmpelVars.set(ampel.id, pedestrianVariable);
      pedestrianAmpelLines.push({
        variable: pedestrianVariable,
        line: `local ${pedestrianVariable} = ${variable}:withPedestrian(${luaString(ampel.pedestrianName || pedestrianVariable)})`,
      });
    }
    const extraLightStructures = lightStructures(ampel).slice(isPlainLightStructure(ampel) ? 1 : 0);
    const extraLightVars = extraLightStructures.map((structure, lightIndex) => {
      const lightVariable = uniqueIdentifier(
        `${variable}Light${lightIndex + 1}`,
        `${variable}Light${lightIndex + 1}`,
        usedAmpelVars,
      );
      ampelLines.push({
        variable: lightVariable,
        line: `local ${lightVariable} = ${plainLightStructureConstructor(`${ampel.name}Light${lightIndex + 1}`, structure)}`,
      });
      return lightVariable;
    });
    if (extraLightVars.length > 0) lightStructureAmpelVars.set(ampel.id, extraLightVars);
  });
  draft.ampeln.forEach((ampel, index) => {
    if (ampel.use !== 'PEDESTRIAN_ONLY' && ampel.trafficType !== 'PEDESTRIAN') return;
    const variable = ampelVariableName(ampel, index, prefix, usedAmpelVars);
    const sourceVariable = ampel.sourceAmpelId ? vehicleAmpelVars.get(ampel.sourceAmpelId) : undefined;
    if (ampel.sourceAmpelId && sourceVariable) {
      const name = trafficLightName(ampel);
      pedestrianAmpelLines.push({
        variable,
        line: `local ${variable} = ${sourceVariable}:withPedestrian(${luaString(name)})`,
      });
      pedestrianAmpelVars.set(ampel.id, variable);
      return;
    }
    pedestrianAmpelLines.push({
      variable,
      line: `local ${variable} = ${chainCall(trafficLightBaseConstructor(ampel), trafficLightChainCalls(ampel))}`,
    });
    pedestrianAmpelVars.set(ampel.id, variable);
  });
  bodyLines.push(...sortedDeclarationLines(ampelLines));
  if (pedestrianAmpelLines.length > 0) {
    bodyLines.push('', '-- Fussg.-Ampeln', ...sortedDeclarationLines(pedestrianAmpelLines));
  }

  const laneSignalLines: { variable: string; line: string }[] = [];
  draft.lanes.forEach((lane, index) => {
    const laneVariable = laneVars.get(lane.id);
    if (!laneVariable) return;
    const variable = laneSignalVariableName(index, prefix, usedAmpelVars);
    laneSignalVars.set(lane.id, variable);
    if (lane.signalSource === 'SIGNAL_GROUP') {
      const group = draft.signalGroups.find((entry) => entry.id === lane.signalGroupSignalId);
      const signalAmpelId = group ? signalGroupLaneSignalAmpelId(draft, group, lane) : undefined;
      if (!signalAmpelId) {
        laneSignalLines.push({ variable, line: `local ${variable} = nil` });
        return;
      }
      laneSignalLines.push({
        variable,
        line: `local ${variable} = ${vehicleAmpelVars.get(signalAmpelId) ?? 'nil'}`,
      });
      return;
    }
    laneSignalLines.push({
      variable,
      line: `local ${variable} = ${chainCall(laneSignalBaseConstructor(lane.signal), trafficLightChainCalls(lane.signal))}`,
    });
  });
  if (laneSignalLines.length > 0) {
    bodyLines.push('', '-- Fahrspur-Ampeln');
    bodyLines.push(...sortedDeclarationLines(laneSignalLines));
  }

  bodyLines.push('', '-- Fahrspuren');
  draft.lanes.forEach((lane) => {
    const variable = laneVars.get(lane.id);
    if (!variable) return;
    const laneSignalExpression = laneSignalVars.get(lane.id) ?? 'nil';
    const type = laneTrafficType(draft, lane);
    const requestTrackIds = lane.requestTrackIds ?? [];
    const highlightTrackIds = lane.highlightTrackIds ?? [];
    const chainCalls = [
      `setScriptVariableName(${luaString(variable)})`,
      ...(type === 'CAR' ? [] : [`setTrafficType(${trafficTypeLuaType[type]})`]),
      ...(lane.vehicleMultiplier && lane.vehicleMultiplier !== 1
        ? [`setVehicleMultiplier(${lane.vehicleMultiplier})`]
        : []),
      ...(lane.countType === 'SIGNALS' ? ['useSignalForQueue()'] : []),
      ...(lane.countType === 'TRACKS' ? requestTrackIds.map((trackId) => `useTrackForQueue(${trackId})`) : []),
      ...(highlightTrackIds.length > 0 ? [`setHighlightTracks(${highlightTrackIds.join(', ')})`] : []),
    ];
    bodyLines.push(
      `${variable} = ${chainCall(`${prefix}:newLane(${luaString(lane.name)}, ${laneSignalExpression})`, chainCalls)}`,
    );
  });

  const pedestrianGroups = draft.signalGroups.filter((group) => group.trafficType === 'PEDESTRIAN');
  if (pedestrianGroups.length > 0) {
    bodyLines.push('', '-- Fussgaengerfurten');
    pedestrianGroups.forEach((group, index) => {
      const variable = pedestrianCrossingVariableName(
        group,
        index,
        prefix,
        usedCrossingVars,
        useManualLuaVariableNames,
      );
      pedestrianCrossingVars.set(group.id, variable);
      bodyLines.push(
        `local ${variable} = ${chainCall(
          `${prefix}:newPedestrianCrossing(${luaString(group.pedestrianCrossingName || group.name)})`,
          [
            `setScriptVariableName(${luaString(variable)})`,
            `setApproach(PedestrianCrossing.Approach.${group.approach})`,
          ],
        )}`,
      );
    });
  }

  bodyLines.push('', '-- Ampelgruppen');
  draft.signalGroups.forEach((group, index) => {
    const variable = signalGroupVariableName(group, index, prefix, usedGroupVars, useManualLuaVariableNames);
    groupVars.set(group.id, variable);
    const signalVars = group.ampelIds
      .flatMap((id) => {
        const mainVar = group.trafficType === 'PEDESTRIAN' ? pedestrianAmpelVars.get(id) : vehicleAmpelVars.get(id);
        return [mainVar, ...(lightStructureAmpelVars.get(id) ?? [])];
      })
      .filter((value): value is string => Boolean(value));
    const signalGroupCalls = [
      ...signalGroupMetadataCalls(group, variable),
      ...(group.trafficType === 'PEDESTRIAN'
        ? [`addPedestrianCrossings(${pedestrianCrossingVars.get(group.id) ?? 'nil'})`]
        : []),
      signalGroupAddCall(group, signalVars),
    ];
    bodyLines.push(
      `local ${variable} = ${chainCall(`${prefix}\n    :newSignalGroup(${luaString(group.name)})`, signalGroupCalls)}`,
    );
  });

  bodyLines.push('', '-- Zuordnung der Ampelgruppen zu Fahrspuren');
  draft.lanes.forEach((lane) => {
    const assignments = assignedGroups(draft, lane);
    const defaultGroupVars = assignments
      .filter((entry) => entry.assignment.mode === 'DEFAULT')
      .map((entry) => groupVars.get(entry.group.id))
      .filter((value): value is string => Boolean(value));
    if (assignments.length > 1 && defaultGroupVars.length === 0) {
      warnings.push(`${lane.name}: Mehrere Ampelgruppen erfordern mindestens eine Standard-Ampelgruppe.`);
    }
    if (defaultGroupVars.length > 0) {
      const requestGroupVars = assignments
        .filter((entry) => entry.assignment.mode === 'DEFAULT' && entry.group.showRequests)
        .map((entry) => groupVars.get(entry.group.id))
        .filter((value): value is string => Boolean(value));
      const calls = requestGroupVars.length > 0 ? [`showRequestsOnSignalGroups(${requestGroupVars.join(', ')})`] : [];
      bodyLines.push(
        chainCall(`${laneVars.get(lane.id)}:driveOnDefaultSignalGroups(${defaultGroupVars.join(', ')})`, calls),
      );
    }
  });

  const routeAssignments = draft.lanes.flatMap((lane) =>
    assignedGroups(draft, lane)
      .filter((entry) => entry.assignment.mode === 'ONLY' || entry.assignment.mode === 'ALSO')
      .map((entry) => ({ lane, ...entry })),
  );
  if (routeAssignments.length > 0) {
    bodyLines.push('', '-- Routenabhängige Fahrregeln');
    routeAssignments.forEach(({ lane, assignment, group }) => {
      const laneVar = laneVars.get(lane.id);
      const groupVar = groupVars.get(group.id);
      const routeNames = assignment.routeNames ?? [];
      if (!laneVar || !groupVar || routeNames.length === 0) return;
      const mode = assignment.mode === 'ALSO' ? 'ALSO' : 'ONLY';
      const calls = [`${routeRuleCall[mode]}(${groupVar})`];
      if (group.showRequests) calls.push(`showRequestsOnSignalGroups(${groupVar})`);
      bodyLines.push(chainCall(`${laneVar}:routes(${routeNames.map(luaString).join(', ')})`, calls));
    });
  }

  bodyLines.push('', '-- Verkehrsphasen');
  draft.phases.forEach((phase) => {
    const groupVarList = phase.signalGroupIds
      .map((id) => groupVars.get(id))
      .filter((value): value is string => Boolean(value));
    bodyLines.push(phaseCall(prefix, phase.name, groupVarList, phase.greenTimeSeconds));
  });
  lines.push(...indentBlock(bodyLines), 'end', `-- END Kreuzung ${prefix}${crossingCommentName}`);

  return { lua: lines.join('\n'), warnings };
}

function draftSignalFromTrafficLight(
  trafficLight: IntersectionWizardAmpelAppDto | undefined,
  fallbackSignalId: string,
  fallbackName: string,
): IntersectionWizardLaneSignalAppDto {
  return {
    name: trafficLight?.name || fallbackName,
    ...(positiveSignalId(trafficLight?.signalId ?? fallbackSignalId) !== undefined
      ? { signalId: trafficLight?.signalId ?? fallbackSignalId }
      : {}),
    modelName: trafficLight?.modelName ?? 'Unsichtbar_2er',
    modelConstant: trafficLight?.modelConstant ?? 'Unsichtbar_2er',
    lightStructures: trafficLight?.lightStructures ?? [],
    axisStructures: trafficLight?.axisStructures ?? [],
  };
}

export function createDraftFromCurrentIntersection(
  intersection: IntersectionAppDto,
  lanes: IntersectionLaneAppDto[],
  ampeln: IntersectionTrafficLightAppDto[],
): IntersectionWizardDraftAppDto {
  const now = new Date().toISOString();
  const prefix = sanitizeIdentifier(
    intersection.scriptVariableName || intersection.name || `kreuzung${intersection.id}`,
    `kreuzung${intersection.id}`,
  );
  const phasesBySignalGroup = new Map<string, string[]>();
  intersection.phases.forEach((phase) => {
    phase.signalGroups.forEach((signalGroupName) => {
      const phaseNames = phasesBySignalGroup.get(signalGroupName) ?? [];
      phaseNames.push(phase.name);
      phasesBySignalGroup.set(signalGroupName, phaseNames);
    });
  });
  const draftAmpeln: IntersectionWizardAmpelAppDto[] = [];
  ampeln.forEach((ampel, index) => {
    const signalId = positiveSignalId(String(ampel.signalId));
    const importedLightStructures = Object.values(ampel.lightStructures ?? {});
    const baseName = ampel.vehicleSignalName || ampel.pedestrianSignalName || `K${index + 1}`;
    draftAmpeln.push({
      id: `ampel-${ampel.signalId}`,
      name: baseName,
      kind: signalId === undefined && importedLightStructures.length > 0 ? 'STRUCTURE_LIGHT' : 'SIGNAL',
      ...(ampel.pedestrianSignalName !== undefined ? { pedestrianName: ampel.pedestrianSignalName } : {}),
      ...(signalId !== undefined ? { signalId: String(signalId) } : {}),
      use: ampel.use,
      trafficType:
        ampel.use === 'PEDESTRIAN_ONLY'
          ? 'PEDESTRIAN'
          : ampel.modelId.toLocaleLowerCase().includes('strab')
            ? 'TRAM'
            : 'CAR',
      modelName: ampel.modelId,
      modelConstant: sanitizeIdentifier(ampel.modelId, ''),
      lightStructures: signalId === undefined ? importedLightStructures : [],
      axisStructures: ampel.axisStructures,
    });
    if (signalId !== undefined) {
      importedLightStructures.forEach((structure, structureIndex) => {
        draftAmpeln.push({
          id: `ampel-${ampel.signalId}-light-${structureIndex + 1}`,
          name: `${baseName}Light${structureIndex + 1}`,
          kind: 'STRUCTURE_LIGHT',
          use: 'VEHICLE_ONLY',
          trafficType: ampel.modelId.toLocaleLowerCase().includes('strab') ? 'TRAM' : 'CAR',
          modelName: 'NONE',
          modelConstant: 'NONE',
          lightStructures: [structure],
          axisStructures: [],
        });
      });
    }
  });
  const draftAmpelIdsBySignalId = new Map<string, string[]>();
  ampeln.forEach((ampel) => {
    draftAmpelIdsBySignalId.set(
      String(ampel.signalId),
      draftAmpeln
        .filter(
          (draftAmpel) =>
            draftAmpel.id === `ampel-${ampel.signalId}` || draftAmpel.id.startsWith(`ampel-${ampel.signalId}-light-`),
        )
        .map((draftAmpel) => draftAmpel.id),
    );
  });
  const draftLanes: IntersectionWizardLaneAppDto[] = lanes.map((lane, index) => {
    const laneSignalId = String(lane.laneSignalId ?? '');
    const matchingTrafficLight = draftAmpeln.find((ampel) => ampel.signalId === laneSignalId);
    const tracks = lane.tracks ?? [];
    return {
      id: `lane-${index + 1}`,
      name: lane.name || `FS${index + 1}`,
      ...((lane.kpId ?? lane.scriptVariableName)?.trim() ? { luaVariableName: lane.kpId ?? lane.scriptVariableName } : {}),
      vehicleMultiplier: lane.vehicleMultiplier,
      ...(lane.countType === 'SIGNALS' || lane.countType === 'TRACKS' || lane.countType === 'CONTACTS'
        ? { countType: lane.countType }
        : {}),
      ...(lane.requestTrackIds && lane.requestTrackIds.length > 0 ? { requestTrackIds: lane.requestTrackIds } : {}),
      ...(lane.highlightTrackIds && lane.highlightTrackIds.length > 0
        ? { highlightTrackIds: lane.highlightTrackIds }
        : tracks.length > 0
          ? { highlightTrackIds: tracks }
          : {}),
      approach: normalizeApproach(lane.approach, lane.heading),
      signalSource: 'OWN',
      signal: draftSignalFromTrafficLight(matchingTrafficLight, laneSignalId, `${lane.name || `FS${index + 1}`}Signal`),
      signalGroupAssignments: [],
    };
  });
  const usedSignalGroupNames = new Set<string>();
  const signalGroups: IntersectionWizardSignalGroupAppDto[] = [];

  (intersection.signalGroupDefinitions ?? []).forEach((definition, index) => {
    const groupLanes = lanes
      .map((lane, laneIndex) => ({ lane, draftLane: draftLanes[laneIndex] }))
      .filter(
        ({ lane }) =>
          (lane.defaultSignalGroups ?? []).includes(definition.name) ||
          (lane.routeRules ?? []).some((rule) => rule.signalGroups.includes(definition.name)),
      );
    const trafficType = normalizeTrafficType(definition.trafficType);
    const firstLane = groupLanes[0]?.draftLane;
    const approach = isApproach(definition.approach) ? definition.approach : (firstLane?.approach ?? 'SOUTH');
    const definitionTurnDirections = normalizeOptionalDirections(definition.turnDirections);
    const ampelIds = definition.signalIds
      .flatMap((signalId) => draftAmpelIdsBySignalId.get(String(signalId)) ?? [])
      .filter((ampelId): ampelId is string => Boolean(ampelId));
    const lightStructureTurnDirections = inferTurnDirectionsFromGreenLightStructures(draftAmpeln, ampelIds);
    const turnDirections =
      trafficType === 'PEDESTRIAN'
        ? []
        : definitionTurnDirections && definitionTurnDirections.length > 0
          ? definitionTurnDirections
          : lightStructureTurnDirections.length > 0
            ? lightStructureTurnDirections
            : Array.from(new Set(groupLanes.flatMap(({ lane }) => normalizeDirections(lane.directions))));
    const importedName = signalGroupName(approach, trafficType, turnDirections);
    signalGroups.push({
      id: `sg-${index + 1}`,
      name: uniqueSignalGroupName(importedName, usedSignalGroupNames),
      luaVariableName: definition.scriptVariableName?.trim() || definition.name,
      approach,
      turnDirections,
      trafficType,
      showRequests: false,
      ...(definition.pedestrianCrossingNames?.[0]
        ? { pedestrianCrossingName: definition.pedestrianCrossingNames[0] }
        : {}),
      ampelIds,
    });
  });

  if (signalGroups.length === 0 && phasesBySignalGroup.size > 0) {
    Array.from(phasesBySignalGroup.entries()).forEach(([name, phaseNames], index) => {
      const groupLanes = lanes
        .map((lane, laneIndex) => ({ lane, draftLane: draftLanes[laneIndex] }))
        .filter(({ lane }) => lane.phases.some((phaseName) => phaseNames.includes(phaseName)));
      const firstHeadType = intersection.phases
        .filter((phase) => phaseNames.includes(phase.name))
        .flatMap((phase) => phase.signalHeads)
        .find((head) => head.type !== 'PEDESTRIAN')?.type;
      const trafficType = normalizeTrafficType(groupLanes[0]?.lane.type ?? firstHeadType);
      const approach = groupLanes[0]?.draftLane?.approach ?? 'SOUTH';
      const turnDirections =
        trafficType === 'PEDESTRIAN'
          ? []
          : Array.from(new Set(groupLanes.flatMap(({ lane }) => normalizeDirections(lane.directions))));
      const signalIds = new Set(
        intersection.phases
          .filter((phase) => phaseNames.includes(phase.name))
          .flatMap((phase) => phase.signalHeads)
          .map((head) => String(head.signalId)),
      );
      signalGroups.push({
        id: `sg-${index + 1}`,
        name: uniqueSignalGroupName(signalGroupName(approach, trafficType, turnDirections), usedSignalGroupNames),
        luaVariableName: name,
        approach,
        turnDirections,
        trafficType,
        showRequests: false,
        ampelIds: Array.from(signalIds)
          .flatMap((signalId) => draftAmpelIdsBySignalId.get(signalId) ?? [])
          .filter((ampelId): ampelId is string => Boolean(ampelId)),
      });
    });
  }

  const signalGroupIdsBySourceName = new Map(
    (intersection.signalGroupDefinitions ?? []).map((definition, index) => [definition.name, signalGroups[index]?.id]),
  );
  if (signalGroupIdsBySourceName.size === 0) {
    Array.from(phasesBySignalGroup.keys()).forEach((name, index) => {
      signalGroupIdsBySourceName.set(name, signalGroups[index]?.id);
    });
  }
  const signalGroupById = new Map(signalGroups.map((signalGroup) => [signalGroup.id, signalGroup]));
  const positiveSignalIdsByGroupId = new Map(
    signalGroups.map((signalGroup) => [
      signalGroup.id,
      new Set(
        signalGroup.ampelIds
          .map((ampelId) => positiveSignalId(draftAmpeln.find((ampel) => ampel.id === ampelId)?.signalId))
          .filter((signalId): signalId is number => signalId !== undefined),
      ),
    ]),
  );
  lanes.forEach((lane, laneIndex) => {
    const draftLane = draftLanes[laneIndex];
    if (!draftLane) return;
    const assignments = [
      ...(lane.defaultSignalGroups ?? [])
        .map((name) => signalGroupIdsBySourceName.get(name))
        .filter((id): id is string => Boolean(id))
        .map((signalGroupId) => ({ signalGroupId, mode: 'DEFAULT' as const })),
      ...(lane.routeRules ?? []).flatMap((rule) =>
        rule.signalGroups
          .map((name) => signalGroupIdsBySourceName.get(name))
          .filter((id): id is string => Boolean(id))
          .map((signalGroupId) => ({
            signalGroupId,
            mode: rule.mode,
            routeNames: rule.routeNames,
          })),
      ),
    ];
    draftLane.signalGroupAssignments = assignments;
    draftLane.approach = derivedLaneApproachFromSignalGroups(signalGroups, draftLane);
    const laneSignalId = String(lane.laneSignalId ?? '');
    const positiveLaneSignalId = positiveSignalId(laneSignalId);
    const matchingSignalGroupAssignment = assignments.find((assignment) => {
      const group = signalGroupById.get(assignment.signalGroupId);
      if (!group || positiveLaneSignalId === undefined) return false;
      return positiveSignalIdsByGroupId.get(group.id)?.has(positiveLaneSignalId) ?? false;
    });
    if (matchingSignalGroupAssignment) {
      draftLane.signalSource = 'SIGNAL_GROUP';
      draftLane.signalGroupSignalId = matchingSignalGroupAssignment.signalGroupId;
    }
    assignments.forEach((assignment) => {
      if (assignment.mode === 'DEFAULT') {
        const group = signalGroupById.get(assignment.signalGroupId);
        const importedName = Array.from(signalGroupIdsBySourceName.entries()).find(
          ([_name, signalGroupId]) => signalGroupId === assignment.signalGroupId,
        )?.[0];
        if (group && importedName && (lane.defaultRequestSignalGroups ?? []).includes(importedName)) {
          group.showRequests = true;
        }
      }
    });
    (lane.routeRules ?? []).forEach((rule) => {
      if (!rule.showRequests) return;
      rule.signalGroups.forEach((name) => {
        const signalGroupId = signalGroupIdsBySourceName.get(name);
        const group = signalGroupId ? signalGroupById.get(signalGroupId) : undefined;
        if (group) group.showRequests = true;
      });
    });
  });

  const pedestrianCrossings = intersection.pedestrianCrossings ?? [];
  pedestrianCrossings.forEach((crossing) => {
    const signalGroupId = crossing.signalGroups.map((name) => signalGroupIdsBySourceName.get(name)).find(Boolean);
    const group = signalGroupId ? signalGroupById.get(signalGroupId) : undefined;
    if (!group) return;
    group.approach = normalizeApproach(crossing.approach, crossing.heading);
    group.pedestrianCrossingName = crossing.name;
    if (crossing.scriptVariableName) group.pedestrianCrossingLuaVariableName = crossing.scriptVariableName;
    usedSignalGroupNames.delete(group.name);
    group.name = uniqueSignalGroupName(
      signalGroupName(group.approach, 'PEDESTRIAN', ['STRAIGHT']),
      usedSignalGroupNames,
    );
  });

  const hasPedestrianSignals =
    signalGroups.some((signalGroup) => signalGroup.trafficType === 'PEDESTRIAN') ||
    draftAmpeln.some(
      (ampel) =>
        ampel.use === 'PEDESTRIAN_ONLY' || ampel.use === 'VEHICLE_AND_PEDESTRIAN' || ampel.trafficType === 'PEDESTRIAN',
    );
  const hasMultipleLaneSignals = draftLanes.some((lane) => lane.signalGroupAssignments.length > 1);
  const hasStructureLightSignals = draftAmpeln.some((ampel) => ampel.kind === 'STRUCTURE_LIGHT');

  const draft: IntersectionWizardDraftAppDto = {
    id: `current-${intersection.id}`,
    name: intersection.name,
    luaVariableName: prefix,
    ...(intersection.greenTimeSeconds > 0 ? { greenTimeSeconds: intersection.greenTimeSeconds } : {}),
    intersectionEepSaveId: intersection.eepSaveId ?? -1,
    ...(intersection.tippStructure !== undefined ? { tippStructure: intersection.tippStructure } : {}),
    switchInStrictOrder: intersection.switchInStrictOrder ?? false,
    showLuaCodeImmediately: false,
    supportPedestrianSignals: hasPedestrianSignals,
    supportMultipleLaneSignals: hasMultipleLaneSignals,
    supportStructureLightSignals: hasStructureLightSignals,
    staticCams: intersection.staticCams ?? [],
    createdAt: now,
    updatedAt: now,
    lanes: draftLanes,
    ampeln: draftAmpeln,
    signalGroups,
    phases: intersection.phases.map((phase) => ({
      id: `phase-${phase.name}`,
      name: phase.name,
      ...(phase.greenTimeSeconds > 0 ? { greenTimeSeconds: phase.greenTimeSeconds } : {}),
      signalGroupIds: phase.signalGroups
        .map((signalGroupName) => signalGroupIdsBySourceName.get(signalGroupName))
        .filter((signalGroupId): signalGroupId is string => Boolean(signalGroupId)),
    })),
    generatedLua: '',
  };
  draft.generatedLua = generateIntersectionWizardLua(draft).lua;
  return draft;
}

export function createDefaultSignalGroups(
  lanes: IntersectionWizardLaneAppDto[],
  trafficTypeForLane: (lane: IntersectionWizardLaneAppDto) => LegacyTrafficType = () => 'CAR',
): IntersectionWizardSignalGroupAppDto[] {
  const groups = new Map<string, IntersectionWizardSignalGroupAppDto>();
  const usedNames = new Set<string>();
  lanes.forEach((lane) => {
    const trafficType = normalizeTrafficType(trafficTypeForLane(lane));
    const directions = ['STRAIGHT'] as IntersectionWizardTurnDirection[];
    const key = `${trafficType}:${lane.approach}:${directions.join('|')}`;
    const existing = groups.get(key);
    if (existing) return;
    const name = uniqueSignalGroupName(signalGroupName(lane.approach, trafficType, directions), usedNames);
    groups.set(key, {
      id: `sg-${groups.size + 1}`,
      name,
      approach: lane.approach,
      turnDirections: directions,
      trafficType,
      showRequests: false,
      ampelIds: [],
    });
  });
  return Array.from(groups.values());
}

export function normalizeLegacyDraftInput(input: LegacyDraftInput): Partial<IntersectionWizardDraftAppDto> {
  const signalGroups =
    input.signalGroups?.map((group) => ({
      id: group.id,
      name: group.name,
      approach:
        group.approach ??
        normalizeApproach(
          input.lanes?.find((lane) => (group as unknown as { laneIds?: string[] }).laneIds?.includes(lane.id))
            ?.approach,
          (
            input.lanes?.find((lane) =>
              (group as unknown as { laneIds?: string[] }).laneIds?.includes(lane.id),
            ) as unknown as { heading?: string } | undefined
          )?.heading,
        ),
      turnDirections: normalizeDirections(group.turnDirections),
      trafficType: normalizeTrafficType(group.trafficType),
      showRequests:
        group.showRequests ?? input.defaultRequestDisplays?.some((entry) => entry.signalGroupId === group.id) ?? false,
      ...(group.luaVariableName ? { luaVariableName: group.luaVariableName } : {}),
      ...(group.pedestrianCrossingName ? { pedestrianCrossingName: group.pedestrianCrossingName } : {}),
      ...(group.pedestrianCrossingLuaVariableName
        ? { pedestrianCrossingLuaVariableName: group.pedestrianCrossingLuaVariableName }
        : {}),
      ampelIds: group.ampelIds ?? [],
    })) ?? [];
  const signalGroupIdsById = new Set(signalGroups.map((group) => group.id));
  const lanes =
    input.lanes?.map((lane) => {
      const legacyLaneIds = signalGroups
        .filter((group) => (group as unknown as { laneIds?: string[] }).laneIds?.includes(lane.id))
        .map((group) => group.id);
      const routeAssignments =
        input.routeRules
          ?.filter((rule) => rule.laneId === lane.id)
          .flatMap((rule) =>
            rule.signalGroupIds
              .filter((signalGroupId) => signalGroupIdsById.has(signalGroupId))
              .map((signalGroupId) => ({
                signalGroupId,
                mode: rule.mode,
                routeNames: rule.routeNames,
              })),
          ) ?? [];
      const defaultAssignments = legacyLaneIds.map((signalGroupId) => ({
        signalGroupId,
        mode: 'DEFAULT' as const,
      }));
      const signal = (lane as unknown as { signal?: IntersectionWizardLaneSignalAppDto }).signal;
      return {
        ...lane,
        approach: normalizeApproach(lane.approach, (lane as unknown as { heading?: string }).heading),
        signalSource: lane.signalSource ?? 'OWN',
        ...(lane.signalGroupSignalId ? { signalGroupSignalId: lane.signalGroupSignalId } : {}),
        signal: signal ?? {
          name: `${lane.name || lane.id}Signal`,
          ...((lane as unknown as { signalId?: string }).signalId
            ? { signalId: (lane as unknown as { signalId?: string }).signalId }
            : {}),
          modelName: 'Unsichtbar_2er',
          modelConstant: 'Unsichtbar_2er',
        },
        signalGroupAssignments:
          lane.signalGroupAssignments && lane.signalGroupAssignments.length > 0
            ? lane.signalGroupAssignments
            : [...defaultAssignments, ...routeAssignments],
      } satisfies IntersectionWizardLaneAppDto;
    }) ?? [];

  return {
    ...input,
    lanes,
    signalGroups,
  };
}
