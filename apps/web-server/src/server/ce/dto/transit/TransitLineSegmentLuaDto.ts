// Lua DtoFactory: lua/LUA/ce/mods/transit/data/TransitDtoFactory.lua
// Nested within TransitLineLuaDto.lineSegments
export interface TransitLineSegmentStation {
  name: string;
  timeToStation: number;
}

export interface TransitLineSegmentLuaDto {
  id: string;
  destination: string;
  routeName: string;
  lineNr: number;
  stations: TransitLineSegmentStation[];
}
