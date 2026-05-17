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
  signalGroups: string[];
  signalHeads: IntersectionPhaseSignalHead[];
}

export interface IntersectionSignalGroup {
  name: string;
  trafficType: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
  signalIds: number[];
}

export default interface Intersection {
  id: number;
  name: string;
  eepSaveId?: number;
  scriptVariableName?: string;
  switchInStrictOrder?: boolean;
  greenTimeSeconds: number;
  ready: boolean;
  currentPhase: string;
  manualPhase: string;
  nextPhase: string;
  tippStructure?: string;
  staticCams: string[];
  phases: IntersectionPhase[];
  signalGroupDefinitions: IntersectionSignalGroup[];
}
