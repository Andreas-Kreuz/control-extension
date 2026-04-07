import { TrackType } from './model/trains/TrackType';

export const CeTypes = {
  ServerApiEntries: 'ce.server.ApiEntries',
  ServerStats: 'ce.server.ServerStats',
  ServerRuntimeStatistics: 'ce.server.RuntimeStatistics',
  HubModule: 'ce.hub.Module',
  HubRuntime: 'ce.hub.Runtime',
  HubFrameData: 'ce.hub.FrameData',
  HubEepVersion: 'ce.hub.EepVersion',
  HubWeather: 'ce.hub.Weather',
  HubSaveSlot: 'ce.hub.SaveSlot',
  HubFreeSlot: 'ce.hub.FreeSlot',
  HubSignal: 'ce.hub.Signal',
  HubWaitingOnSignal: 'ce.hub.WaitingOnSignal',
  HubSwitch: 'ce.hub.Switch',
  HubStructure: 'ce.hub.Structure',
  HubTime: 'ce.hub.Time',
  HubTrain: 'ce.hub.Train',
  HubRollingStock: 'ce.hub.RollingStock',
  HubAuxiliaryTrack: 'ce.hub.AuxiliaryTrack',
  HubControlTrack: 'ce.hub.ControlTrack',
  HubRoadTrack: 'ce.hub.RoadTrack',
  HubRailTrack: 'ce.hub.RailTrack',
  HubTramTrack: 'ce.hub.TramTrack',
  RoadIntersection: 'ce.mods.road.Intersection',
  RoadIntersectionLane: 'ce.mods.road.IntersectionLane',
  RoadIntersectionSwitching: 'ce.mods.road.IntersectionSwitching',
  RoadIntersectionTrafficLight: 'ce.mods.road.IntersectionTrafficLight',
  RoadModuleSetting: 'ce.mods.road.ModuleSetting',
  RoadSignalTypeDefinition: 'ce.mods.road.SignalTypeDefinition',
  TransitStation: 'ce.mods.transit.Station',
  TransitLine: 'ce.mods.transit.Line',
  TransitModuleSetting: 'ce.mods.transit.ModuleSetting',
  TransitLineName: 'ce.mods.transit.LineName',
} as const;

export type CeType = (typeof CeTypes)[keyof typeof CeTypes];

const trackTypeToCeType: Record<TrackType, CeType> = {
  [TrackType.Auxiliary]: CeTypes.HubAuxiliaryTrack,
  [TrackType.Control]: CeTypes.HubControlTrack,
  [TrackType.Road]: CeTypes.HubRoadTrack,
  [TrackType.Rail]: CeTypes.HubRailTrack,
  [TrackType.Tram]: CeTypes.HubTramTrack,
};

const ceTypeToTrackType: Partial<Record<CeType, TrackType>> = {
  [CeTypes.HubAuxiliaryTrack]: TrackType.Auxiliary,
  [CeTypes.HubControlTrack]: TrackType.Control,
  [CeTypes.HubRoadTrack]: TrackType.Road,
  [CeTypes.HubRailTrack]: TrackType.Rail,
  [CeTypes.HubTramTrack]: TrackType.Tram,
};

export function ceTypeForTrackType(trackType: TrackType | string): CeType {
  const ceType = trackTypeToCeType[trackType as TrackType];
  if (!ceType) {
    throw new Error('No ceType registered for trackType: ' + trackType);
  }
  return ceType;
}

export function trackTypeForCeType(ceType: string): TrackType | undefined {
  return ceTypeToTrackType[ceType as CeType];
}
