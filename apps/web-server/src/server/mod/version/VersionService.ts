import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
import VersionSelector from './VersionSelector';
import { VersionRoom } from '@ce/web-shared';
import { Server } from 'socket.io';

export default class VersionService implements DynamicRoomService {
  private roomDataProviders: DynamicDataProvider[] = [];
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
