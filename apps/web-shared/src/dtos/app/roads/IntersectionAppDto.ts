// App contract populated by:
// apps/web-server/src/server/mod/road/RoadSelector.ts
export interface IntersectionPhaseTrafficLightAppDto {
  signalId: number;
  signalKind?: 'TRAFFIC' | 'PEDESTRIAN';
  signalKey?: string;
  signalName?: string;
  type: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
  trafficSignalName?: string;
  pedestrianSignalName?: string;
  use: 'TRAFFIC_ONLY' | 'PEDESTRIAN_ONLY' | 'TRAFFIC_AND_PEDESTRIAN';
}

export interface IntersectionPhaseAppDto {
  id: string;
  name: string;
  order: number;
  prio: number;
  greenPhaseSeconds: number;
  trafficLights: IntersectionPhaseTrafficLightAppDto[];
}

export interface IntersectionAppDto {
  id: number;
  name: string;
  currentSwitching: string;
  manualSwitching: string;
  nextSwitching: string;
  ready: boolean;
  timeForGreen: number;
  staticCams: string[];
  phases: IntersectionPhaseAppDto[];
}
