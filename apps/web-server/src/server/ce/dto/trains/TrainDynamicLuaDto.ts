// Lua DtoFactory: lua/LUA/ce/hub/data/trains/TrainDynamicDtoFactory.lua
// Room: train-dynamic
export interface TrainDynamicLuaDto {
  id: string;
  speed: number;
  targetSpeed: number;
  couplingFront: number;
  couplingRear: number;
  active: boolean;
  inTrainyard: boolean;
  trainyardId?: number;
}
