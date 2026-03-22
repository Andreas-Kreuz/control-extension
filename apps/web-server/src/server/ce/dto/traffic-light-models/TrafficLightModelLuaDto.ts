// Lua DtoFactory: lua/LUA/ce/mods/road/data/TrafficLightModelDtoFactory.lua
// Room: signal-type-definitions
export interface TrafficLightModelLuaDto {
  id: string;
  name: string;
  type: string;
  positionRed: number;
  positionGreen: number;
  positionYellow: number;
  positionRedYellow: number;
  positionPedestrians: number;
  positionOff: number;
  positionOffBlinking: number;
}
