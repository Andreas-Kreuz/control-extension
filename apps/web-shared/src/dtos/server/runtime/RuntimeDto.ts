// Produced by: apps/web-server/src/server/mod/runtime/RuntimeSelector.ts
export interface RuntimeDto {
  id: string;
  count: number;
  time: number;
  lastTime: number;
  framesPerSecond?: number;
  currentFrame?: number;
  currentRenderFrame?: number;
}
