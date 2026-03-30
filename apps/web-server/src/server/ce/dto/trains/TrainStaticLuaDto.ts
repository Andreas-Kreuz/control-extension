// Lua DtoFactory: lua/LUA/ce/hub/data/trains/TrainStaticDtoFactory.lua
// Room: train-static
export interface TrainStaticLuaDto {
  id: string;
  name: string;
  trackType?: string;
  rollingStockCount: number;
  route: string;
  length: number;
  line?: string;
  destination?: string;
  direction?: string;
  movesForward: boolean;
}
