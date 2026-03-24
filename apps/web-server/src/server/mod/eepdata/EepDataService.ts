import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
import EepDataSelector from './EepDataSelector';
import {
  RuntimeRoom,
  ModuleRoom,
  SaveSlotRoom,
  FreeSlotRoom,
  SignalRoom,
  WaitingOnSignalRoom,
  SwitchRoom,
  StructureRoom,
  TrackRoom,
} from '@ak/web-shared';
import { Server } from 'socket.io';

export default class EepDataService implements DynamicRoomService {
  private roomDataProviders: DynamicDataProvider[] = [];
  private selector = new EepDataSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: RuntimeRoom,
      id: 'RuntimeRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getRuntime()),
    });
    this.roomDataProviders.push({
      roomType: ModuleRoom,
      id: 'ModuleRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getModules()),
    });
    this.roomDataProviders.push({
      roomType: SaveSlotRoom,
      id: 'SaveSlotRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getSaveSlots()),
    });
    this.roomDataProviders.push({
      roomType: FreeSlotRoom,
      id: 'FreeSlotRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getFreeSlots()),
    });
    this.roomDataProviders.push({
      roomType: SignalRoom,
      id: 'SignalRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getSignals()),
    });
    this.roomDataProviders.push({
      roomType: WaitingOnSignalRoom,
      id: 'WaitingOnSignalRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getWaitingOnSignals()),
    });
    this.roomDataProviders.push({
      roomType: SwitchRoom,
      id: 'SwitchRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getSwitches()),
    });
    this.roomDataProviders.push({
      roomType: StructureRoom,
      id: 'StructureRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getStructures()),
    });
    this.roomDataProviders.push({
      roomType: TrackRoom,
      id: 'TrackRoom',
      jsonCreator: (room: string) => {
        const roomName = TrackRoom.idOfRoom(room);
        return JSON.stringify(this.selector.getTracksForRoom(roomName));
      },
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
