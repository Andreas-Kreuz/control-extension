// Produced by: lua/LUA/ce/hub/data/trains/TrainDtoFactory.lua
export interface TrainDto {
  ceType?: string;
  id: string;
  name: string;
  route: string;
  rollingStockCount: number;
  length: number;
  speed: number;
  targetSpeed: number;
  couplingFront: number;
  couplingRear: number;
  active: boolean;
  inTrainyard: boolean;
  movesForward: boolean;
  line?: string;
  destination?: string;
  direction?: string;
  trackType?: string;
  trainyardId?: number | string;
}
