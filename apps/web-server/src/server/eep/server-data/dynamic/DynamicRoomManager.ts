import EepDataStore from '../EepDataStore';
import { DynamicDataProvider } from './DynamicDataProvider';
import DynamicInterestService from './DynamicInterestService';
import { DynamicDataUpdater } from './DynamicDataUpdater';
import DynamicRoomService from './DynamicRoomService';
import { DynamicRoom } from '@ce/web-shared';
import { Server, Socket } from 'socket.io';

export default class DynamicRoomManager {
  private debug = false;
  private updatePending = false;
  private dataUpdaters: DynamicDataUpdater[] = [];
  private roomServices: DynamicRoomService[] = [];
  private roomMap: Map<
    DynamicRoom,
      {
        id: string;
        jsonCreator: (roomName: string) => string;
        dynamicInterest?: DynamicDataProvider['dynamicInterest'];
        lastDataCache: Map<string, string>;
        currentData: Map<string, string>;
        sockets: Map<Socket, string>;
      }
  > = new Map();

  constructor(
    private io: Server,
    private dynamicInterestService?: DynamicInterestService,
  ) {}

  registerService(dynamicRoomService: DynamicRoomService) {
    this.roomServices.push(dynamicRoomService);
    dynamicRoomService.getUpdaters().forEach((element: DynamicDataUpdater) => {
      this.dataUpdaters.push(element);
    });

    dynamicRoomService.getDataProviders().forEach((provider: DynamicDataProvider) => {
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

      this.roomMap.forEach((dynRoomSetting, dynRoom) => {
        const lastDataCache = dynRoomSetting.lastDataCache;
        const roomSockets = dynRoomSetting.sockets;
        const jsonCreator = dynRoomSetting.jsonCreator;
        const currentData: Map<string, string> = new Map();
        const modifiedRooms: Map<string, boolean> = new Map();

        if (this.debug) console.log('ID', dynRoomSetting.id, roomSockets.size);

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
            const eventName = dynRoom.eventId(dynRoom.idOfRoom(nameOfRoom));
            this.io.to(nameOfRoom).emit(eventName, currentData.get(nameOfRoom));
            if (this.debug) console.log('Sending Data to ', nameOfRoom, currentData.get(nameOfRoom));
          } else {
            if (this.debug) console.log('Skipping data event to ', nameOfRoom);
          }
        });

        // Store the room data for the next update
        dynRoomSetting.lastDataCache = currentData;
      });
      this.updatePending = false;
    }
  }

  onJoinRoom = (socket: Socket, nameOfRoom: string): void => {
    this.roomMap.forEach((dynRoomSetting, room) => {
      if (room.matchesRoom(nameOfRoom)) {
        const eventName = room.eventId(room.idOfRoom(nameOfRoom));
        dynRoomSetting.sockets.set(socket, nameOfRoom);
        if (dynRoomSetting.dynamicInterest) {
          this.dynamicInterestService?.retainRoomInterest(socket, nameOfRoom, dynRoomSetting.dynamicInterest);
        }
        if (this.debug) console.log('🟨 EMIT to ' + socket.id + ': ' + eventName);
        socket.emit(eventName, dynRoomSetting.jsonCreator(nameOfRoom));
        if (this.debug)
          console.log(dynRoomSetting.id, ': sending event', eventName, ' to ', nameOfRoom, ' on socket ', socket.id);
      }
    });
    this.roomServices.forEach((service) => service.onJoinRoom?.(socket, nameOfRoom));
  };

  onLeaveRoom = (socket: Socket, nameOfRoom: string): void => {
    this.roomMap.forEach((dynRoomSetting, room) => {
      if (room.matchesRoom(nameOfRoom)) {
        dynRoomSetting.sockets.delete(socket);
        if (dynRoomSetting.dynamicInterest) {
          this.dynamicInterestService?.releaseRoomInterest(socket, nameOfRoom);
        }
        if (this.debug) console.log(dynRoomSetting.id, ': disconnect ', nameOfRoom, ' from socket ', socket.id);
      }
    });
    this.roomServices.forEach((service) => service.onLeaveRoom?.(socket, nameOfRoom));
  };

  onSocketClose = (socket: Socket): void => {
    this.roomMap.forEach((dynRoomSetting) => {
      dynRoomSetting.sockets.delete(socket);
      if (this.debug) console.log(dynRoomSetting.id, ': disconnect socket ', socket.id);
    });
    this.dynamicInterestService?.releaseSocketInterests(socket);
    this.roomServices.forEach((service) => service.onSocketClose?.(socket));
  };
}
