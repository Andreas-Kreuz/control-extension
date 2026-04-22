// App contract populated by:
// apps/web-server/src/server/mod/road/RoadSelector.ts
export interface IntersectionTrafficLightStructureAppDto {
  structureRed?: string;
  structureGreen?: string;
  structureYellow?: string;
  structureRequest?: string;
}

export interface IntersectionTrafficLightAxisStructureAppDto {
  structureName: string;
  axisName: string;
  positionDefault: number;
  positionRed?: number;
  positionGreen?: number;
  positionYellow?: number;
  positionPedestrian?: number;
  positionRedYellow?: number;
}

export interface IntersectionTrafficLightAppDto {
  id: number;
  signalId: number;
  trafficSignalName?: string;
  pedestrianSignalName?: string;
  use: 'TRAFFIC_ONLY' | 'PEDESTRIAN_ONLY' | 'TRAFFIC_AND_PEDESTRIAN';
  modelId: string;
  currentPhase: string;
  intersectionId: number;
  lightStructures: Record<string, IntersectionTrafficLightStructureAppDto>;
  axisStructures: IntersectionTrafficLightAxisStructureAppDto[];
}
