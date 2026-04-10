import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
import RoadSelector from './RoadSelector';
import {
  IntersectionRoom,
  IntersectionLaneRoom,
  IntersectionSwitchingRoom,
  IntersectionTrafficLightRoom,
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
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getIntersections()),
    });
    this.roomDataProviders.push({
      roomType: IntersectionLaneRoom,
      id: 'IntersectionLaneRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getIntersectionLanes()),
    });
    this.roomDataProviders.push({
      roomType: IntersectionSwitchingRoom,
      id: 'IntersectionSwitchingRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getIntersectionSwitchings()),
    });
    this.roomDataProviders.push({
      roomType: IntersectionTrafficLightRoom,
      id: 'IntersectionTrafficLightRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getIntersectionTrafficLights()),
    });
    this.roomDataProviders.push({
      roomType: TrafficLightModelRoom,
      id: 'TrafficLightModelRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getTrafficLightModels()),
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
