import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
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

export default class RoadDataService implements DynamicRoomService {
  private roomDataProviders: DynamicDataProvider[] = [];
  private selector = new RoadSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: IntersectionRoom,
      id: 'IntersectionRoom',
      dynamicInterest: { ceType: CeTypes.RoadIntersection, idOfRoom: (room: string) => IntersectionRoom.idOfRoom(room) },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getIntersection(IntersectionRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: IntersectionLaneRoom,
      id: 'IntersectionLaneRoom',
      dynamicInterest: {
        ceType: CeTypes.RoadIntersectionLane,
        idOfRoom: (room: string) => IntersectionLaneRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getIntersectionLane(IntersectionLaneRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: IntersectionSwitchingRoom,
      id: 'IntersectionSwitchingRoom',
      dynamicInterest: {
        ceType: CeTypes.RoadIntersectionSwitching,
        idOfRoom: (room: string) => IntersectionSwitchingRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) =>
        JSON.stringify(this.selector.getIntersectionSwitching(IntersectionSwitchingRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: IntersectionTrafficLightRoom,
      id: 'IntersectionTrafficLightRoom',
      dynamicInterest: {
        ceType: CeTypes.RoadIntersectionTrafficLight,
        idOfRoom: (room: string) => IntersectionTrafficLightRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) =>
        JSON.stringify(this.selector.getIntersectionTrafficLight(IntersectionTrafficLightRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: TrafficLightModelRoom,
      id: 'TrafficLightModelRoom',
      dynamicInterest: {
        ceType: CeTypes.RoadSignalTypeDefinition,
        idOfRoom: (room: string) => TrafficLightModelRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getTrafficLightModel(TrafficLightModelRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: RoadModuleSettingRoom,
      id: 'RoadModuleSettingRoom',
      dynamicInterest: {
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
