export interface TrainLuaDto {
  ceType?: string;
  id: string;
  // static fields (optional for patches)
  name?: string;
  route?: string;
  rollingStockCount?: number;
  length?: number;
  line?: string;
  destination?: string;
  direction?: string;
  trackType?: string;
  movesForward?: boolean;
  // dynamic fields (optional for patches)
  speed?: number;
  targetSpeed?: number;
  couplingFront?: number;
  couplingRear?: number;
  active?: boolean;
  inTrainyard?: boolean;
  trainyardId?: number | string;
}
