// Produced by: lua/LUA/ce/hub/data/rollingstock/RollingStockDtoFactory.lua
export interface RollingStockDto {
  ceType?: string;
  id: string;
  name: string;
  trainName: string;
  positionInTrain: number;
  couplingFront: number;
  couplingRear: number;
  length: number;
  propelled: boolean;
  modelType: number;
  modelTypeText: string;
  tag: string;
  hookStatus: number;
  hookGlueMode: number;
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
  surfaceTexts: Record<string, string>;
  rotX: number;
  rotY: number;
  rotZ: number;
  nr?: string;
  trackType?: string;
}
