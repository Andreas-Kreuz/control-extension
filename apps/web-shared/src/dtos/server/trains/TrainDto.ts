// Produced by: web-server/src/server/mod/train/TrainSelector.ts
import { RollingStockDto } from './RollingStockDto';
import { TrainListDto } from './TrainListDto';

export interface TrainDto extends TrainListDto {
  rollingStock: RollingStockDto[];
  length: number;
  direction: string;
  speed: number;
}
