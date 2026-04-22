// App contract populated by:
// apps/web-server/src/server/mod/train/TrainSelector.ts
export interface TrainAppDto {
  id: string;
  name: string;
  route: string;
  rollingStockCount: number;
  length: number;
  speed: number;
  targetSpeed: number;
  couplingFront: number;
  couplingRear: number;
  active: boolean;
  inTrainyard: boolean;
  movesForward: boolean;
  line?: string;
  destination?: string;
  direction?: string;
  nextStations?: TrainNextStationAppDto[];
  trackType?: string;
  trainyardId?: number | string;
}

export interface TrainNextStationAppDto {
  station: {
    name: string;
    platform: string;
  };
  departureInMinutes: number;
}
