// App contract populated by:
// apps/web-server/src/server/mod/road/RoadSelector.ts
export interface IntersectionPhaseSignalHeadAppDto {
  signalId: number;
  signalHeadKind?: 'VEHICLE' | 'PEDESTRIAN';
  signalHeadKey?: string;
  signalHeadName?: string;
  type: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
  vehicleSignalHeadName?: string;
  pedestrianSignalHeadName?: string;
  use: 'VEHICLE_ONLY' | 'PEDESTRIAN_ONLY' | 'VEHICLE_AND_PEDESTRIAN';
}

export interface IntersectionPhaseTimingAppDto {
  id: string;
  name: string;
  order: number;
  prio: number;
  greenTimeSeconds: number;
  signalHeads: IntersectionPhaseSignalHeadAppDto[];
}

export interface IntersectionAppDto {
  id: number;
  name: string;
  currentPhase: string;
  manualPhase: string;
  nextPhase: string;
  ready: boolean;
  greenTimeSeconds: number;
  staticCams: string[];
  phases: IntersectionPhaseTimingAppDto[];
}
