// Produced by: apps/web-server/src/server/mod/road/RoadSelector.ts
export interface IntersectionDto {
  id: string;
  name: string;
  currentSwitching: string;
  manualSwitching: string;
  nextSwitching: string;
  ready: boolean;
  timeForGreen: number;
  staticCams: boolean;
}
