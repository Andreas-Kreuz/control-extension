import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DomainDataProvider } from '../../eep/server-data/dynamic/DomainDataProvider';
import DomainRoomService from '../../eep/server-data/dynamic/DomainRoomService';
import VersionSelector from './VersionSelector';
import { VersionRoom } from '@ce/web-shared';
import { Server } from 'socket.io';

export default class VersionService implements DomainRoomService {
  private roomDataProviders: DomainDataProvider[] = [];
  private versionSelector = new VersionSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: VersionRoom,
      id: 'VersionRoom',
      jsonCreator: (_room: string): string => {
        return JSON.stringify(this.versionSelector.getVersions());
      },
    });
  }

  getUpdaters = () => [
    {
      updateFromState: (state: Readonly<fromEepData.State>) => {
        this.versionSelector.updateFromState(state);
      },
    },
  ];

  getDataProviders = () => this.roomDataProviders;
}
