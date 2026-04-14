// Lua DtoFactory: lua/LUA/ce/mods/road/data/RoadDtoFactory.lua
// Room: intersection-traffic-lights
export interface IntersectionTrafficLightStructureLuaDto {
  structureRed?: string;
  structureGreen?: string;
  structureYellow?: string;
  structureRequest?: string;
}

export interface IntersectionTrafficLightAxisStructureLuaDto {
  structureName: string;
  axisName: string;
  positionDefault: number;
  positionRed?: number;
  positionGreen?: number;
  positionYellow?: number;
  positionPedestrian?: number;
  positionRedYellow?: number;
}

export interface IntersectionTrafficLightLuaDto {
  id: number;
  signalId: number;
  modelId: string;
  currentPhase: string;
  intersectionId: number;
  lightStructures: Record<string, IntersectionTrafficLightStructureLuaDto>;
  axisStructures: IntersectionTrafficLightAxisStructureLuaDto[];
}
