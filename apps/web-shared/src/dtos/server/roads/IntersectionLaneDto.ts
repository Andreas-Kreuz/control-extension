// Produced by: apps/web-server/src/server/mod/road/RoadSelector.ts
export interface IntersectionLaneDto {
  id: string;
  intersectionId: number;
  name: string;
  phase: string;
  vehicleMultiplier: number;
  eepSaveId: number;
  type: string;
  countType: string;
  waitingTrains: string[];
  waitingForGreenCyclesCount: number;
  directions: string[];
  switchings: string[];
  tracks: number[];
}
