// Lua DtoFactory: lua/LUA/ce/mods/transit/data/TransitDtoFactory.lua
// Room: transit-lines (or similar transit line room)
import { TransitLineSegmentLuaDto } from './TransitLineSegmentLuaDto';

export interface TransitLineLuaDto {
  id: string;
  nr: number;
  trafficType: string;
  lineSegments: TransitLineSegmentLuaDto[];
}
