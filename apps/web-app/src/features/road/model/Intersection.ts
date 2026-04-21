export interface IntersectionPhaseTrafficLight {
  signalId: number;
  signalKind?: 'TRAFFIC' | 'PEDESTRIAN';
  signalKey?: string;
  signalName?: string;
  type: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
  trafficSignalName?: string;
  pedestrianSignalName?: string;
  use: 'TRAFFIC_ONLY' | 'PEDESTRIAN_ONLY' | 'TRAFFIC_AND_PEDESTRIAN';
}

export interface IntersectionPhase {
  id: string;
  name: string;
  order: number;
  prio: number;
  greenPhaseSeconds: number;
  trafficLights: IntersectionPhaseTrafficLight[];
}

export default interface Intersection {
  id: number;
  name: string;
  timeForGreen: number;
  ready: boolean;
  currentSwitching: string;
  manualSwitching: string;
  nextSwitching: string;
  staticCams: string[];
  phases: IntersectionPhase[];
}
