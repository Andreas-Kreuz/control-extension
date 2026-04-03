// Produced by: web-server/src/server/mod/train/TrainDynamicSelector.ts
export interface TrainDynamicDto {
  id: string;
  speed: number;
  targetSpeed: number;
  couplingFront: number;
  couplingRear: number;
  active: boolean;
  inTrainyard: boolean;
  trainyardId?: number;
}
