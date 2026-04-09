import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
import TimeSelector from './TimeSelector';
import { TimeRoom } from '@ce/web-shared';
import { Server } from 'socket.io';

export default class TimeService implements DynamicRoomService {
  private roomDataProviders: DynamicDataProvider[] = [];
  private timeSelector = new TimeSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: TimeRoom,
      id: 'TimeRoom',
      jsonCreator: (_room: string): string => {
        return JSON.stringify(this.timeSelector.getTimes());
      },
    });
  }

  getUpdaters = () => [
    {
      updateFromState: (state: Readonly<fromEepData.State>) => {
        this.timeSelector.updateFromState(state);
      },
    },
  ];

  getDataProviders = () => this.roomDataProviders;
}
