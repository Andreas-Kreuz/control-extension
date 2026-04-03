// Produced by: apps/web-server/src/server/mod/road/RoadSelector.ts
export interface IntersectionLaneDto {
  id: string;
  intersectionId: string;
  name: string;
  phase: number;
  vehicleMultiplier: number;
  eepSaveId: number;
  type: string;
  countType: string;
  waitingTrains: number;
  waitingForGreenCyclesCount: number;
  directions: string[];
  switchings: string[];
  tracks: string[];
}
