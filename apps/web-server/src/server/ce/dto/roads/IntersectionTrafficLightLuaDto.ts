// Lua DtoFactory: lua/LUA/ce/mods/road/data/RoadDtoFactory.lua
// Room: intersection-traffic-lights
export interface IntersectionTrafficLightLuaDto {
  id: string;
  signalId: number;
  modelId: string;
  currentPhase: string;
  intersectionId: string;
  lightStructures: number[];
  axisStructures: number[];
}
