// Produced by: apps/web-server/src/server/mod/transit/TransitSelector.ts
export interface TransitTrainNextStationDto {
  station: {
    name: string;
    platform: string;
  };
  departureInMinutes: number;
}

export interface TransitTrainDto {
  id: string;
  line?: string;
  destination?: string;
  direction?: string;
  nextStations?: TransitTrainNextStationDto[];
}
