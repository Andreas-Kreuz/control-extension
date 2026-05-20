// Lua DtoFactory: lua/LUA/ce/mods/road/data/RoadDtoFactory.lua
// Room: intersections
export interface IntersectionPhaseSignalHeadLuaDto {
  signalId: number;
  signalHeadKind?: 'VEHICLE' | 'PEDESTRIAN';
  signalHeadKey?: string;
  signalHeadName?: string;
  type: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
  vehicleSignalHeadName?: string;
  pedestrianSignalHeadName?: string;
  use: 'VEHICLE_ONLY' | 'PEDESTRIAN_ONLY' | 'VEHICLE_AND_PEDESTRIAN';
}

export interface IntersectionPhaseTimingLuaDto {
  id: string;
  name: string;
  order: number;
  prio: number;
  greenTimeSeconds: number;
  signalGroups?: string[];
  signalHeads: IntersectionPhaseSignalHeadLuaDto[];
}

export interface IntersectionSignalGroupLuaDto {
  name: string;
  scriptVariableName?: string;
  approach?: string;
  turnDirections?: string[];
  trafficType: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
  signalIds: number[];
  pedestrianCrossingNames?: string[];
}

export interface IntersectionPedestrianCrossingLuaDto {
  name: string;
  scriptVariableName?: string;
  approach?: string;
  heading?: string;
  signalGroups: string[];
}

export interface IntersectionLuaDto {
  id: number;
  name: string;
  eepSaveId?: number;
  scriptVariableName?: string;
  switchInStrictOrder?: boolean;
  currentPhase: string;
  manualPhase: string;
  nextPhase: string;
  ready: boolean;
  greenTimeSeconds: number;
  tippStructure?: string;
  staticCams: string[];
  phases: IntersectionPhaseTimingLuaDto[];
  signalGroupDefinitions?: IntersectionSignalGroupLuaDto[];
  pedestrianCrossings?: IntersectionPedestrianCrossingLuaDto[];
}
