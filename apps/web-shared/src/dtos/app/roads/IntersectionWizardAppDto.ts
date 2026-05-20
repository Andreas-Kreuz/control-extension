// App contract populated by:
// apps/web-server/src/server/mod/road/IntersectionWizardService.ts
export type IntersectionWizardTurnDirection = 'LEFT' | 'HALF_LEFT' | 'STRAIGHT' | 'HALF_RIGHT' | 'RIGHT';

export type IntersectionWizardApproach =
  | 'NORTH'
  | 'NORTH_EAST'
  | 'EAST'
  | 'SOUTH_EAST'
  | 'SOUTH'
  | 'SOUTH_WEST'
  | 'WEST'
  | 'NORTH_WEST';

export type IntersectionWizardTrafficType = 'CAR' | 'TRAM' | 'PEDESTRIAN';

export type IntersectionWizardAmpelUse = 'VEHICLE_ONLY' | 'PEDESTRIAN_ONLY' | 'VEHICLE_AND_PEDESTRIAN';

export type IntersectionWizardAmpelKind = 'SIGNAL' | 'STRUCTURE_LIGHT';

export type IntersectionWizardLaneCountType = 'CONTACTS' | 'SIGNALS' | 'TRACKS';

export type IntersectionWizardLaneSignalSource = 'OWN' | 'SIGNAL_GROUP';

export type IntersectionWizardSignalGroupAssignmentMode = 'DEFAULT' | 'ONLY' | 'ALSO';

export interface IntersectionWizardSignalLookupAppDto {
  id: string;
  found: boolean;
  position?: number;
  tag?: string;
  itemName?: string;
  itemNameWithModelPath?: string;
  signalFunctions?: string[];
  activeFunction?: string;
  suggestedTrafficLightModel?: string;
  suggestedTrafficLightModelConstant?: string;
}

export interface IntersectionWizardLaneAppDto {
  id: string;
  name: string;
  luaVariableName?: string;
  vehicleMultiplier?: number;
  countType?: IntersectionWizardLaneCountType;
  requestTrackIds?: number[];
  highlightTrackIds?: number[];
  approach: IntersectionWizardApproach;
  signalSource: IntersectionWizardLaneSignalSource;
  signalGroupSignalId?: string;
  signal: IntersectionWizardLaneSignalAppDto;
  signalGroupAssignments: IntersectionWizardSignalGroupAssignmentAppDto[];
}

export interface IntersectionWizardLaneSignalAppDto {
  name: string;
  signalId?: string;
  modelName: string;
  modelConstant: string;
  lightStructures?: IntersectionWizardLightStructureAppDto[];
  axisStructures?: IntersectionWizardAxisStructureAppDto[];
}

export interface IntersectionWizardSignalGroupAssignmentAppDto {
  signalGroupId: string;
  mode: IntersectionWizardSignalGroupAssignmentMode;
  routeNames?: string[];
}

export interface IntersectionWizardAmpelAppDto {
  id: string;
  name: string;
  kind?: IntersectionWizardAmpelKind;
  pedestrianName?: string;
  signalId?: string;
  sourceAmpelId?: string;
  use: IntersectionWizardAmpelUse;
  trafficType: IntersectionWizardTrafficType;
  modelName: string;
  modelConstant: string;
  lightStructures?: IntersectionWizardLightStructureAppDto[];
  axisStructures?: IntersectionWizardAxisStructureAppDto[];
}

export interface IntersectionWizardLightStructureAppDto {
  structureRed?: string;
  structureGreen?: string;
  structureYellow?: string;
  structureRequest?: string;
}

export interface IntersectionWizardAxisStructureAppDto {
  structureName: string;
  axisName: string;
  positionDefault: number;
  positionRed?: number;
  positionGreen?: number;
  positionYellow?: number;
  positionPedestrian?: number;
  positionRedYellow?: number;
}

export interface IntersectionWizardSignalGroupAppDto {
  id: string;
  name: string;
  approach: IntersectionWizardApproach;
  turnDirections: IntersectionWizardTurnDirection[];
  trafficType: IntersectionWizardTrafficType;
  showRequests: boolean;
  pedestrianCrossingName?: string;
  pedestrianCrossingLuaVariableName?: string;
  ampelIds: string[];
}

export interface IntersectionWizardPhaseAppDto {
  id: string;
  name: string;
  greenTimeSeconds?: number;
  signalGroupIds: string[];
}

export interface IntersectionWizardDraftAppDto {
  id: string;
  name: string;
  luaVariableName: string;
  greenTimeSeconds?: number;
  intersectionEepSaveId?: number;
  tippStructure?: string;
  switchInStrictOrder?: boolean;
  showLuaCodeImmediately?: boolean;
  manualLuaVariableNames?: boolean;
  individualLanePhaseSettings?: boolean;
  supportPedestrianSignals?: boolean;
  supportMultipleLaneSignals?: boolean;
  supportStructureLightSignals?: boolean;
  staticCams?: string[];
  createdAt: string;
  updatedAt: string;
  lanes: IntersectionWizardLaneAppDto[];
  ampeln: IntersectionWizardAmpelAppDto[];
  signalGroups: IntersectionWizardSignalGroupAppDto[];
  phases: IntersectionWizardPhaseAppDto[];
  generatedLua: string;
}

export interface IntersectionWizardDraftSummaryAppDto {
  id: string;
  name: string;
  updatedAt: string;
  lanesCount: number;
  signalGroupsCount: number;
  phasesCount: number;
}

export interface IntersectionWizardGenerateResultAppDto {
  draft: IntersectionWizardDraftAppDto;
  lua: string;
  warnings: string[];
}
