import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DomainDataProvider } from '../../eep/server-data/dynamic/DomainDataProvider';
import DomainRoomService from '../../eep/server-data/dynamic/DomainRoomService';
import RoadSelector from './RoadSelector';
import {
  IntersectionRoom,
  IntersectionListRoom,
  IntersectionPhaseListRoom,
  RoadSettingsRoom,
  RoadTrafficLightModelsRoom,
} from '@ce/web-shared';
import { Server } from 'socket.io';

export default class RoadDataService implements DomainRoomService {
  private roomDataProviders: DomainDataProvider[] = [];
  private selector = new RoadSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: IntersectionListRoom,
      id: 'IntersectionListRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getIntersections()),
    });
    this.roomDataProviders.push({
      roomType: IntersectionRoom,
      id: 'IntersectionRoom',
      jsonCreator: (room: string) =>
        JSON.stringify(this.selector.getIntersection(IntersectionRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: IntersectionPhaseListRoom,
      id: 'IntersectionPhaseListRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getIntersectionPhases()),
    });
    this.roomDataProviders.push({
      roomType: RoadSettingsRoom,
      id: 'RoadSettingsRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getModuleSettings()),
    });
    this.roomDataProviders.push({
      roomType: RoadTrafficLightModelsRoom,
      id: 'RoadTrafficLightModelsRoom',
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
