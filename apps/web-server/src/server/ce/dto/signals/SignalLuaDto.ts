// Lua DtoFactory: lua/LUA/ce/hub/data/signals/SignalDtoFactory.lua
// Room: signals
export interface SignalLuaDto {
  id: string;
  position: number;
  tag: string;
  waitingVehiclesCount: number;
  stopDistance?: number;
  itemName?: string;
  itemNameWithModelPath?: string;
  signalFunctions?: string[];
  activeFunction?: string;
}
