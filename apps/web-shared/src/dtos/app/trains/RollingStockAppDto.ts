// App contract populated by:
// apps/web-server/src/server/mod/train/RollingStockSelector.ts
export interface RollingStockAppDto {
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
  axisNamesKnown: boolean;
  axisNames: Record<string, string>;
  axisValues: Record<string, number>;
  surfaceTexts: Record<string, string>;
  textureNames: Record<string, string>;
  rotX: number;
  rotY: number;
  rotZ: number;
  licencePlate?: string;
  vehicleNumber?: string;
  nr?: string;
  trackType?: string;
  xmlModel?: string;
}
