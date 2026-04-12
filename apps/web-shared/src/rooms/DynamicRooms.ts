import { CeTypes } from '../CeTypes';
import DynamicRoom from './DynamicRoom';

const ApiDataRoom = new DynamicRoom('API Data');
const ApiEntriesRoom = new DynamicRoom(CeTypes.ServerApiEntries);
const ServerStatsRoom = new DynamicRoom(CeTypes.ServerStats);
const RuntimeStatisticsRoom = new DynamicRoom(CeTypes.ServerRuntimeStatistics);
const TrainListRoom = new DynamicRoom('TrainList');
const TrainRoom = new DynamicRoom(CeTypes.HubTrain);
const RollingStockRoom = new DynamicRoom(CeTypes.HubRollingStock);
const TransitLineListRoom = new DynamicRoom('Transit List of Lines');
const TransitLineDetailsRoom = new DynamicRoom('Transit Details of Line');
const TransitLineNameRoom = new DynamicRoom(CeTypes.TransitLineName);
const TransitStationListRoom = new DynamicRoom('Transit List of Stations');
const TransitStationDetailsRoom = new DynamicRoom('Transit Details of Station');
const TransitSettingsRoom = new DynamicRoom('Transit Settings');
const TransitTrainRoom = new DynamicRoom(CeTypes.TransitTrain);
const TransitModuleSettingRoom = new DynamicRoom(CeTypes.TransitModuleSetting);

const VersionRoom = new DynamicRoom(CeTypes.HubEepVersion);
const WeatherRoom = new DynamicRoom(CeTypes.HubWeather);
const TimeRoom = new DynamicRoom(CeTypes.HubTime);
const RuntimeRoom = new DynamicRoom(CeTypes.HubRuntime);
const ModuleRoom = new DynamicRoom(CeTypes.HubModule);
const SaveSlotRoom = new DynamicRoom(CeTypes.HubSaveSlot);
const FreeSlotRoom = new DynamicRoom(CeTypes.HubFreeSlot);
const SignalRoom = new DynamicRoom(CeTypes.HubSignal);
const WaitingOnSignalRoom = new DynamicRoom(CeTypes.HubWaitingOnSignal);
const SwitchRoom = new DynamicRoom(CeTypes.HubSwitch);
const StructureRoom = new DynamicRoom(CeTypes.HubStructure);
const ContactRoom = new DynamicRoom(CeTypes.HubContact);
const ScenarioRoom = new DynamicRoom(CeTypes.HubScenario);
const RollingStockTexturesRoom = new DynamicRoom('ce.hub.RollingStockTextures');
const RollingStockRotationRoom = new DynamicRoom('ce.hub.RollingStockRotation');
const TrackRoom = new DynamicRoom('Track');
const AuxiliaryTrackRoom = new DynamicRoom(CeTypes.HubAuxiliaryTrack);
const ControlTrackRoom = new DynamicRoom(CeTypes.HubControlTrack);
const RoadTrackRoom = new DynamicRoom(CeTypes.HubRoadTrack);
const RailTrackRoom = new DynamicRoom(CeTypes.HubRailTrack);
const TramTrackRoom = new DynamicRoom(CeTypes.HubTramTrack);
const IntersectionRoom = new DynamicRoom(CeTypes.RoadIntersection);
const IntersectionLaneRoom = new DynamicRoom(CeTypes.RoadIntersectionLane);
const IntersectionSwitchingRoom = new DynamicRoom(CeTypes.RoadIntersectionSwitching);
const IntersectionTrafficLightRoom = new DynamicRoom(CeTypes.RoadIntersectionTrafficLight);
const TrafficLightModelRoom = new DynamicRoom(CeTypes.RoadSignalTypeDefinition);
const RoadModuleSettingRoom = new DynamicRoom(CeTypes.RoadModuleSetting);
const DetailRoomByCeType: Partial<Record<string, DynamicRoom>> = {
  [CeTypes.HubTrain]: TrainRoom,
  [CeTypes.HubRollingStock]: RollingStockRoom,
  [CeTypes.HubSignal]: SignalRoom,
  [CeTypes.HubSwitch]: SwitchRoom,
  [CeTypes.HubStructure]: StructureRoom,
  [CeTypes.HubContact]: ContactRoom,
  [CeTypes.HubAuxiliaryTrack]: AuxiliaryTrackRoom,
  [CeTypes.HubControlTrack]: ControlTrackRoom,
  [CeTypes.HubRoadTrack]: RoadTrackRoom,
  [CeTypes.HubRailTrack]: RailTrackRoom,
  [CeTypes.HubTramTrack]: TramTrackRoom,
  [CeTypes.RoadIntersection]: IntersectionRoom,
  [CeTypes.RoadIntersectionLane]: IntersectionLaneRoom,
  [CeTypes.RoadIntersectionSwitching]: IntersectionSwitchingRoom,
  [CeTypes.RoadIntersectionTrafficLight]: IntersectionTrafficLightRoom,
  [CeTypes.RoadSignalTypeDefinition]: TrafficLightModelRoom,
  [CeTypes.RoadModuleSetting]: RoadModuleSettingRoom,
  [CeTypes.TransitLine]: TransitLineDetailsRoom,
  [CeTypes.TransitLineName]: TransitLineNameRoom,
  [CeTypes.TransitStation]: TransitStationDetailsRoom,
  [CeTypes.TransitTrain]: TransitTrainRoom,
  [CeTypes.TransitModuleSetting]: TransitModuleSettingRoom,
};

function detailRoomForCeType(ceType: string): DynamicRoom | undefined {
  return DetailRoomByCeType[ceType];
}

export { ApiDataRoom };
export { ApiEntriesRoom };
export { ServerStatsRoom };
export { RuntimeStatisticsRoom };
export { TrainListRoom };
export { TrainRoom };
export { TransitLineListRoom };
export { TransitLineDetailsRoom };
export { TransitLineNameRoom };
export { TransitStationListRoom };
export { TransitStationDetailsRoom };
export { TransitSettingsRoom };
export { TransitTrainRoom };
export { TransitModuleSettingRoom };
export { VersionRoom };
export { WeatherRoom };
export { TimeRoom };
export { RuntimeRoom };
export { ModuleRoom };
export { SaveSlotRoom };
export { FreeSlotRoom };
export { SignalRoom };
export { WaitingOnSignalRoom };
export { SwitchRoom };
export { StructureRoom };
export { ContactRoom };
export { ScenarioRoom };
export { RollingStockRoom };
export { RollingStockTexturesRoom };
export { RollingStockRotationRoom };
export { TrackRoom };
export { AuxiliaryTrackRoom };
export { ControlTrackRoom };
export { RoadTrackRoom };
export { RailTrackRoom };
export { TramTrackRoom };
export { IntersectionRoom };
export { IntersectionLaneRoom };
export { IntersectionSwitchingRoom };
export { IntersectionTrafficLightRoom };
export { TrafficLightModelRoom };
export { RoadModuleSettingRoom };
export { detailRoomForCeType };
