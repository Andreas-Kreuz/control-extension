// Produced by: web-server/src/server/mod/train/TrainStaticSelector.ts
import { TrainListDto } from './TrainListDto';

export interface TrainStaticDto extends TrainListDto {
  length: number;
  direction?: string;
}
