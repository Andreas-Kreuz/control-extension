// App contract populated by:
// apps/web-server/src/server/mod/transit/TransitSelector.ts
export interface TransitStationPlatformAppDto {
  nr: number;
  routes: string[];
}

export interface TransitStationQueueEntryAppDto {
  trainName: string;
  line: string;
  destination: string;
  timeInMinutes: number;
  platform: number;
}

export interface TransitStationAppDto {
  id: string;
  name?: string;
  platforms?: TransitStationPlatformAppDto[];
  queue?: TransitStationQueueEntryAppDto[];
}
