import { OnInterestBinding } from './DomainDataProvider';
import {
  CeTypes,
  DomainRoom,
  IntersectionRoom,
  RollingStockRoom,
  TrainRoom,
  TransitLineDetailsRoom,
  TransitStationDetailsRoom,
  TransitTrainRoom,
} from '@ce/web-shared';

export interface DomainRoomInterestMapping {
  roomType: DomainRoom;
  onInterest: OnInterestBinding[];
}

function sameRoom(left: DomainRoom, right: DomainRoom): boolean {
  return left === right;
}

const appDomainRoomInterestMappings: DomainRoomInterestMapping[] = [
  {
    roomType: TrainRoom,
    onInterest: [
      {
        // App train details select Lua train data.
        ceType: CeTypes.HubTrain,
        idOfRoom: (roomName: string) => TrainRoom.idOfRoom(roomName),
      },
      {
        // App train details also select Lua transit train data.
        ceType: CeTypes.TransitTrain,
        idOfRoom: (roomName: string) => TrainRoom.idOfRoom(roomName),
      },
    ],
  },
  {
    roomType: RollingStockRoom,
    onInterest: [
      {
        // App rolling-stock details select Lua rolling-stock data.
        ceType: CeTypes.HubRollingStock,
        idOfRoom: (roomName: string) => RollingStockRoom.idOfRoom(roomName),
      },
    ],
  },
  {
    roomType: TransitLineDetailsRoom,
    onInterest: [
      {
        // App transit line details select Lua transit line data.
        ceType: CeTypes.TransitLine,
        idOfRoom: (roomName: string) => TransitLineDetailsRoom.idOfRoom(roomName),
      },
    ],
  },
  {
    roomType: TransitStationDetailsRoom,
    onInterest: [
      {
        // App station details select Lua transit station data.
        ceType: CeTypes.TransitStation,
        idOfRoom: (roomName: string) => TransitStationDetailsRoom.idOfRoom(roomName),
      },
    ],
  },
  {
    roomType: TransitTrainRoom,
    onInterest: [
      {
        // App transit train details select Lua transit train data.
        ceType: CeTypes.TransitTrain,
        idOfRoom: (roomName: string) => TransitTrainRoom.idOfRoom(roomName),
      },
    ],
  },
  {
    roomType: IntersectionRoom,
    onInterest: [
      {
        // App intersection details select Lua road intersection data.
        ceType: CeTypes.RoadIntersection,
        idOfRoom: (roomName: string) => IntersectionRoom.idOfRoom(roomName),
      },
    ],
  },
];

export default class DomainRoomInterestRegistry {
  constructor(private mappings: DomainRoomInterestMapping[] = appDomainRoomInterestMappings) {}

  bindingsFor(roomType: DomainRoom): OnInterestBinding[] {
    return this.mappings.find((mapping) => sameRoom(mapping.roomType, roomType))?.onInterest ?? [];
  }
}
