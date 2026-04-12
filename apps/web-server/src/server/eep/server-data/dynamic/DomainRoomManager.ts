import EepDataStore from '../EepDataStore';
import { DomainDataProvider } from './DomainDataProvider';
import DynamicInterestService from './DynamicInterestService';
import { StateDataUpdater } from './StateDataUpdater';
import DomainRoomService from './DomainRoomService';
import { DomainRoom } from '@ce/web-shared';
import { Server, Socket } from 'socket.io';

export default class DomainRoomManager {
  private debug = false;
  private updatePending = false;
  private dataUpdaters: StateDataUpdater[] = [];
  private roomServices: DomainRoomService[] = [];
  private roomMap: Map<
    DomainRoom,
      {
        id: string;
        jsonCreator: (roomName: string) => string;
        dynamicInterest?: DomainDataProvider['dynamicInterest'];
        lastDataCache: Map<string, string>;
        currentData: Map<string, string>;
        sockets: Map<Socket, string>;
      }
  > = new Map();

  constructor(
    private io: Server,
    private dynamicInterestService?: DynamicInterestService,
  ) {}

  registerService(domainRoomService: DomainRoomService) {
    this.roomServices.push(domainRoomService);
    domainRoomService.getUpdaters().forEach((element: StateDataUpdater) => {
      this.dataUpdaters.push(element);
    });

    domainRoomService.getDataProviders().forEach((provider: DomainDataProvider) => {
      this.roomMap.set(provider.roomType, {
        id: provider.id,
        jsonCreator: provider.jsonCreator,
        dynamicInterest: provider.dynamicInterest,
        lastDataCache: new Map(),
        currentData: new Map(),
        sockets: new Map(),
      });
    });
  }

  onStateChange(store: Readonly<EepDataStore>): void {
    if (this.updatePending) {
      console.log('Skipping pending Update');
    } else {
      this.updatePending = true;

      this.dataUpdaters.forEach((updater) => {
        updater.updateFromState(store.currentState());
      });

      this.roomMap.forEach((domainRoomSetting, domainRoom) => {
        const lastDataCache = domainRoomSetting.lastDataCache;
        const roomSockets = domainRoomSetting.sockets;
        const jsonCreator = domainRoomSetting.jsonCreator;
        const currentData: Map<string, string> = new Map();
        const modifiedRooms: Map<string, boolean> = new Map();

        if (this.debug) console.log('ID', domainRoomSetting.id, roomSockets.size);

        // Which rooms need an update
        const roomNames: Map<string, boolean> = new Map();
        roomSockets.forEach((nameOfRoom) => roomNames.set(nameOfRoom, true));

        // Calculate the new data
        roomNames.forEach((_, nameOfRoom) => {
          const oldJson = lastDataCache.get(nameOfRoom);
          const newJson = jsonCreator(nameOfRoom);
          currentData.set(nameOfRoom, newJson);
          modifiedRooms.set(nameOfRoom, oldJson !== newJson);
        });

        modifiedRooms.forEach((modified, nameOfRoom) => {
          if (modified === true) {
            const eventName = domainRoom.eventId(domainRoom.idOfRoom(nameOfRoom));
            this.io.to(nameOfRoom).emit(eventName, currentData.get(nameOfRoom));
            if (this.debug) console.log('Sending Data to ', nameOfRoom, currentData.get(nameOfRoom));
          } else {
            if (this.debug) console.log('Skipping data event to ', nameOfRoom);
          }
        });

        // Store the room data for the next update
        domainRoomSetting.lastDataCache = currentData;
      });
      this.updatePending = false;
    }
  }

  onJoinRoom = (socket: Socket, nameOfRoom: string): void => {
    this.roomMap.forEach((domainRoomSetting, room) => {
      if (room.matchesRoom(nameOfRoom)) {
        const eventName = room.eventId(room.idOfRoom(nameOfRoom));
        domainRoomSetting.sockets.set(socket, nameOfRoom);
        if (domainRoomSetting.dynamicInterest) {
          this.dynamicInterestService?.retainRoomInterest(socket, nameOfRoom, domainRoomSetting.dynamicInterest);
        }
        if (this.debug) console.log('🟨 EMIT to ' + socket.id + ': ' + eventName);
        socket.emit(eventName, domainRoomSetting.jsonCreator(nameOfRoom));
        if (this.debug)
          console.log(
            domainRoomSetting.id,
            ': sending event',
            eventName,
            ' to ',
            nameOfRoom,
            ' on socket ',
            socket.id,
          );
      }
    });
    this.roomServices.forEach((service) => service.onJoinRoom?.(socket, nameOfRoom));
  };

  onLeaveRoom = (socket: Socket, nameOfRoom: string): void => {
    this.roomMap.forEach((domainRoomSetting, room) => {
      if (room.matchesRoom(nameOfRoom)) {
        domainRoomSetting.sockets.delete(socket);
        if (domainRoomSetting.dynamicInterest) {
          this.dynamicInterestService?.releaseRoomInterest(socket, nameOfRoom);
        }
        if (this.debug) console.log(domainRoomSetting.id, ': disconnect ', nameOfRoom, ' from socket ', socket.id);
      }
    });
    this.roomServices.forEach((service) => service.onLeaveRoom?.(socket, nameOfRoom));
  };

  onSocketClose = (socket: Socket): void => {
    this.roomMap.forEach((domainRoomSetting) => {
      domainRoomSetting.sockets.delete(socket);
      if (this.debug) console.log(domainRoomSetting.id, ': disconnect socket ', socket.id);
    });
    this.dynamicInterestService?.releaseSocketInterests(socket);
    this.roomServices.forEach((service) => service.onSocketClose?.(socket));
  };
}
