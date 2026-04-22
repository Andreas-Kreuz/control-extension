import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DomainDataProvider } from '../../eep/server-data/dynamic/DomainDataProvider';
import DomainRoomService from '../../eep/server-data/dynamic/DomainRoomService';
import EepDataSelector from './EepDataSelector';
import { RuntimeStatisticsRoom, ModuleRoom } from '@ce/web-shared';
import { Server } from 'socket.io';

export default class EepDataService implements DomainRoomService {
  private roomDataProviders: DomainDataProvider[] = [];
  private selector = new EepDataSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: RuntimeStatisticsRoom,
      id: 'RuntimeStatisticsRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getRuntimeStatistics()),
    });
    this.roomDataProviders.push({
      roomType: ModuleRoom,
      id: 'ModuleRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getModules()),
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
