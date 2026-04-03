import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
import TransitSettingsSelector from './TransitSettingsSelector';
import TransitSelector from './TransitSelector';
import {
  TransitLineListRoom,
  TransitLineDetailsRoom,
  TransitStationListRoom,
  TransitStationDetailsRoom,
  TransitSettingsRoom,
} from '@ce/web-shared';
import { Server } from 'socket.io';

export default class TransitService implements DynamicRoomService {
  private roomDataProviders: DynamicDataProvider[] = [];
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
        return JSON.stringify(this.transitSelector.getTransitLines()[lineId] ?? null);
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
        return JSON.stringify(this.transitSelector.getTransitStations()[stationId] ?? null);
      },
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

