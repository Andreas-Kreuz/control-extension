// Lua DtoFactory: lua/LUA/ce/mods/road/data/RoadDtoFactory.lua
// Room: intersection-lanes
export interface IntersectionLaneLuaDto {
  id: string;
  intersectionId: string;
  name: string;
  phase: number;
  vehicleMultiplier: number;
  eepSaveId: number;
  type: string;
  countType: string;
  waitingTrains: number;
  waitingForGreenCyclesCount: number;
  directions: string[];
  switchings: string[];
  tracks: string[];
}
