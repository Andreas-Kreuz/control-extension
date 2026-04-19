export interface IntersectionPhaseTrafficLight {
  signalId: number;
  type: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
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
