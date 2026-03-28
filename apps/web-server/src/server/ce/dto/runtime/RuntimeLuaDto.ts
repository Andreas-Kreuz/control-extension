// Lua DtoFactory: lua/LUA/ce/hub/data/runtime/RuntimeDtoFactory.lua
// Room: runtime
export interface RuntimeLuaDto {
  id: string;
  count: number;
  time: number;
  lastTime: number;
  framesPerSecond?: number;
  currentFrame?: number;
  currentRenderFrame?: number;
}
