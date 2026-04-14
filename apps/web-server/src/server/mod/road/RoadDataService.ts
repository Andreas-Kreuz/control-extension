import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DomainDataProvider } from '../../eep/server-data/dynamic/DomainDataProvider';
import DomainRoomService from '../../eep/server-data/dynamic/DomainRoomService';
import RoadSelector from './RoadSelector';
import {
  CeTypes,
  IntersectionRoom,
  IntersectionLaneRoom,
  IntersectionSwitchingRoom,
  IntersectionTrafficLightRoom,
  RoadModuleSettingRoom,
  TrafficLightModelRoom,
} from '@ce/web-shared';
import { Server } from 'socket.io';

export default class RoadDataService implements DomainRoomService {
  private roomDataProviders: DomainDataProvider[] = [];
  private selector = new RoadSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: IntersectionRoom,
      id: 'IntersectionRoom',
      onInterest: { ceType: CeTypes.RoadIntersection, idOfRoom: (room: string) => IntersectionRoom.idOfRoom(room) },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getIntersection(IntersectionRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: IntersectionLaneRoom,
      id: 'IntersectionLaneRoom',
      onInterest: {
        ceType: CeTypes.RoadIntersectionLane,
        idOfRoom: (room: string) => IntersectionLaneRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getIntersectionLane(IntersectionLaneRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: IntersectionSwitchingRoom,
      id: 'IntersectionSwitchingRoom',
      onInterest: {
        ceType: CeTypes.RoadIntersectionSwitching,
        idOfRoom: (room: string) => IntersectionSwitchingRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) =>
        JSON.stringify(this.selector.getIntersectionSwitching(IntersectionSwitchingRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: IntersectionTrafficLightRoom,
      id: 'IntersectionTrafficLightRoom',
      onInterest: {
        ceType: CeTypes.RoadIntersectionTrafficLight,
        idOfRoom: (room: string) => IntersectionTrafficLightRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) =>
        JSON.stringify(this.selector.getIntersectionTrafficLight(IntersectionTrafficLightRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: TrafficLightModelRoom,
      id: 'TrafficLightModelRoom',
      onInterest: {
        ceType: CeTypes.RoadSignalTypeDefinition,
        idOfRoom: (room: string) => TrafficLightModelRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getTrafficLightModel(TrafficLightModelRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: RoadModuleSettingRoom,
      id: 'RoadModuleSettingRoom',
      onInterest: {
        ceType: CeTypes.RoadModuleSetting,
        idOfRoom: (room: string) => RoadModuleSettingRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getModuleSetting(RoadModuleSettingRoom.idOfRoom(room)) ?? null),
    });
  }

  getUpdaters = () => [
    {
      updateFromState: (state: Readonly<fromEepData.State>) => {
        this.selector.updateFromState(state);
      },
    },
  ];

  getDataProviders = () => this.roomDataProviders;
}
