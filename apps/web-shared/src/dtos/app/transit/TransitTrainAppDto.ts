// App contract populated by:
// apps/web-server/src/server/mod/transit/TransitSelector.ts
export interface TransitTrainNextStationAppDto {
  station: {
    name: string;
    platform: string;
  };
  departureInMinutes: number;
}

export interface TransitTrainAppDto {
  id: string;
  line?: string;
  destination?: string;
  direction?: string;
  nextStations?: TransitTrainNextStationAppDto[];
}
