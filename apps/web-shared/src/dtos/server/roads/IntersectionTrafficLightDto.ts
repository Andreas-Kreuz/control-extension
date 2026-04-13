// Produced by: apps/web-server/src/server/mod/road/RoadSelector.ts
export interface IntersectionTrafficLightStructureDto {
  structureRed?: string;
  structureGreen?: string;
  structureYellow?: string;
  structureRequest?: string;
}

export interface IntersectionTrafficLightAxisStructureDto {
  structureName: string;
  axisName: string;
  positionDefault: number;
  positionRed?: number;
  positionGreen?: number;
  positionYellow?: number;
  positionPedestrian?: number;
  positionRedYellow?: number;
}

export interface IntersectionTrafficLightDto {
  id: number;
  signalId: number;
  modelId: string;
  currentPhase: string;
  intersectionId: number;
  lightStructures: Record<string, IntersectionTrafficLightStructureDto>;
  axisStructures: IntersectionTrafficLightAxisStructureDto[];
}
