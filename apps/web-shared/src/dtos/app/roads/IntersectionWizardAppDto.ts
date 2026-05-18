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

export type IntersectionWizardTrafficType = 'CAR' | 'BUS' | 'TRAM' | 'BICYCLE' | 'PEDESTRIAN';

export type IntersectionWizardAmpelUse = 'VEHICLE_ONLY' | 'PEDESTRIAN_ONLY' | 'VEHICLE_AND_PEDESTRIAN';

export type IntersectionWizardLaneCountType = 'CONTACTS' | 'SIGNALS' | 'TRACKS';

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
  signalId: string;
  approach?: IntersectionWizardApproach;
  heading?: IntersectionWizardApproach;
  turnDirections: IntersectionWizardTurnDirection[];
}

export interface IntersectionWizardPedestrianCrossingAppDto {
  id: string;
  name: string;
  luaVariableName?: string;
  approach: IntersectionWizardApproach;
  heading?: IntersectionWizardApproach;
  signalGroupId: string;
}

export interface IntersectionWizardAmpelAppDto {
  id: string;
  name: string;
  pedestrianName?: string;
  signalId: string;
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
  laneIds: string[];
  turnDirections: IntersectionWizardTurnDirection[];
  trafficType: IntersectionWizardTrafficType;
  ampelIds: string[];
}

export interface IntersectionWizardPhaseAppDto {
  id: string;
  name: string;
  greenTimeSeconds?: number;
  signalGroupIds: string[];
}

export type IntersectionWizardRouteRuleMode = 'ONLY' | 'ALSO';

export interface IntersectionWizardRouteRuleAppDto {
  id: string;
  laneId: string;
  routeNames: string[];
  signalGroupIds: string[];
  mode: IntersectionWizardRouteRuleMode;
  showRequests: boolean;
}

export interface IntersectionWizardDefaultRequestDisplayAppDto {
  laneId: string;
  signalGroupId: string;
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
  staticCams?: string[];
  createdAt: string;
  updatedAt: string;
  lanes: IntersectionWizardLaneAppDto[];
  pedestrianCrossings?: IntersectionWizardPedestrianCrossingAppDto[];
  ampeln: IntersectionWizardAmpelAppDto[];
  signalGroups: IntersectionWizardSignalGroupAppDto[];
  routeRules?: IntersectionWizardRouteRuleAppDto[];
  defaultRequestDisplays?: IntersectionWizardDefaultRequestDisplayAppDto[];
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
