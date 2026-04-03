// Produced by: apps/web-server/src/server/mod/eepdata/EepDataSelector.ts
export interface RuntimeStatisticsTimeDto {
  id: string;
  ms: number;
}

export interface RuntimeStatisticsHistoryDto {
  publisherSyncTimes: RuntimeStatisticsTimeDto[][];
  moduleRunTimes: RuntimeStatisticsTimeDto[][];
  controllerUpdateTimes: RuntimeStatisticsTimeDto[][];
  sampleEventCounters: number[];
}

export interface RuntimeStatisticsInitializationDto {
  publisherInitTimes: RuntimeStatisticsTimeDto[];
  moduleInitTimes: RuntimeStatisticsTimeDto[];
}

export interface RuntimeStatisticsDto {
  history: RuntimeStatisticsHistoryDto;
  initialization: RuntimeStatisticsInitializationDto;
}
