import { CeTypes } from '../CeTypes';
import DomainRoom from './DomainRoom';

const ApiDataRoom = new DomainRoom('API Data');
const ApiEntriesRoom = new DomainRoom(CeTypes.ServerApiEntries);
const ServerStatsRoom = new DomainRoom(CeTypes.ServerStats);
const RuntimeStatisticsRoom = new DomainRoom(CeTypes.ServerRuntimeStatistics);
const TrainListRoom = new DomainRoom('TrainList');
const TrainRoom = new DomainRoom(CeTypes.HubTrain);
const RollingStockRoom = new DomainRoom(CeTypes.HubRollingStock);
const TransitLineListRoom = new DomainRoom('Transit List of Lines');
const TransitLineDetailsRoom = new DomainRoom('Transit Details of Line');
const TransitLineNameRoom = new DomainRoom(CeTypes.TransitLineName);
const TransitStationListRoom = new DomainRoom('Transit List of Stations');
const TransitStationDetailsRoom = new DomainRoom('Transit Details of Station');
const TransitSettingsRoom = new DomainRoom('Transit Settings');
const TransitTrainRoom = new DomainRoom(CeTypes.TransitTrain);
const TransitModuleSettingRoom = new DomainRoom(CeTypes.TransitModuleSetting);

const VersionRoom = new DomainRoom(CeTypes.HubEepVersion);
const WeatherRoom = new DomainRoom(CeTypes.HubWeather);
const TimeRoom = new DomainRoom(CeTypes.HubTime);
const RuntimeRoom = new DomainRoom(CeTypes.HubRuntime);
const ModuleRoom = new DomainRoom(CeTypes.HubModule);
const SaveSlotRoom = new DomainRoom(CeTypes.HubSaveSlot);
const FreeSlotRoom = new DomainRoom(CeTypes.HubFreeSlot);
const SignalRoom = new DomainRoom(CeTypes.HubSignal);
const WaitingOnSignalRoom = new DomainRoom(CeTypes.HubWaitingOnSignal);
const SwitchRoom = new DomainRoom(CeTypes.HubSwitch);
const StructureRoom = new DomainRoom(CeTypes.HubStructure);
const ContactRoom = new DomainRoom(CeTypes.HubContact);
const ScenarioRoom = new DomainRoom(CeTypes.HubScenario);
const RollingStockTexturesRoom = new DomainRoom('ce.hub.RollingStockTextures');
const RollingStockRotationRoom = new DomainRoom('ce.hub.RollingStockRotation');
const TrackRoom = new DomainRoom('Track');
const AuxiliaryTrackRoom = new DomainRoom(CeTypes.HubAuxiliaryTrack);
const ControlTrackRoom = new DomainRoom(CeTypes.HubControlTrack);
const RoadTrackRoom = new DomainRoom(CeTypes.HubRoadTrack);
const RailTrackRoom = new DomainRoom(CeTypes.HubRailTrack);
const TramTrackRoom = new DomainRoom(CeTypes.HubTramTrack);
const IntersectionRoom = new DomainRoom(CeTypes.RoadIntersection);
const IntersectionLaneRoom = new DomainRoom(CeTypes.RoadIntersectionLane);
const IntersectionSwitchingRoom = new DomainRoom(CeTypes.RoadIntersectionSwitching);
const IntersectionTrafficLightRoom = new DomainRoom(CeTypes.RoadIntersectionTrafficLight);
const TrafficLightModelRoom = new DomainRoom(CeTypes.RoadSignalTypeDefinition);
const RoadModuleSettingRoom = new DomainRoom(CeTypes.RoadModuleSetting);
const DetailRoomByCeType: Partial<Record<string, DomainRoom>> = {
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

function detailRoomForCeType(ceType: string): DomainRoom | undefined {
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
