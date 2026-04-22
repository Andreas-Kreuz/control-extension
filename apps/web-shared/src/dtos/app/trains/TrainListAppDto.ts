// App contract populated by:
// apps/web-server/src/server/mod/train/TrainSelector.ts
import { TrainType } from '../../../model/trains/TrainType';

export interface TrainListAppDto {
  id: string;
  name: string;
  route: string;
  line?: string;
  destination?: string;
  via?: string;
  firstRollingStockName: string;
  lastRollingStockName: string;
  trainType: TrainType;
  trackType?: string;
  rollingStockCount: number;
  movesForward: boolean;
}
