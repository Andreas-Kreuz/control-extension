// Lua DtoFactory: lua/LUA/ce/hub/data/rollingstock/RollingStockStaticDtoFactory.lua
// Room: rollingstock-static
export interface RollingStockStaticLuaDto {
  id: string;
  name: string;
  trainName: string;
  positionInTrain: number;
  couplingFront: number;
  couplingRear: number;
  length: number;
  propelled: boolean;
  trackType?: string;
  modelType: number;
  modelTypeText: string;
  tag: string;
  nr?: string;
  hookStatus: number;
  hookGlueMode: number;
}
