// Lua DtoFactory: lua/LUA/ce/hub/data/rollingstock/RollingStockDtoFactory.lua
// Room: rolling-stocks
export interface RollingStockLuaDto {
  id: string;
  name: string;
  trainName: string;
  positionInTrain: number;
  couplingFront: number;
  couplingRear: number;
  length: number;
  propelled: boolean;
  trackSystem: number;
  trackType: string;
  modelType: number;
  modelTypeText: string;
  tag: string;
  nr: string | undefined;
  trackId: number;
  trackDistance: number;
  trackDirection: number;
  posX: number;
  posY: number;
  posZ: number;
  mileage: number;
}
