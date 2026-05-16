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
  signalHeads: IntersectionPhaseSignalHeadLuaDto[];
}

export interface IntersectionLuaDto {
  id: number;
  name: string;
  currentPhase: string;
  manualPhase: string;
  nextPhase: string;
  ready: boolean;
  greenTimeSeconds: number;
  staticCams: string[];
  phases: IntersectionPhaseTimingLuaDto[];
}
