// Lua DtoFactory: lua/LUA/ce/mods/road/data/RoadDtoFactory.lua
// Room: intersection-lanes
export interface IntersectionLaneLuaDto {
  id: string;
  intersectionId: number;
  name: string;
  phase: string;
  vehicleMultiplier: number;
  eepSaveId: number;
  type: string;
  countType: string;
  waitingTrains: string[];
  waitingForGreenCyclesCount: number;
  directions: string[];
  switchings: string[];
  tracks: number[];
}
