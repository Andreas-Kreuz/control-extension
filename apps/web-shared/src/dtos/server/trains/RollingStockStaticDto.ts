// Produced by: web-server/src/server/mod/train/RollingStockStaticSelector.ts
export interface RollingStockStaticDto {
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
  nr?: string;
  trackType?: string;
  hookStatus: number;
  hookGlueMode: number;
}
