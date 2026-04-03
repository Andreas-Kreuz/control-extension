// Produced by: apps/web-server/src/server/mod/transit/TransitSelector.ts
import { TransitLineSegmentDto } from './TransitLineSegmentDto';

export interface TransitLineDto {
  id: string;
  nr: number;
  trafficType: string;
  lineSegments: TransitLineSegmentDto[];
}
