// App contract populated by:
// apps/web-server/src/server/mod/transit/TransitSelector.ts
import { TransitLineSegmentStationAppDto } from './TransitLineSegmentStationAppDto';

export interface TransitLineSegmentAppDto {
  id: string;
  destination: string;
  routeName: string;
  lineNr: number;
  stations: TransitLineSegmentStationAppDto[];
}
