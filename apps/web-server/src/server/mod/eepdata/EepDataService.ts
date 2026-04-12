import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DomainDataProvider } from '../../eep/server-data/dynamic/DomainDataProvider';
import DomainRoomService from '../../eep/server-data/dynamic/DomainRoomService';
import EepDataSelector from './EepDataSelector';
import {
  AuxiliaryTrackRoom,
  CeTypes,
  ContactRoom,
  ControlTrackRoom,
  RuntimeRoom,
  RuntimeStatisticsRoom,
  ModuleRoom,
  RailTrackRoom,
  RoadTrackRoom,
  SaveSlotRoom,
  FreeSlotRoom,
  SignalRoom,
  WaitingOnSignalRoom,
  SwitchRoom,
  StructureRoom,
  TrackRoom,
  TramTrackRoom,
} from '@ce/web-shared';
import { Server } from 'socket.io';

export default class EepDataService implements DomainRoomService {
  private roomDataProviders: DomainDataProvider[] = [];
  private selector = new EepDataSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: RuntimeRoom,
      id: 'RuntimeRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getRuntime()),
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
      onInterest: { ceType: CeTypes.HubSignal, idOfRoom: (room: string) => SignalRoom.idOfRoom(room) },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getSignal(SignalRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: WaitingOnSignalRoom,
      id: 'WaitingOnSignalRoom',
      jsonCreator: (_room: string) => JSON.stringify(this.selector.getWaitingOnSignals()),
    });
    this.roomDataProviders.push({
      roomType: SwitchRoom,
      id: 'SwitchRoom',
      onInterest: { ceType: CeTypes.HubSwitch, idOfRoom: (room: string) => SwitchRoom.idOfRoom(room) },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getSwitch(SwitchRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: StructureRoom,
      id: 'StructureRoom',
      onInterest: { ceType: CeTypes.HubStructure, idOfRoom: (room: string) => StructureRoom.idOfRoom(room) },
      jsonCreator: (room: string) => {
        const structureId = StructureRoom.idOfRoom(room);
        return JSON.stringify(this.selector.getStructure(structureId) ?? null);
      },
    });
    this.roomDataProviders.push({
      roomType: ContactRoom,
      id: 'ContactRoom',
      onInterest: { ceType: CeTypes.HubContact, idOfRoom: (room: string) => ContactRoom.idOfRoom(room) },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getContact(ContactRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: TrackRoom,
      id: 'TrackRoom',
      jsonCreator: (room: string) => {
        const roomName = TrackRoom.idOfRoom(room);
        return JSON.stringify(this.selector.getTracksForRoom(roomName));
      },
    });
    this.roomDataProviders.push({
      roomType: AuxiliaryTrackRoom,
      id: 'AuxiliaryTrackRoom',
      onInterest: {
        ceType: CeTypes.HubAuxiliaryTrack,
        idOfRoom: (room: string) => AuxiliaryTrackRoom.idOfRoom(room),
      },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getTrack('auxiliary', AuxiliaryTrackRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: ControlTrackRoom,
      id: 'ControlTrackRoom',
      onInterest: { ceType: CeTypes.HubControlTrack, idOfRoom: (room: string) => ControlTrackRoom.idOfRoom(room) },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getTrack('control', ControlTrackRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: RoadTrackRoom,
      id: 'RoadTrackRoom',
      onInterest: { ceType: CeTypes.HubRoadTrack, idOfRoom: (room: string) => RoadTrackRoom.idOfRoom(room) },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getTrack('road', RoadTrackRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: RailTrackRoom,
      id: 'RailTrackRoom',
      onInterest: { ceType: CeTypes.HubRailTrack, idOfRoom: (room: string) => RailTrackRoom.idOfRoom(room) },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getTrack('rail', RailTrackRoom.idOfRoom(room)) ?? null),
    });
    this.roomDataProviders.push({
      roomType: TramTrackRoom,
      id: 'TramTrackRoom',
      onInterest: { ceType: CeTypes.HubTramTrack, idOfRoom: (room: string) => TramTrackRoom.idOfRoom(room) },
      jsonCreator: (room: string) => JSON.stringify(this.selector.getTrack('tram', TramTrackRoom.idOfRoom(room)) ?? null),
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
