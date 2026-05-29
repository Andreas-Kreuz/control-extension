import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DomainDataProvider } from '../../eep/server-data/dynamic/DomainDataProvider';
import DomainRoomService from '../../eep/server-data/dynamic/DomainRoomService';
import DataTransferSelector from './DataTransferSelector';
import EepDataSelector from './EepDataSelector';
import { DataTransferFieldsRoom, DataTransferSummaryRoom, RuntimeStatisticsRoom, ModuleRoom } from '@ce/web-shared';
import { Server } from 'socket.io';

export default class EepDataService implements DomainRoomService {
  private roomDataProviders: DomainDataProvider[] = [];
  private selector = new EepDataSelector();
  private dataTransferSelector = new DataTransferSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: DataTransferSummaryRoom,
      id: 'DataTransferSummary',
      jsonCreator: (_room: string) => JSON.stringify(this.dataTransferSelector.getSummary()),
    });
    this.roomDataProviders.push({
      roomType: DataTransferFieldsRoom,
      id: 'DataTransferFields',
      jsonCreator: (room: string) => {
        const ceType = DataTransferFieldsRoom.idOfRoom(room);
        return JSON.stringify(this.dataTransferSelector.getFields(ceType));
      },
    });
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
        this.dataTransferSelector.updateFromState(state);
      },
    },
  ];

  getDataProviders = () => this.roomDataProviders;
}
