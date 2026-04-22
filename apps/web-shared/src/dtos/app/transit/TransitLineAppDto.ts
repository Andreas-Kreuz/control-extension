// App contract populated by:
// apps/web-server/src/server/mod/transit/TransitSelector.ts
import { TransitLineSegmentAppDto } from './TransitLineSegmentAppDto';

export interface TransitLineAppDto {
  id: string;
  nr: number;
  trafficType: string;
  lineSegments: TransitLineSegmentAppDto[];
}
