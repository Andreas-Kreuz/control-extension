// Produced by: apps/web-server/src/server/mod/transit/TransitSelector.ts
import { TransitLineSegmentStationDto } from './TransitLineSegmentStationDto';

export interface TransitLineSegmentDto {
  id: string;
  destination: string;
  routeName: string;
  lineNr: number;
  stations: TransitLineSegmentStationDto[];
}
