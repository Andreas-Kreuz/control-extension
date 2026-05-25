// App contract populated by:
// apps/web-server/src/server/mod/road/RoadSelector.ts
export type IntersectionLaneRouteRuleModeAppDto = 'ONLY' | 'ALSO';

export interface IntersectionLaneRouteRuleAppDto {
  routeNames: string[];
  signalGroups: string[];
  mode: IntersectionLaneRouteRuleModeAppDto;
  showRequests: boolean;
}

export interface IntersectionLaneAppDto {
  id: string;
  intersectionId: number;
  name: string;
  kpId?: string;
  scriptVariableName?: string;
  currentIndication: string;
  vehicleMultiplier: number;
  laneSignalId?: number;
  type: string;
  countType: string;
  waitingTrains: string[];
  waitingForGreenCyclesCount: number;
  approach?: string;
  heading?: string;
  directions: string[];
  phases: string[];
  defaultSignalGroups: string[];
  routeRules?: IntersectionLaneRouteRuleAppDto[];
  defaultRequestSignalGroups?: string[];
  requestTrackIds?: number[];
  highlightTrackIds?: number[];
  tracks: number[];
}
