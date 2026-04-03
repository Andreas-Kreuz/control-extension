// Lua DtoFactory: lua/LUA/ce/hub/data/rollingstock/RollingStockDynamicDtoFactory.lua
// Room: rollingstock-dynamic
export interface RollingStockDynamicLuaDto {
  id: string;
  trackSystem: number;
  trackId: number;
  trackDistance: number;
  trackDirection: number;
  posX: number;
  posY: number;
  posZ: number;
  mileage: number;
  orientationForward: boolean;
  smoke: number;
  active: boolean;
}
