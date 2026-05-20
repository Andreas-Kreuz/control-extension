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
  signalGroups: string[];
  signalHeads: IntersectionPhaseSignalHeadAppDto[];
}

export interface IntersectionSignalGroupAppDto {
  name: string;
  scriptVariableName?: string;
  approach?: string;
  turnDirections?: string[];
  trafficType: 'BUS' | 'CAR' | 'TRAM' | 'PEDESTRIAN' | 'BICYCLE';
  signalIds: number[];
  pedestrianCrossingNames?: string[];
}

export interface IntersectionPedestrianCrossingAppDto {
  name: string;
  scriptVariableName?: string;
  approach?: string;
  heading?: string;
  signalGroups: string[];
}

export interface IntersectionAppDto {
  id: number;
  name: string;
  eepSaveId?: number;
  scriptVariableName?: string;
  switchInStrictOrder?: boolean;
  currentPhase: string;
  manualPhase: string;
  nextPhase: string;
  ready: boolean;
  greenTimeSeconds: number;
  tippStructure?: string;
  staticCams: string[];
  phases: IntersectionPhaseTimingAppDto[];
  signalGroupDefinitions: IntersectionSignalGroupAppDto[];
  pedestrianCrossings?: IntersectionPedestrianCrossingAppDto[];
}
