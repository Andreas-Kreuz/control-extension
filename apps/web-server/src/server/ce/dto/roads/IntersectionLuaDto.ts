// Lua DtoFactory: lua/LUA/ce/mods/road/data/RoadDtoFactory.lua
// Room: intersections
export interface IntersectionLuaDto {
  id: string;
  name: string;
  currentSwitching: string;
  manualSwitching: string;
  nextSwitching: string;
  ready: boolean;
  timeForGreen: number;
  staticCams: boolean;
}
