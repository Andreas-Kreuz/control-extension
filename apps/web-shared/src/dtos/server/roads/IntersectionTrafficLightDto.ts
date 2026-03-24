// Produced by: apps/web-server/src/server/mod/road/RoadSelector.ts
export interface IntersectionTrafficLightDto {
  id: string;
  signalId: number;
  modelId: string;
  currentPhase: string;
  intersectionId: string;
  lightStructures: number[];
  axisStructures: number[];
}
