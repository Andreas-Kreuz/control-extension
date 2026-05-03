export interface TransitTrainNextStationLuaDto {
  station: {
    name: string;
    platform: string;
  };
  departureInMinutes: number;
}

export interface TransitTrainLuaDto {
  ceType?: string;
  id: string;
  line?: string;
  destination?: string;
  origin?: string;
  direction?: string;
  nextStations?: TransitTrainNextStationLuaDto[];
}
