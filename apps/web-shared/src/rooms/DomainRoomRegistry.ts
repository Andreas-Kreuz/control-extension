import DomainRoom from './DomainRoom';

const ApiDataRoom = new DomainRoom('API Data');
const ServerStatsRoom = new DomainRoom('App.ServerStats');
const RuntimeStatisticsRoom = new DomainRoom('App.RuntimeStatistics');
const ModuleRoom = new DomainRoom('App.Modules');
const VersionRoom = new DomainRoom('App.Version');
const ScenarioRoom = new DomainRoom('App.Scenario');

const TrainListRoom = new DomainRoom('App.TrainList');
const TrainRoom = new DomainRoom('App.Train');
const RollingStockRoom = new DomainRoom('App.RollingStock');

const TransitLineListRoom = new DomainRoom('App.TransitLineList');
const TransitLineDetailsRoom = new DomainRoom('App.TransitLine');
const TransitStationListRoom = new DomainRoom('App.TransitStationList');
const TransitStationDetailsRoom = new DomainRoom('App.TransitStation');
const TransitSettingsRoom = new DomainRoom('App.TransitSettings');
const TransitTrainRoom = new DomainRoom('App.TransitTrain');

const IntersectionListRoom = new DomainRoom('App.IntersectionList');
const IntersectionRoom = new DomainRoom('App.Intersection');
const IntersectionSwitchingListRoom = new DomainRoom('App.IntersectionSwitchingList');
const RoadSettingsRoom = new DomainRoom('App.RoadSettings');
export { ApiDataRoom };
export { ServerStatsRoom };
export { RuntimeStatisticsRoom };
export { ModuleRoom };
export { VersionRoom };
export { ScenarioRoom };
export { TrainListRoom };
export { TrainRoom };
export { RollingStockRoom };
export { TransitLineListRoom };
export { TransitLineDetailsRoom };
export { TransitStationListRoom };
export { TransitStationDetailsRoom };
export { TransitSettingsRoom };
export { TransitTrainRoom };
export { IntersectionListRoom };
export { IntersectionRoom };
export { IntersectionSwitchingListRoom };
export { RoadSettingsRoom };
