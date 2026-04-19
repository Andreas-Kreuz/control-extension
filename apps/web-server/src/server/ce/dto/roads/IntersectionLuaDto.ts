// Lua DtoFactory: lua/LUA/ce/mods/road/data/RoadDtoFactory.lua
// Room: intersections
export interface IntersectionPhaseTrafficLightLuaDto {
  signalId: number;
  type: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
}

export interface IntersectionPhaseLuaDto {
  id: string;
  name: string;
  order: number;
  prio: number;
  greenPhaseSeconds: number;
  trafficLights: IntersectionPhaseTrafficLightLuaDto[];
}

export interface IntersectionLuaDto {
  id: number;
  name: string;
  currentSwitching: string;
  manualSwitching: string;
  nextSwitching: string;
  ready: boolean;
  timeForGreen: number;
  staticCams: string[];
  phases: IntersectionPhaseLuaDto[];
}
