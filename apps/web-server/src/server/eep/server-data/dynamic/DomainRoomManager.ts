import EepDataStore from '../EepDataStore';
import { DomainDataProvider, OnInterestBinding } from './DomainDataProvider';
import InterestSyncService from './InterestSyncService';
import { StateDataUpdater } from './StateDataUpdater';
import DomainRoomService from './DomainRoomService';
import DomainRoomInterestRegistry from './DomainRoomInterestRegistry';
import { CeTypeRoom, DomainRoom } from '@ce/web-shared';
import { Server, Socket } from 'socket.io';

export default class DomainRoomManager {
  private debug = false;
  private updatePending = false;
  private currentCeTypes: Record<string, Record<string, unknown>> = {};
  private ceTypeRoomSockets: Map<string, { ceType: string; entryId: string; sockets: Set<Socket> }> = new Map();
  private ceTypeRoomDataCache: Map<string, string> = new Map();
  private dataUpdaters: StateDataUpdater[] = [];
  private roomServices: DomainRoomService[] = [];
  private roomMap: Map<
    DomainRoom,
    {
      id: string;
      jsonCreator: (roomName: string) => string;
      onInterest: OnInterestBinding[];
      lastDataCache: Map<string, string>;
      currentData: Map<string, string>;
      sockets: Map<Socket, Set<string>>;
    }
  > = new Map();

  constructor(
    private io: Server,
    private interestSyncService?: InterestSyncService,
    private interestRegistry: DomainRoomInterestRegistry = new DomainRoomInterestRegistry(),
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
        onInterest:
          provider.onInterest !== undefined ? provider.onInterest : this.interestRegistry.bindingsFor(provider.roomType),
        lastDataCache: new Map(),
        currentData: new Map(),
        sockets: new Map(),
      });
    });
  }

  onStateChange(store: Readonly<EepDataStore>): void {
    this.currentCeTypes = store.currentState().ceTypes;

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
        roomSockets.forEach((namesOfRooms) => {
          namesOfRooms.forEach((nameOfRoom) => roomNames.set(nameOfRoom, true));
        });

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
      this.emitCeTypeRoomUpdates();
      this.updatePending = false;
    }
  }

  onJoinRoom = (socket: Socket, nameOfRoom: string): void => {
    let matchedDomainRoom = false;
    this.roomMap.forEach((domainRoomSetting, room) => {
      if (room.matchesRoom(nameOfRoom)) {
        matchedDomainRoom = true;
        const eventName = room.eventId(room.idOfRoom(nameOfRoom));
        socket.join(nameOfRoom);
        const socketRooms = domainRoomSetting.sockets.get(socket) ?? new Set<string>();
        socketRooms.add(nameOfRoom);
        domainRoomSetting.sockets.set(socket, socketRooms);
        if (domainRoomSetting.onInterest.length > 0) {
          this.interestSyncService?.retainRoomInterest(socket, nameOfRoom, domainRoomSetting.onInterest);
        }
        if (this.debug) console.log('🟨 EMIT to ' + socket.id + ': ' + eventName);
        socket.emit(eventName, domainRoomSetting.jsonCreator(nameOfRoom));
        if (this.debug)
          console.log(domainRoomSetting.id, ': sending event', eventName, ' to ', nameOfRoom, ' on socket ', socket.id);
      }
    });
    if (!matchedDomainRoom) {
      this.joinCeTypeRoom(socket, nameOfRoom);
    }
    this.roomServices.forEach((service) => service.onJoinRoom?.(socket, nameOfRoom));
  };

  onLeaveRoom = (socket: Socket, nameOfRoom: string): void => {
    let matchedDomainRoom = false;
    this.roomMap.forEach((domainRoomSetting, room) => {
      if (room.matchesRoom(nameOfRoom)) {
        matchedDomainRoom = true;
        socket.leave(nameOfRoom);
        const socketRooms = domainRoomSetting.sockets.get(socket);
        socketRooms?.delete(nameOfRoom);
        if (!socketRooms || socketRooms.size === 0) {
          domainRoomSetting.sockets.delete(socket);
        }
        if (domainRoomSetting.onInterest.length > 0) {
          this.interestSyncService?.releaseRoomInterest(socket, nameOfRoom);
        }
        if (this.debug) console.log(domainRoomSetting.id, ': disconnect ', nameOfRoom, ' from socket ', socket.id);
      }
    });
    if (!matchedDomainRoom) {
      this.leaveCeTypeRoom(socket, nameOfRoom);
    }
    this.roomServices.forEach((service) => service.onLeaveRoom?.(socket, nameOfRoom));
  };

  onSocketClose = (socket: Socket): void => {
    this.roomMap.forEach((domainRoomSetting) => {
      domainRoomSetting.sockets.delete(socket);
      if (this.debug) console.log(domainRoomSetting.id, ': disconnect socket ', socket.id);
    });
    this.removeSocketFromCeTypeRooms(socket);
    this.interestSyncService?.releaseSocketInterests(socket);
    this.roomServices.forEach((service) => service.onSocketClose?.(socket));
  };

  private joinCeTypeRoom(socket: Socket, roomName: string): void {
    const parsedRoom = CeTypeRoom.parseRoomId(roomName);
    if (!parsedRoom || !Object.prototype.hasOwnProperty.call(this.currentCeTypes, parsedRoom.ceType)) {
      return;
    }

    socket.join(roomName);
    let setting = this.ceTypeRoomSockets.get(roomName);
    if (!setting) {
      setting = { ...parsedRoom, sockets: new Set<Socket>() };
      this.ceTypeRoomSockets.set(roomName, setting);
    }
    setting.sockets.add(socket);

    this.interestSyncService?.retainRoomInterest(socket, roomName, [
      { ceType: parsedRoom.ceType, idOfRoom: () => parsedRoom.entryId },
    ]);

    const room = new CeTypeRoom(parsedRoom.ceType);
    const eventName = room.eventId(parsedRoom.entryId);
    const json = this.getCeTypeRoomJson(parsedRoom.ceType, parsedRoom.entryId);
    this.ceTypeRoomDataCache.set(roomName, json);
    socket.emit(eventName, json);
  }

  private leaveCeTypeRoom(socket: Socket, roomName: string): void {
    const setting = this.ceTypeRoomSockets.get(roomName);
    if (!setting) {
      return;
    }

    socket.leave(roomName);
    setting.sockets.delete(socket);
    this.interestSyncService?.releaseRoomInterest(socket, roomName);
    if (setting.sockets.size === 0) {
      this.ceTypeRoomSockets.delete(roomName);
      this.ceTypeRoomDataCache.delete(roomName);
    }
  }

  private removeSocketFromCeTypeRooms(socket: Socket): void {
    for (const [roomName, setting] of this.ceTypeRoomSockets.entries()) {
      setting.sockets.delete(socket);
      if (setting.sockets.size === 0) {
        this.ceTypeRoomSockets.delete(roomName);
        this.ceTypeRoomDataCache.delete(roomName);
      }
    }
  }

  private emitCeTypeRoomUpdates(): void {
    for (const [roomName, setting] of this.ceTypeRoomSockets.entries()) {
      const newJson = this.getCeTypeRoomJson(setting.ceType, setting.entryId);
      if (this.ceTypeRoomDataCache.get(roomName) === newJson) {
        continue;
      }

      this.ceTypeRoomDataCache.set(roomName, newJson);
      const eventName = new CeTypeRoom(setting.ceType).eventId(setting.entryId);
      this.io.to(roomName).emit(eventName, newJson);
    }
  }

  private getCeTypeRoomJson(ceType: string, entryId: string): string {
    return JSON.stringify(this.currentCeTypes[ceType]?.[entryId] ?? null);
  }
}
