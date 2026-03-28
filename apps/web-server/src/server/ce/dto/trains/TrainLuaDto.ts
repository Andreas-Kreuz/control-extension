// Lua DtoFactory: lua/LUA/ce/hub/data/trains/TrainDtoFactory.lua
// Room: trains
export interface TrainLuaDto {
  id: string;
  name: string;
  trackType: string;
  rollingStockCount: number;
  route: string;
  length: number;
  line: string;
  destination: string;
  direction: string;
  speed: number;
  movesForward: boolean;
  occupiedTacks: Record<string, number>;
  targetSpeed?: number;
  couplingFront?: number;
  couplingRear?: number;
  active?: boolean;
  trainyardId?: number;
  inTrainyard?: boolean;
}
