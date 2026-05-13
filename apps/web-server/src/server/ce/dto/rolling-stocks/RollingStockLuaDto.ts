export interface RollingStockLuaDto {
  ceType?: string;
  id: string;
  // static
  name?: string;
  trainName?: string;
  positionInTrain?: number;
  couplingFront?: number;
  couplingRear?: number;
  length?: number;
  propelled?: boolean;
  modelType?: number;
  modelTypeText?: string;
  tag?: string;
  licencePlate?: string;
  vehicleNumber?: string;
  nr?: string;
  trackType?: string;
  hookStatus?: number;
  hookGlueMode?: number;
  // dynamic
  trackId?: number;
  trackDistance?: number;
  trackDirection?: number;
  trackSystem?: number;
  posX?: number;
  posY?: number;
  posZ?: number;
  mileage?: number;
  orientationForward?: boolean;
  smoke?: number;
  active?: boolean;
  // axes
  axisNamesKnown?: boolean;
  axisNames?: Record<string, string> | string[];
  axisValues?: Record<string, number> | number[];
  // textures
  surfaceTexts?: Record<string, string> | string[];
  textureNames?: Record<string, string> | string[];
  // rotation
  rotX?: number;
  rotY?: number;
  rotZ?: number;
  // xml
  xmlModel?: string;
}
