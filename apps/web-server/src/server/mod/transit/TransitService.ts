import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DomainDataProvider } from '../../eep/server-data/dynamic/DomainDataProvider';
import DomainRoomService from '../../eep/server-data/dynamic/DomainRoomService';
import TransitSettingsSelector from './TransitSettingsSelector';
import TransitSelector from './TransitSelector';
import {
  TransitLineListRoom,
  TransitLineDetailsRoom,
  TransitStationListRoom,
  TransitStationDetailsRoom,
  TransitSettingsRoom,
  TransitTrainRoom,
} from '@ce/web-shared';
import { Server } from 'socket.io';

export default class TransitService implements DomainRoomService {
  private roomDataProviders: DomainDataProvider[] = [];
  private publicTransportSettingsSelector = new TransitSettingsSelector();
  private transitSelector = new TransitSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: TransitSettingsRoom,
      id: 'TransitSettingsRoom',
      jsonCreator: (_room: string): string => {
        return JSON.stringify(this.publicTransportSettingsSelector.getSettings());
      },
    });
    this.roomDataProviders.push({
      roomType: TransitLineListRoom,
      id: 'TransitLineListRoom',
      jsonCreator: (_room: string): string => {
        return JSON.stringify(Object.values(this.transitSelector.getTransitLines()));
      },
    });
    this.roomDataProviders.push({
      roomType: TransitLineDetailsRoom,
      id: 'TransitLineDetailsRoom',
      jsonCreator: (room: string): string => {
        const lineId = TransitLineDetailsRoom.idOfRoom(room);
        return JSON.stringify(this.transitSelector.getTransitLine(lineId) ?? null);
      },
    });
    this.roomDataProviders.push({
      roomType: TransitStationListRoom,
      id: 'TransitStationListRoom',
      jsonCreator: (_room: string): string => {
        return JSON.stringify(Object.values(this.transitSelector.getTransitStations()));
      },
    });
    this.roomDataProviders.push({
      roomType: TransitStationDetailsRoom,
      id: 'TransitStationDetailsRoom',
      jsonCreator: (room: string): string => {
        const stationId = TransitStationDetailsRoom.idOfRoom(room);
        return JSON.stringify(this.transitSelector.getTransitStation(stationId) ?? null);
      },
    });
    this.roomDataProviders.push({
      roomType: TransitTrainRoom,
      id: 'TransitTrainRoom',
      jsonCreator: (room: string): string =>
        JSON.stringify(this.transitSelector.getTransitTrain(TransitTrainRoom.idOfRoom(room)) ?? null),
    });
  }

  getUpdaters = () => [
    {
      updateFromState: (state: Readonly<fromEepData.State>) => {
        this.publicTransportSettingsSelector.updateFromState(state);
        this.transitSelector.updateFromState(state);
      },
    },
  ];

  getDataProviders = () => this.roomDataProviders;
}
