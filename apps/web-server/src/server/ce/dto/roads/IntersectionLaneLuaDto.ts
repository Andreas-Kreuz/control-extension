// Lua DtoFactory: lua/LUA/ce/mods/road/data/RoadDtoFactory.lua
// Room: intersection-lanes
export type IntersectionLaneRouteRuleModeLuaDto = 'ONLY' | 'ALSO';

export interface IntersectionLaneRouteRuleLuaDto {
  routeNames: string[];
  signalGroups: string[];
  mode: IntersectionLaneRouteRuleModeLuaDto;
  showRequests: boolean;
}

export interface IntersectionLaneLuaDto {
  id: string;
  intersectionId: number;
  name: string;
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
  defaultSignalGroups?: string[];
  routeRules?: IntersectionLaneRouteRuleLuaDto[];
  tracks: number[];
}
