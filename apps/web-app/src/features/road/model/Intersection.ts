export interface IntersectionPhaseSignalHead {
  signalId: number;
  signalHeadKind?: 'VEHICLE' | 'PEDESTRIAN';
  signalHeadKey?: string;
  signalHeadName?: string;
  type: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
  vehicleSignalHeadName?: string;
  pedestrianSignalHeadName?: string;
  use: 'VEHICLE_ONLY' | 'PEDESTRIAN_ONLY' | 'VEHICLE_AND_PEDESTRIAN';
}

export interface IntersectionPhase {
  id: string;
  name: string;
  order: number;
  prio: number;
  greenTimeSeconds: number;
  signalHeads: IntersectionPhaseSignalHead[];
}

export default interface Intersection {
  id: number;
  name: string;
  greenTimeSeconds: number;
  ready: boolean;
  currentPhase: string;
  manualPhase: string;
  nextPhase: string;
  staticCams: string[];
  phases: IntersectionPhase[];
}
