export interface TransitStationPlatformDto {
  nr: number;
  routes: string[];
}

export interface TransitStationQueueEntryDto {
  trainName: string;
  line: string;
  destination: string;
  timeInMinutes: number;
  platform: number;
}

export interface TransitStationDto {
  id: string;
  name?: string;
  platforms?: TransitStationPlatformDto[];
  queue?: TransitStationQueueEntryDto[];
}
