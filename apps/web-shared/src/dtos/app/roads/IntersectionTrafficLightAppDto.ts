// App contract populated by:
// apps/web-server/src/server/mod/road/RoadSelector.ts
export interface IntersectionTrafficLightStructureAppDto {
  structureBlend?: string;
  structureRed?: string;
  structureGreen?: string;
  structureHousing?: string;
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
  vehicleSignalName?: string;
  pedestrianSignalName?: string;
  use: 'VEHICLE_ONLY' | 'PEDESTRIAN_ONLY' | 'VEHICLE_AND_PEDESTRIAN';
  modelId: string;
  currentIndication: string;
  intersectionId: number;
  lightStructures: Record<string, IntersectionTrafficLightStructureAppDto>;
  axisStructures: IntersectionTrafficLightAxisStructureAppDto[];
}
