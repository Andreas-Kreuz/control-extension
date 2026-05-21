// App contract populated by:
// apps/web-server/src/server/mod/road/registerRoadMod.ts
export type StructureSignalInstallerHousingKind =
  | 'HOUSING_1'
  | 'HOUSING_2'
  | 'HOUSING_3'
  | 'HOUSING_4'
  | 'HOUSING_5'
  | 'MAST_1'
  | 'MAST_2'
  | 'MAST_3'
  | 'MAST_4'
  | 'MAST_5'
  | 'MAST_LEFT_1'
  | 'MAST_LEFT_2'
  | 'MAST_LEFT_3'
  | 'MAST_LEFT_4'
  | 'MAST_LEFT_5'
  | 'MAST_RIGHT_1'
  | 'MAST_RIGHT_2'
  | 'MAST_RIGHT_3'
  | 'MAST_RIGHT_4'
  | 'MAST_RIGHT_5';

export interface StructureSignalInstallerTargetAppDto {
  name: string;
  posX: number;
  posY: number;
  posZ: number;
  rotX: number;
  rotY: number;
  rotZ: number;
}

export interface AlignStructureSignalInstallerCommandAppDto {
  blendName?: string;
  housingKind: StructureSignalInstallerHousingKind;
  housingName: string;
  housingTag: string;
  signals: string[];
  targets: StructureSignalInstallerTargetAppDto[];
}
