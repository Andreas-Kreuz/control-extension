import {
  IntersectionAppDto,
  IntersectionLaneAppDto,
  IntersectionTrafficLightAppDto,
  IntersectionWizardAmpelAppDto,
  IntersectionWizardApproach,
  IntersectionWizardTurnDirection,
  IntersectionWizardDraftAppDto,
  IntersectionWizardLaneAppDto,
  IntersectionWizardPedestrianCrossingAppDto,
  IntersectionWizardSignalGroupAppDto,
  IntersectionWizardTrafficType,
} from '@ce/web-shared';

const turnDirectionSuffix: Record<IntersectionWizardTurnDirection, string> = {
  LEFT: 'Left',
  HALF_LEFT: 'HalfLeft',
  STRAIGHT: 'Straight',
  HALF_RIGHT: 'HalfRight',
  RIGHT: 'Right',
};

const approachPrefix: Record<IntersectionWizardApproach, string> = {
  NORTH: 'n',
  NORTH_EAST: 'ne',
  EAST: 'e',
  SOUTH_EAST: 'se',
  SOUTH: 's',
  SOUTH_WEST: 'sw',
  WEST: 'w',
  NORTH_WEST: 'nw',
};

const trafficTypeSignalFunction: Record<IntersectionWizardTrafficType, string> = {
  CAR: 'addVehicleSignals',
  BUS: 'addSignals',
  TRAM: 'addTramSignals',
  BICYCLE: 'addSignals',
  PEDESTRIAN: 'addPedestrianSignals',
};

const trafficTypeLuaType: Record<IntersectionWizardTrafficType, string> = {
  CAR: 'Lane.Type.CAR',
  BUS: 'Lane.Type.BUS',
  TRAM: 'Lane.Type.TRAM',
  BICYCLE: 'Lane.Type.BICYCLE',
  PEDESTRIAN: 'Lane.Type.PEDESTRIAN',
};

const routeRuleCall = {
  ONLY: 'driveOnlyOnSignalGroups',
  ALSO: 'driveAlsoOnSignalGroups',
} as const;

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

function ampelVariableName(ampel: IntersectionWizardAmpelAppDto, index: number, used: Set<string>): string {
  return uniqueIdentifier(ampel.name, `K${index + 1}`, used);
}

function laneSignalVariableName(lane: IntersectionWizardLaneAppDto, index: number, used: Set<string>): string {
  return uniqueIdentifier(`${lane.name}Signal`, `lane${index + 1}Signal`, used);
}

function laneVariableName(
  lane: IntersectionWizardLaneAppDto,
  index: number,
  intersectionPrefix: string,
  used: Set<string>,
): string {
  if (lane.luaVariableName?.trim()) {
    return uniqueIdentifier(lane.luaVariableName, `lane${index + 1}`, used);
  }
  const numberedLane = /^(?:lane|spur|fahrstreifen|fs)\s*(\d+[a-z]?)$/i.exec(lane.name.trim());
  if (numberedLane) {
    const prefix = lowerFirst(sanitizeIdentifier(intersectionPrefix, 'kreuzung'));
    return uniqueIdentifier(`${prefix}Lane${numberedLane[1]}`, `${prefix}Lane${index + 1}`, used);
  }
  return uniqueIdentifier(lowerFirst(sanitizeIdentifier(lane.name, `lane${index + 1}`)), `lane${index + 1}`, used);
}

function pedestrianCrossingVariableName(
  crossing: IntersectionWizardPedestrianCrossingAppDto,
  index: number,
  intersectionPrefix: string,
  used: Set<string>,
): string {
  if (crossing.luaVariableName?.trim()) {
    return uniqueIdentifier(crossing.luaVariableName, `pedCrossing${index + 1}`, used);
  }
  const prefix = lowerFirst(sanitizeIdentifier(intersectionPrefix, 'kreuzung'));
  const crossingName = upperFirst(sanitizeIdentifier(crossing.name, `PedCrossing${index + 1}`));
  return uniqueIdentifier(`${prefix}${crossingName}`, `${prefix}PedCrossing${index + 1}`, used);
}

function signalGroupVariableName(group: IntersectionWizardSignalGroupAppDto, index: number, used: Set<string>): string {
  return uniqueIdentifier(group.name, `sg${index + 1}`, used);
}

function normalizeTrafficType(type: string | undefined): IntersectionWizardTrafficType {
  if (type === 'BUS' || type === 'TRAM' || type === 'BICYCLE' || type === 'PEDESTRIAN') return type;
  return 'CAR';
}

function normalizeDirections(directions: string[]): IntersectionWizardTurnDirection[] {
  return directions.filter((direction): direction is IntersectionWizardTurnDirection =>
    ['LEFT', 'HALF_LEFT', 'STRAIGHT', 'HALF_RIGHT', 'RIGHT'].includes(direction),
  );
}

function normalizeTurnDirections(directions: string[] | undefined): IntersectionWizardTurnDirection[] {
  return normalizeDirections(directions ?? []);
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

function normalizeApproach(approach: string | undefined, legacyHeading?: string): IntersectionWizardApproach {
  if (isApproach(approach)) return approach;
  if (isApproach(legacyHeading)) return oppositeApproach[legacyHeading];
  return 'SOUTH';
}

function signalGroupNameForLane(lane: IntersectionWizardLaneAppDto): string {
  return `${approachPrefix[normalizeApproach(lane.approach, lane.heading)]}${lane.turnDirections
    .map((direction) => turnDirectionSuffix[direction])
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

function luaTurnDirections(directions: IntersectionWizardTurnDirection[]): string {
  return directions.map((direction) => `Lane.Directions.${direction}`).join(', ');
}

function modelExpression(ampel: IntersectionWizardAmpelAppDto): string {
  if (ampel.modelConstant) return `TrafficLightModel.${ampel.modelConstant}`;
  if (ampel.modelName === 'NO SIGNAL MODEL') return 'TrafficLightModel.NONE';
  return `TrafficLightModel.${sanitizeIdentifier(ampel.modelName, 'JS2_3er_mit_FG')}`;
}

function luaValue(value: string | number | undefined): string {
  if (value === undefined) return 'nil';
  if (typeof value === 'number') return String(value);
  return luaString(value);
}

function signalGroupAddCall(group: IntersectionWizardSignalGroupAppDto, signalVars: string[]): string {
  if (group.trafficType === 'BUS' || group.trafficType === 'BICYCLE') {
    return `${trafficTypeSignalFunction[group.trafficType]}(${trafficTypeLuaType[group.trafficType]}, ${signalVars.join(', ')})`;
  }
  return `${trafficTypeSignalFunction[group.trafficType]}(${signalVars.join(', ')})`;
}

function laneTrafficType(
  draft: IntersectionWizardDraftAppDto,
  lane: IntersectionWizardLaneAppDto,
): IntersectionWizardTrafficType {
  const groupTypes = draft.signalGroups
    .filter((group) => group.trafficType !== 'PEDESTRIAN' && group.laneIds.includes(lane.id))
    .map((group) => group.trafficType);
  return (
    groupTypes.find((type) => type === 'TRAM') ??
    groupTypes.find((type) => type === 'BUS') ??
    groupTypes.find((type) => type === 'BICYCLE') ??
    groupTypes[0] ??
    (lane as { trafficType?: IntersectionWizardTrafficType }).trafficType ??
    'CAR'
  );
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
  if (groupVarList.length <= 1) return chainCall(newPhase, [`addSignalGroup(${groupVarList.join(', ')})`]);
  return chainCall(newPhase, [`addSignalGroup(\n        ${groupVarList.join(',\n        ')}\n    )`]);
}

function intersectionChainCalls(draft: IntersectionWizardDraftAppDto, variableName: string): string[] {
  return [
    ...(draft.tippStructure ? [`setTippStructure(${luaString(draft.tippStructure)})`] : []),
    `scriptVariableName(${luaString(variableName)})`,
    `withStorage(${draft.intersectionEepSaveId ?? -1})`,
    ...(draft.switchInStrictOrder ? ['setSwitchInStrictOrder(true)'] : []),
  ];
}

function intersectionConstructor(draft: IntersectionWizardDraftAppDto): string {
  const args = [luaString(draft.name)];
  if (draft.greenTimeSeconds !== undefined) args.push(String(draft.greenTimeSeconds));
  return `Intersection:new(${args.join(', ')})`;
}

function isPlainLightStructure(ampel: IntersectionWizardAmpelAppDto): boolean {
  const signalId = Number(ampel.signalId);
  return (
    Number.isFinite(signalId) &&
    signalId < 0 &&
    modelExpression(ampel) === 'TrafficLightModel.NONE' &&
    (ampel.lightStructures ?? []).length === 1 &&
    (ampel.axisStructures ?? []).length === 0 &&
    ampel.use === 'VEHICLE_ONLY'
  );
}

function trafficLightBaseConstructor(ampel: IntersectionWizardAmpelAppDto): string {
  if (isPlainLightStructure(ampel)) {
    const structure = ampel.lightStructures?.[0] ?? {};
    return `TrafficLight:newPlainLightStructure(${[
      luaString(ampel.name),
      luaValue(structure.structureRed),
      luaValue(structure.structureGreen),
      luaValue(structure.structureYellow),
      luaValue(structure.structureRequest),
    ].join(', ')})`;
  }
  const signalId = Number(ampel.signalId);
  const safeSignalId = Number.isFinite(signalId) ? signalId : 0;
  if (ampel.use === 'PEDESTRIAN_ONLY') {
    return `TrafficLight:newPedestrianOnly(${luaString(ampel.name)}, ${safeSignalId}, ${modelExpression(ampel)})`;
  }
  return `TrafficLight:new(${luaString(ampel.name)}, ${safeSignalId}, ${modelExpression(ampel)})`;
}

function trafficLightChainCalls(ampel: IntersectionWizardAmpelAppDto): string[] {
  const useCalls: string[] = [];
  const lightStructures = (ampel.lightStructures ?? []).map((structure) => {
    const values = [
      luaValue(structure.structureRed),
      luaValue(structure.structureGreen),
      luaValue(structure.structureYellow),
      luaValue(structure.structureRequest),
    ];
    const [firstValue, ...remainingValues] = values;
    return `addLightStructure(${firstValue},\n        ${remainingValues.join(',\n        ')}\n    )`;
  });
  const axisStructures = (ampel.axisStructures ?? []).map(
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
  return [...useCalls, ...(isPlainLightStructure(ampel) ? [] : lightStructures), ...axisStructures];
}

function indentBlock(lines: string[]): string[] {
  return lines.map((line) =>
    line
      .split('\n')
      .map((part) => (part ? `    ${part}` : part))
      .join('\n'),
  );
}

export function generateIntersectionWizardLua(draft: IntersectionWizardDraftAppDto): {
  lua: string;
  warnings: string[];
} {
  const prefix = sanitizeIdentifier(draft.luaVariableName || 'kreuzung', 'kreuzung');
  const crossingCommentName = draft.name.trim() ? ` (${draft.name.trim()})` : '';
  const warnings: string[] = [];
  const ampelVars = new Map<string, string>();
  const vehicleAmpelVars = new Map<string, string>();
  const pedestrianAmpelVars = new Map<string, string>();
  const laneSignalVarsBySignalId = new Map<string, string>();
  const laneVars = new Map<string, string>();
  const pedestrianCrossingVars = new Map<string, string>();
  const groupVars = new Map<string, string>();
  const usedAmpelVars = new Set<string>();
  const usedLaneVars = new Set<string>();
  const usedPedestrianCrossingVars = new Set<string>();
  const usedGroupVars = new Set<string>();

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
  const bodyLines: string[] = ['-- Ampeln'];

  draft.ampeln.forEach((ampel, index) => {
    const variable = ampelVariableName(ampel, index, usedAmpelVars);
    ampelVars.set(ampel.id, variable);
    vehicleAmpelVars.set(ampel.id, variable);
    if (ampel.use === 'PEDESTRIAN_ONLY') pedestrianAmpelVars.set(ampel.id, variable);
    bodyLines.push(
      `local ${variable} = ${chainCall(trafficLightBaseConstructor(ampel), trafficLightChainCalls(ampel))}`,
    );
    if (ampel.use === 'VEHICLE_AND_PEDESTRIAN') {
      const pedestrianVariable = uniqueIdentifier(
        ampel.pedestrianName || `F${index + 1}`,
        `F${index + 1}`,
        usedAmpelVars,
      );
      pedestrianAmpelVars.set(ampel.id, pedestrianVariable);
      bodyLines.push(
        `local ${pedestrianVariable} = ${variable}:withPedestrian(${luaString(ampel.pedestrianName || pedestrianVariable)})`,
      );
    }
  });

  draft.ampeln.forEach((ampel) => {
    const variable = vehicleAmpelVars.get(ampel.id);
    if (variable) laneSignalVarsBySignalId.set(ampel.signalId.trim(), variable);
  });

  const placeholderLaneSignals: string[] = [];
  draft.lanes.forEach((lane, index) => {
    const signalId = lane.signalId.trim();
    if (!signalId || laneSignalVarsBySignalId.has(signalId)) return;
    const numericSignalId = Number(signalId);
    const variable = laneSignalVariableName(lane, index, usedAmpelVars);
    laneSignalVarsBySignalId.set(signalId, variable);
    placeholderLaneSignals.push(
      `local ${variable} = TrafficLight:new(${luaString(variable)}, ${
        Number.isFinite(numericSignalId) ? numericSignalId : 0
      }, TrafficLightModel.Unsichtbar_2er)`,
    );
  });

  if (placeholderLaneSignals.length > 0) {
    bodyLines.push('', '-- Fahrspur-Ampeln');
    bodyLines.push(...placeholderLaneSignals);
  }

  bodyLines.push('', '-- Fahrspuren');
  draft.lanes.forEach((lane, index) => {
    const variable = laneVariableName(lane, index, prefix, usedLaneVars);
    laneVars.set(lane.id, variable);
    const laneSignalExpression = laneSignalVarsBySignalId.get(lane.signalId.trim()) ?? 'nil';
    const type = laneTrafficType(draft, lane);
    const turnDirectionArguments = luaTurnDirections(lane.turnDirections);
    const requestTrackIds = lane.requestTrackIds ?? [];
    const highlightTrackIds = lane.highlightTrackIds ?? [];
    const chainCalls = [
      `setApproach(Lane.Approach.${normalizeApproach(lane.approach, lane.heading)})`,
      ...(turnDirectionArguments ? [`setTurnDirections(${turnDirectionArguments})`] : []),
      ...(type === 'CAR' ? [] : [`setTrafficType(${trafficTypeLuaType[type]})`]),
      ...(lane.vehicleMultiplier && lane.vehicleMultiplier !== 1
        ? [`setFahrzeugMultiplikator(${lane.vehicleMultiplier})`]
        : []),
      ...(lane.countType === 'SIGNALS' ? ['useSignalForQueue()'] : []),
      ...(lane.countType === 'TRACKS' ? requestTrackIds.map((trackId) => `useTrackForQueue(${trackId})`) : []),
      ...(highlightTrackIds.length > 0 ? [`setHighLightingTracks(${highlightTrackIds.join(', ')})`] : []),
    ];
    bodyLines.push(
      `${variable} = ${chainCall(`Lane:new(${luaString(lane.name)}, ${laneSignalExpression})`, chainCalls)}`,
    );
  });

  bodyLines.push(
    '',
    '-- Kreuzung',
    `local ${prefix} = ${chainCall(intersectionConstructor(draft), intersectionChainCalls(draft, prefix))}`,
  );
  if ((draft.pedestrianCrossings ?? []).length > 0) {
    bodyLines.push('', '-- Fussgaengerfurten');
    (draft.pedestrianCrossings ?? []).forEach((crossing, index) => {
      const variable = pedestrianCrossingVariableName(crossing, index, prefix, usedPedestrianCrossingVars);
      pedestrianCrossingVars.set(crossing.id, variable);
      bodyLines.push(
        `${variable} = ${chainCall(`PedestrianCrossing:new(${luaString(crossing.name)})`, [
          `scriptVariableName(${luaString(variable)})`,
          `setApproach(PedestrianCrossing.Approach.${normalizeApproach(crossing.approach, crossing.heading)})`,
        ])}`,
      );
    });
  }
  bodyLines.push('', '-- Signalgruppen');
  draft.signalGroups.forEach((group, index) => {
    const variable = signalGroupVariableName(group, index, usedGroupVars);
    groupVars.set(group.id, variable);
    const crossingVars = (draft.pedestrianCrossings ?? [])
      .filter((crossing) => crossing.signalGroupId === group.id)
      .map((crossing) => pedestrianCrossingVars.get(crossing.id))
      .filter((value): value is string => Boolean(value));
    const signalVars = group.ampelIds
      .map((id) => (group.trafficType === 'PEDESTRIAN' ? pedestrianAmpelVars.get(id) : vehicleAmpelVars.get(id)))
      .filter((value): value is string => Boolean(value));
    const signalGroupCalls = [
      ...(crossingVars.length > 0 ? [`addPedestrianCrossing(${crossingVars.join(', ')})`] : []),
      signalGroupAddCall(group, signalVars),
    ];
    bodyLines.push(
      `local ${variable} = ${chainCall(`${prefix}:newSignalGroup(${luaString(group.name)})`, signalGroupCalls)}`,
    );
  });

  bodyLines.push('', '-- Fahrspuren fahren auf Signalgruppen');
  draft.lanes.forEach((lane) => {
    const groups = draft.signalGroups.filter((group) => group.laneIds.includes(lane.id));
    if (groups.length > 1) {
      warnings.push(`${lane.name}: Mehrere Signalgruppen erfordern eine eigene unsichtbare Ampel als Fahrspur-Ampel.`);
    }
    const groupVarList = groups
      .map((group) => groupVars.get(group.id))
      .filter((value): value is string => Boolean(value));
    if (groupVarList.length > 0) {
      const requestGroupVarList = (draft.defaultRequestDisplays ?? [])
        .filter((entry) => entry.laneId === lane.id)
        .map((entry) => groupVars.get(entry.signalGroupId))
        .filter((value): value is string => Boolean(value));
      const calls =
        requestGroupVarList.length > 0 ? [`showRequestsOnSignalGroups(${requestGroupVarList.join(', ')})`] : [];
      bodyLines.push(
        chainCall(`${laneVars.get(lane.id)}:driveOnDefaultSignalGroups(${groupVarList.join(', ')})`, calls),
      );
    }
  });

  if ((draft.routeRules ?? []).length > 0) {
    bodyLines.push('', '-- Routenabhängige Fahrregeln');
    (draft.routeRules ?? []).forEach((rule) => {
      const laneVar = laneVars.get(rule.laneId);
      if (!laneVar || rule.routeNames.length === 0) return;
      const groupVarList = rule.signalGroupIds
        .map((id) => groupVars.get(id))
        .filter((value): value is string => Boolean(value));
      if (groupVarList.length === 0) return;
      const routes = rule.routeNames.map(luaString).join(', ');
      const groups = groupVarList.join(', ');
      const calls = [`${routeRuleCall[rule.mode]}(${groups})`];
      if (rule.showRequests) calls.push(`showRequestsOnSignalGroups(${groups})`);
      bodyLines.push(chainCall(`${laneVar}:routes(${routes})`, calls));
    });
  }

  if ((draft.staticCams ?? []).length > 0) {
    bodyLines.push('', '-- Statische Kameras');
    (draft.staticCams ?? [])
      .filter((cameraName) => cameraName.trim())
      .forEach((cameraName) => {
        bodyLines.push(`${prefix}:addStaticCam(${luaString(cameraName)})`);
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
  const draftAmpeln: IntersectionWizardAmpelAppDto[] = ampeln.map((ampel, index) => ({
    id: `ampel-${ampel.signalId}`,
    name: ampel.vehicleSignalName || ampel.pedestrianSignalName || `K${index + 1}`,
    ...(ampel.pedestrianSignalName !== undefined ? { pedestrianName: ampel.pedestrianSignalName } : {}),
    signalId: String(ampel.signalId),
    use: ampel.use,
    trafficType:
      ampel.use === 'PEDESTRIAN_ONLY'
        ? 'PEDESTRIAN'
        : ampel.modelId.toLocaleLowerCase().includes('strab')
          ? 'TRAM'
          : 'CAR',
    modelName: ampel.modelId,
    modelConstant: sanitizeIdentifier(ampel.modelId, ''),
    lightStructures: Object.values(ampel.lightStructures ?? {}),
    axisStructures: ampel.axisStructures,
  }));
  const draftLanes: IntersectionWizardLaneAppDto[] = lanes.map((lane, index) => ({
    id: `lane-${index + 1}`,
    name: lane.name || `FS${index + 1}`,
    vehicleMultiplier: lane.vehicleMultiplier,
    ...(lane.countType === 'SIGNALS' || lane.countType === 'TRACKS' || lane.countType === 'CONTACTS'
      ? { countType: lane.countType }
      : {}),
    ...(lane.requestTrackIds && lane.requestTrackIds.length > 0 ? { requestTrackIds: lane.requestTrackIds } : {}),
    ...(lane.highlightTrackIds && lane.highlightTrackIds.length > 0
      ? { highlightTrackIds: lane.highlightTrackIds }
      : lane.tracks.length > 0
        ? { highlightTrackIds: lane.tracks }
        : {}),
    signalId: String(lane.laneSignalId ?? ''),
    approach: normalizeApproach(lane.approach, lane.heading),
    turnDirections: normalizeTurnDirections(lane.directions),
  }));
  const signalGroupDefinitions = intersection.signalGroupDefinitions ?? [];
  const pedestrianCrossingDtos = intersection.pedestrianCrossings ?? [];
  const hasDefaultSignalGroupLinks = lanes.some((lane) => (lane.defaultSignalGroups ?? []).length > 0);
  let signalGroups: IntersectionWizardSignalGroupAppDto[];
  if (signalGroupDefinitions.length > 0) {
    signalGroups = signalGroupDefinitions.map((definition, index) => {
      const phaseNames = phasesBySignalGroup.get(definition.name) ?? [];
      let groupLanes = lanes
        .map((lane, laneIndex) => ({ lane, laneId: draftLanes[laneIndex]?.id }))
        .filter(({ lane }) => (lane.defaultSignalGroups ?? []).includes(definition.name));
      if (groupLanes.length === 0 && !hasDefaultSignalGroupLinks) {
        groupLanes = lanes
          .map((lane, laneIndex) => ({ lane, laneId: draftLanes[laneIndex]?.id }))
          .filter(({ lane }) => lane.phases.some((phaseName) => phaseNames.includes(phaseName)));
      }
      const turnDirections: IntersectionWizardTurnDirection[] = Array.from(
        new Set(groupLanes.flatMap(({ lane }) => normalizeTurnDirections(lane.directions))),
      );
      const signalIds = new Set(definition.signalIds.map(String));
      return {
        id: `sg-${index + 1}`,
        name: definition.name,
        laneIds: groupLanes.map(({ laneId }) => laneId).filter((laneId): laneId is string => Boolean(laneId)),
        turnDirections:
          turnDirections.length > 0 ? turnDirections : (['STRAIGHT'] as IntersectionWizardTurnDirection[]),
        trafficType: normalizeTrafficType(definition.trafficType),
        ampelIds: draftAmpeln.filter((ampel) => signalIds.has(ampel.signalId)).map((ampel) => ampel.id),
      };
    });
  } else if (phasesBySignalGroup.size > 0) {
    signalGroups = Array.from(phasesBySignalGroup.entries()).map(([name, phaseNames], index) => {
      const groupLanes = lanes
        .map((lane, laneIndex) => ({ lane, laneId: draftLanes[laneIndex]?.id }))
        .filter(({ lane }) => lane.phases.some((phaseName) => phaseNames.includes(phaseName)));
      const turnDirections: IntersectionWizardTurnDirection[] = Array.from(
        new Set(groupLanes.flatMap(({ lane }) => normalizeTurnDirections(lane.directions))),
      );
      const firstLaneType = groupLanes[0]?.lane.type;
      const firstHeadType = intersection.phases
        .filter((phase) => phaseNames.includes(phase.name))
        .flatMap((phase) => phase.signalHeads)
        .find((head) => head.type !== 'PEDESTRIAN')?.type;
      const signalIds = new Set(
        intersection.phases
          .filter((phase) => phaseNames.includes(phase.name))
          .flatMap((phase) => phase.signalHeads)
          .map((head) => String(head.signalId)),
      );
      return {
        id: `sg-${index + 1}`,
        name,
        laneIds: groupLanes.map(({ laneId }) => laneId).filter((laneId): laneId is string => Boolean(laneId)),
        turnDirections:
          turnDirections.length > 0 ? turnDirections : (['STRAIGHT'] as IntersectionWizardTurnDirection[]),
        trafficType: normalizeTrafficType(firstLaneType ?? firstHeadType),
        ampelIds: draftAmpeln.filter((ampel) => signalIds.has(ampel.signalId)).map((ampel) => ampel.id),
      };
    });
  } else {
    signalGroups = createDefaultSignalGroups(draftLanes, (lane) => {
      const laneIndex = draftLanes.findIndex((draftLane) => draftLane.id === lane.id);
      return normalizeTrafficType(lanes[laneIndex]?.type);
    });
  }

  const signalGroupIdsByName = new Map(signalGroups.map((signalGroup) => [signalGroup.name, signalGroup.id]));
  const pedestrianCrossings =
    pedestrianCrossingDtos.length > 0
      ? pedestrianCrossingDtos.map((crossing, index) => {
          const signalGroupName = crossing.signalGroups[0];
          const signalGroupId =
            (signalGroupName && signalGroupIdsByName.get(signalGroupName)) ??
            signalGroups.find((group) => group.trafficType === 'PEDESTRIAN' && group.name === crossing.name)?.id ??
            '';
          return {
            id: `ped-crossing-${index + 1}`,
            name: crossing.name,
            ...(crossing.scriptVariableName ? { luaVariableName: crossing.scriptVariableName } : {}),
            approach: normalizeApproach(crossing.approach, crossing.heading),
            signalGroupId,
          };
        })
      : signalGroups
          .filter((signalGroup) => signalGroup.trafficType === 'PEDESTRIAN')
          .map((signalGroup, index) => ({
            id: `ped-crossing-${index + 1}`,
            name: signalGroup.name,
            approach: 'SOUTH' as IntersectionWizardApproach,
            signalGroupId: signalGroup.id,
          }));
  const routeRules = lanes.flatMap((lane, laneIndex) =>
    (lane.routeRules ?? [])
      .map((rule, ruleIndex) => ({
        id: `route-rule-${laneIndex + 1}-${ruleIndex + 1}`,
        laneId: draftLanes[laneIndex]?.id ?? '',
        routeNames: rule.routeNames,
        signalGroupIds: rule.signalGroups
          .map((signalGroupName) => signalGroupIdsByName.get(signalGroupName))
          .filter((value): value is string => Boolean(value)),
        mode: rule.mode,
        showRequests: rule.showRequests,
      }))
      .filter((rule) => rule.laneId && rule.routeNames.length > 0 && rule.signalGroupIds.length > 0),
  );
  const defaultRequestDisplays = lanes.flatMap((lane, laneIndex) =>
    (lane.defaultRequestSignalGroups ?? [])
      .map((signalGroupName) => ({
        laneId: draftLanes[laneIndex]?.id ?? '',
        signalGroupId: signalGroupIdsByName.get(signalGroupName) ?? '',
      }))
      .filter((entry) => entry.laneId && entry.signalGroupId),
  );
  const hasPedestrianSignals =
    signalGroups.some((signalGroup) => signalGroup.trafficType === 'PEDESTRIAN') ||
    draftAmpeln.some(
      (ampel) =>
        ampel.use === 'PEDESTRIAN_ONLY' || ampel.use === 'VEHICLE_AND_PEDESTRIAN' || ampel.trafficType === 'PEDESTRIAN',
    );
  const hasMultipleLaneSignals =
    routeRules.length > 0 ||
    signalGroups.some((group) =>
      group.laneIds.some((laneId) => signalGroups.filter((entry) => entry.laneIds.includes(laneId)).length > 1),
    );

  const draft: IntersectionWizardDraftAppDto = {
    id: `current-${intersection.id}`,
    name: intersection.name,
    luaVariableName: prefix,
    ...(intersection.greenTimeSeconds > 0 ? { greenTimeSeconds: intersection.greenTimeSeconds } : {}),
    intersectionEepSaveId: intersection.eepSaveId ?? -1,
    ...(intersection.tippStructure !== undefined ? { tippStructure: intersection.tippStructure } : {}),
    switchInStrictOrder: intersection.switchInStrictOrder ?? false,
    showLuaCodeImmediately: true,
    supportPedestrianSignals: hasPedestrianSignals,
    supportMultipleLaneSignals: hasMultipleLaneSignals,
    staticCams: intersection.staticCams ?? [],
    createdAt: now,
    updatedAt: now,
    lanes: draftLanes,
    pedestrianCrossings,
    ampeln: draftAmpeln,
    signalGroups,
    routeRules,
    defaultRequestDisplays,
    phases: intersection.phases.map((phase) => ({
      id: `phase-${phase.name}`,
      name: phase.name,
      ...(phase.greenTimeSeconds > 0 ? { greenTimeSeconds: phase.greenTimeSeconds } : {}),
      signalGroupIds: signalGroups
        .filter((signalGroup) => phase.signalGroups.includes(signalGroup.name))
        .map((signalGroup) => signalGroup.id),
    })),
    generatedLua: '',
  };
  draft.generatedLua = generateIntersectionWizardLua(draft).lua;
  return draft;
}

export function createDefaultSignalGroups(
  lanes: IntersectionWizardLaneAppDto[],
  trafficTypeForLane: (lane: IntersectionWizardLaneAppDto) => IntersectionWizardTrafficType = () => 'CAR',
): IntersectionWizardSignalGroupAppDto[] {
  const groups = new Map<string, IntersectionWizardSignalGroupAppDto>();
  const usedNames = new Set<string>();
  lanes.forEach((lane) => {
    const trafficType = trafficTypeForLane(lane);
    const key = `${trafficType}:${normalizeApproach(lane.approach, lane.heading)}:${lane.turnDirections.join('|')}`;
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
      trafficType,
      ampelIds: [],
    });
  });
  return Array.from(groups.values());
}
