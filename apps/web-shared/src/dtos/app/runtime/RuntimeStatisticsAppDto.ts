// App contract populated by:
// apps/web-server/src/server/mod/eepdata/EepDataSelector.ts
export interface RuntimeStatisticsTimeAppDto {
  id: string;
  ms: number;
}

export interface RuntimeStatisticsHistoryAppDto {
  publisherSyncTimes: RuntimeStatisticsTimeAppDto[][];
  moduleRunTimes: RuntimeStatisticsTimeAppDto[][];
  updateTimes: RuntimeStatisticsTimeAppDto[][];
  controllerUpdateTimes: RuntimeStatisticsTimeAppDto[][];
  sampleEventCounters: number[];
}

export interface RuntimeStatisticsInitializationAppDto {
  publisherInitTimes: RuntimeStatisticsTimeAppDto[];
  moduleInitTimes: RuntimeStatisticsTimeAppDto[];
}

export interface RuntimeStatisticsAppDto {
  history: RuntimeStatisticsHistoryAppDto;
  initialization: RuntimeStatisticsInitializationAppDto;
}
