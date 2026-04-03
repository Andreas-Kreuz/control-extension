// Produced by: web-server/src/server/mod/train/RollingStockDynamicSelector.ts
export interface RollingStockDynamicDto {
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
