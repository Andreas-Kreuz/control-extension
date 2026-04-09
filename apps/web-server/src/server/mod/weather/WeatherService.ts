import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
import WeatherSelector from './WeatherSelector';
import { WeatherRoom } from '@ce/web-shared';
import { Server } from 'socket.io';

export default class WeatherService implements DynamicRoomService {
  private roomDataProviders: DynamicDataProvider[] = [];
  private weatherSelector = new WeatherSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: WeatherRoom,
      id: 'WeatherRoom',
      jsonCreator: (_room: string): string => JSON.stringify(this.weatherSelector.getWeather()),
    });
  }

  getUpdaters = () => [
    {
      updateFromState: (state: Readonly<fromEepData.State>) => {
        this.weatherSelector.updateFromState(state);
      },
    },
  ];

  getDataProviders = () => this.roomDataProviders;
}
