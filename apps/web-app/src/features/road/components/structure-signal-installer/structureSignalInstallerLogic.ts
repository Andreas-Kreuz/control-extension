import type {
  AlignStructureSignalInstallerCommandAppDto,
  FocusStructureSignalInstallerCameraCommandAppDto,
  StructureAppDto,
  StructureSignalInstallerHousingKind,
  StructureSignalInstallerTargetAppDto,
} from '@ce/web-shared';

export type HousingKindOption = {
  label: string;
  signalCount: number;
  value: StructureSignalInstallerHousingKind;
};

type TagValues = Record<string, string>;

const signalSpacingMeters = 0.27;
const mastBaseOffsetMeters = 2.88;
const cameraDistanceMeters = 20;
const cameraMastHeightOffsetMeters = 5;
const cameraHousingHeightOffsetMeters = cameraMastHeightOffsetMeters - mastBaseOffsetMeters;
const cameraTiltYDegrees = 9;
const signalAVerticalOffsetMeters = -0.03;
const mastBottomOffsets = [2.88, 2.61, 2.61, 2.34, 2.07] as const;
const greenKeys = new Set(['F1', 'F2', 'F3']);
const knownSignalKeys = ['F0', 'F1', 'F2', 'F3', 'F4', 'F5', 'A', 'H', 'M', 'T', 'V', 'abf', 's20', 's30'];

export const housingKindOptions: HousingKindOption[] = [
  ...[1, 2, 3, 4, 5].map((count) => ({
    label: `Mast ${count}`,
    signalCount: count,
    value: `MAST_${count}` as StructureSignalInstallerHousingKind,
  })),
  ...[1, 2, 3, 4, 5].map((count) => ({
    label: `Gehäuse ${count}`,
    signalCount: count,
    value: `HOUSING_${count}` as StructureSignalInstallerHousingKind,
  })),
  ...[1, 2, 3, 4, 5].map((count) => ({
    label: `Mast links ${count}`,
    signalCount: count,
    value: `MAST_LEFT_${count}` as StructureSignalInstallerHousingKind,
  })),
  ...[1, 2, 3, 4, 5].map((count) => ({
    label: `Mast rechts ${count}`,
    signalCount: count,
    value: `MAST_RIGHT_${count}` as StructureSignalInstallerHousingKind,
  })),
];

export function parseInstallerTag(tag: string | undefined): TagValues {
  const values: TagValues = {};
  if (!tag) return values;
  for (const match of tag.matchAll(/(\w+)=(.*?),/g)) {
    const key = match[1];
    const value = match[2];
    if (key && value !== undefined) values[key] = value;
  }
  return values;
}

export function encodeInstallerTag(values: TagValues): string {
  return Object.keys(values)
    .sort()
    .map((key) => `${key}=${values[key]},`)
    .join('');
}

export function inferHousingKind(name: string): StructureSignalInstallerHousingKind | undefined {
  const normalized = normalizeText(name);
  const count = Number(/(?:^|\s)([1-5])(?:\s|$)/.exec(normalized)?.[1]);
  if (!Number.isInteger(count) || count < 1 || count > 5) return undefined;
  if (normalized.includes('gehaeuse mast links')) return `MAST_LEFT_${count}` as StructureSignalInstallerHousingKind;
  if (normalized.includes('gehaeuse mast rechts')) return `MAST_RIGHT_${count}` as StructureSignalInstallerHousingKind;
  if (normalized.includes('gehaeuse mast')) return `MAST_${count}` as StructureSignalInstallerHousingKind;
  if (normalized.includes('gehaeuse')) return `HOUSING_${count}` as StructureSignalInstallerHousingKind;
  return undefined;
}

export function signalCountForHousingKind(kind: StructureSignalInstallerHousingKind | ''): number {
  return housingKindOptions.find((option) => option.value === kind)?.signalCount ?? 0;
}

export function isBuiltInMastHousing(kind: StructureSignalInstallerHousingKind): boolean {
  return /^MAST(?:_LEFT|_RIGHT)?_[1-5]$/.test(kind);
}

export function isHousingStructureName(name: string): boolean {
  const normalized = normalizeText(name);
  return normalized.includes('straba signal gehaeuse') && !normalized.includes('blendschutz');
}

export function isBlendStructureName(name: string): boolean {
  return normalizeText(name).includes('blendschutz');
}

export function isSignalStructureName(name: string): boolean {
  const normalized = normalizeText(name);
  return (
    normalized.includes('straba signal') && !normalized.includes('gehaeuse') && !normalized.includes('blendschutz')
  );
}

export function installedSignalsFromTag(tag: string | undefined, signalCount: number): string[] {
  const values = parseInstallerTag(tag);
  const byPosition = Array.from({ length: signalCount }, (_entry, index) => values[`p${index + 1}`] ?? '');
  if (byPosition.some((value) => value.trim())) return byPosition;
  const fallbackKeys = [
    'F0',
    'F1',
    'F2',
    'F3',
    'F4',
    'F5',
    'A',
    'H',
    'M',
    'T',
    'V',
    'abf',
    's20',
    's30',
    ...Object.keys(values)
      .filter((key) => /^W\d+a?$/.test(key))
      .sort((a, b) => a.localeCompare(b, undefined, { numeric: true })),
  ];
  return fallbackKeys
    .map((key) => values[key])
    .filter((value): value is string => Boolean(value?.trim()))
    .slice(0, signalCount)
    .concat(Array.from({ length: signalCount }, () => ''))
    .slice(0, signalCount);
}

export function buildInstallerTag(existingTag: string, signals: string[], blendName: string, housingName = ''): string {
  const values = parseInstallerTag(existingTag);
  Object.keys(values).forEach((key) => {
    if (
      knownSignalKeys.includes(key) ||
      key === 'bl' ||
      key === 'r' ||
      key === 'y' ||
      key === 'g' ||
      key === 'geh' ||
      /^p[1-5]$/.test(key) ||
      /^W\d+a?$/.test(key)
    ) {
      delete values[key];
    }
  });

  let firstGreenSignal = '';
  signals.forEach((signalName, index) => {
    const trimmedSignalName = signalName.trim();
    if (!trimmedSignalName) return;
    values[`p${index + 1}`] = trimmedSignalName;
    const key = tagKeyForSignalName(trimmedSignalName);
    if (key) {
      values[key] = trimmedSignalName;
      if (!firstGreenSignal && greenKeys.has(key)) firstGreenSignal = trimmedSignalName;
    }
  });
  if (blendName.trim()) values.bl = blendName.trim();
  if (values.F0) values.r = values.F0;
  if (values.F4) values.y = values.F4;
  if (firstGreenSignal) values.g = firstGreenSignal;
  if (housingName.trim()) values.geh = housingName.trim();
  return encodeInstallerTag(values);
}

export function buildAlignStructureSignalInstallerCommand(
  housing: StructureAppDto,
  housingKind: StructureSignalInstallerHousingKind,
  signals: string[],
  blendName: string,
): AlignStructureSignalInstallerCommandAppDto {
  const trimmedSignals = signals.map((signalName) => signalName.trim()).filter(Boolean);
  const trimmedBlendName = blendName.trim();
  const targets = [
    ...signals
      .map((signalName, index) => ({ signalName: signalName.trim(), index }))
      .filter((entry) => entry.signalName)
      .map(({ signalName, index }) => targetForSignal(housing, housingKind, signalName, index)),
    ...(trimmedBlendName ? [targetForBlend(housing, housingKind, trimmedBlendName)] : []),
  ];
  return {
    ...(trimmedBlendName ? { blendName: trimmedBlendName } : {}),
    housingKind,
    housingName: housing.name,
    housingTag: buildInstallerTag(housing.tag, signals, blendName, housing.name),
    signals: trimmedSignals,
    targets,
  };
}

export function buildFocusStructureSignalInstallerCameraCommand(
  housing: StructureAppDto,
): FocusStructureSignalInstallerCameraCommandAppDto {
  const yawRadians = degreesToRadians(housing.rot_z);
  const forwardX = Math.cos(yawRadians);
  const forwardY = Math.sin(yawRadians);
  const posX = housing.pos_x - forwardX * cameraDistanceMeters;
  const posY = housing.pos_y - forwardY * cameraDistanceMeters;
  const housingKind = inferHousingKind(housing.name);
  const heightOffset =
    housingKind && isBuiltInMastHousing(housingKind) ? cameraMastHeightOffsetMeters : cameraHousingHeightOffsetMeters;
  const posZ = housing.pos_z + heightOffset;
  const targetDeltaX = housing.pos_x - posX;
  const targetDeltaY = housing.pos_y - posY;
  return {
    posX: round3(posX),
    posY: round3(posY),
    posZ: round3(posZ),
    rotX: 0,
    rotY: cameraTiltYDegrees,
    rotZ: round3(radiansToDegrees(Math.atan2(targetDeltaY, targetDeltaX))),
  };
}

function normalizeText(value: string): string {
  return value
    .toLocaleLowerCase()
    .replace(/ä/g, 'ae')
    .replace(/ö/g, 'oe')
    .replace(/ü/g, 'ue')
    .replace(/ß/g, 'ss')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

function degreesToRadians(degrees: number): number {
  return (degrees * Math.PI) / 180;
}

function radiansToDegrees(radians: number): number {
  return (radians * 180) / Math.PI;
}

function round3(value: number): number {
  return Number(value.toFixed(3));
}

function tagKeyForSignalName(name: string): string | undefined {
  const normalized = normalizeText(name);
  const switchMatch = /signal weiche (w\d+a?)/.exec(normalized);
  if (switchMatch?.[1]) return switchMatch[1].toUpperCase();
  if (normalized.includes('vorfahrt beachten')) return 'F5';
  if (normalized.includes('geradeaus')) return 'F1';
  if (normalized.includes('rechts')) return 'F2';
  if (normalized.includes('anhalten')) return 'F4';
  if (normalized.includes('halt')) return 'F0';
  if (normalized.includes('links')) return 'F3';
  if (/(^|\s)signal a(\s|$)/.test(normalized)) return 'A';
  if (/(^|\s)signal h(\s|$)/.test(normalized)) return 'H';
  if (/(^|\s)signal m(\s|$)/.test(normalized)) return 'M';
  if (/(^|\s)signal t(\s|$)/.test(normalized)) return 'T';
  if (/(^|\s)signal v(\s|$)/.test(normalized)) return 'V';
  if (normalized.includes('abfahrt')) return 'abf';
  if (normalized.includes('20km')) return 's20';
  if (normalized.includes('30km')) return 's30';
  return undefined;
}

function signalOffset(kind: StructureSignalInstallerHousingKind, signalIndex: number, signalCount: number): number {
  const stackOffset = Math.max(0, signalCount - signalIndex - 1) * signalSpacingMeters;
  if (isVerticalMastHousing(kind)) {
    const bottomOffset = mastBottomOffsets[signalCount - 1] ?? mastBaseOffsetMeters;
    return bottomOffset + stackOffset;
  }
  return stackOffset;
}

function isVerticalMastHousing(kind: StructureSignalInstallerHousingKind): boolean {
  return /^MAST_[1-5]$/.test(kind);
}

function blendOffset(kind: StructureSignalInstallerHousingKind): number {
  const signalCount = signalCountForHousingKind(kind);
  return signalOffset(kind, Math.max(0, signalCount - 1), signalCount);
}

function targetForSignal(
  housing: StructureAppDto,
  housingKind: StructureSignalInstallerHousingKind,
  signalName: string,
  signalIndex: number,
): StructureSignalInstallerTargetAppDto {
  const signalAOffset = tagKeyForSignalName(signalName) === 'A' ? signalAVerticalOffsetMeters : 0;
  return targetForStructure(
    housing,
    signalName,
    signalOffset(housingKind, signalIndex, signalCountForHousingKind(housingKind)) + signalAOffset,
  );
}

function targetForBlend(
  housing: StructureAppDto,
  housingKind: StructureSignalInstallerHousingKind,
  blendName: string,
): StructureSignalInstallerTargetAppDto {
  return targetForStructure(housing, blendName, blendOffset(housingKind));
}

function targetForStructure(
  housing: StructureAppDto,
  name: string,
  zOffset: number,
): StructureSignalInstallerTargetAppDto {
  return {
    name,
    posX: housing.pos_x,
    posY: housing.pos_y,
    posZ: Number((housing.pos_z + zOffset).toFixed(3)),
    rotX: housing.rot_x,
    rotY: housing.rot_y,
    rotZ: housing.rot_z,
  };
}
