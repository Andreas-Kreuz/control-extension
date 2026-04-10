import { CacheService } from '../CacheService';
import EepDataStore, { State } from '../EepDataStore';
import JsonApiReducer, { ServerData } from './ServerData';
import { ApiDataRoom, CeTypes, ServerStatusEvent } from '@ce/web-shared';
import express from 'express';
import { Server, Socket } from 'socket.io';

export default class JsonApiUpdateService {
  private debug = false;
  private reducer = new JsonApiReducer();

  constructor(
    private router: express.Router,
    private io: Server,
    private cacheService: CacheService,
  ) {
    this.router.get('/', (_req, res) => {
      const names = this.reducer.getAllRoomNames().sort();
      const items = names.map((n) => `<li><a href="/api/v1/${n}">${n}</a></li>`).join('');
      res.setHeader('Content-Type', 'text/html');
      res.send(
        `<!DOCTYPE html><html><head><meta charset="utf-8"><title>/api/v1</title>` +
          `<style>body{font-family:sans-serif;padding:2rem;max-width:600px}h1{color:#333}a{color:#0070f3}li{margin:.3rem 0}</style>` +
          `</head><body><h1>/api/v1</h1><ul>${items}</ul></body></html>`,
      );
    });
    this.router.get('/:room', (req, res, next?: express.NextFunction) => {
      const { room } = req.params;
      if (!this.reducer.roomAvailable(room)) {
        if (next) {
          next();
          return;
        }
        res.status(404).json({ error: 'not found' });
        return;
      }
      res.setHeader('Content-Type', 'application/json');
      res.send(this.reducer.getRoomJsonString(room));
    });
  }

  onJoinRoom = (socket: Socket, room: string) => {
    // Send data on join
    const roomNames = this.reducer.getAllRoomNames();
    for (const roomName of roomNames) {
      // Send datatype events to datatype rooms
      if (room === ApiDataRoom.roomId(roomName)) {
        const event = ApiDataRoom.eventId(roomName);
        if (this.debug) console.log('🟨 EMIT to ' + socket.id + ': ' + event);
        socket.emit(event, this.reducer.getRoomJsonString(roomName));
      }
    }

    // Send JsonKeys to all JsonKey rooms
    if (room === ServerStatusEvent.Room) {
      if (this.debug) console.log('🟨 EMIT to ' + socket.id + ': ' + ServerStatusEvent.UrlsChanged);
      socket.emit(ServerStatusEvent.UrlsChanged, this.reducer.getUrlJson());
    }
  };

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  onLeaveRoom = (socket: Socket, room: string) => {
    // Nothing to do here
  };

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  onSocketClose = (socket: Socket): void => {
    // Nothing to do here yet
  };

  onStateChange = (store: Readonly<EepDataStore>) => {
    const currentState: State = store.currentState();
    const oldData: ServerData = this.reducer.getLastAnnouncedData();
    const data: ServerData = JsonApiReducer.calculateData(currentState);
    if (!store.hasInitialState()) {
      this.cacheService.writeCache(currentState);
    }
    this.reducer.setLastAnnouncedData(data);
    this.registerStatsTimeout(data);

    this.announceEepData(oldData, data, currentState.eventCounter);
  };

  private announceEepData(oldData: ServerData, data: ServerData, eventCounter: number): void {
    // Get those new room names from the Json Content
    const oldRooms = Object.keys(oldData.roomToJson);
    const newRooms = Object.keys(data.roomToJson);

    // Calculate room changes
    const addedRooms = newRooms.filter((el) => !oldRooms.includes(el));
    const removedRooms = oldRooms.filter((el) => !newRooms.includes(el));
    const roomsToCheck = newRooms.filter((el) => oldRooms.includes(el));
    const modifiedRooms = JsonApiReducer.calcChangedRooms(roomsToCheck, oldData, data);

    // Inform the data listeners
    for (const roomName of addedRooms) {
      this.onRoomAdded(roomName, this.reducer.getRoomJsonString(roomName));
    }
    for (const roomName of modifiedRooms) {
      this.onRoomChanged(roomName, this.reducer.getRoomJsonString(roomName));
    }
    for (const roomName of removedRooms) {
      this.onRoomRemoved(roomName);
    }

    // Inform about URL listeners
    if (addedRooms.length > 0 || removedRooms.length > 0) {
      this.io.to(ServerStatusEvent.Room).emit(ServerStatusEvent.UrlsChanged, this.reducer.getUrlJson());
    }

    // console.log('EventCounter: ', currentState.eventCounter);
    this.io.to(ServerStatusEvent.Room).emit(ServerStatusEvent.CounterUpdated, eventCounter);
  }

  private onRoomAdded(key: string, json: string): void {
    if (this.debug) console.log('🟦 EMIT to all IO: ' + ApiDataRoom.roomId(key) + ' (' + ApiDataRoom.eventId(key));
    this.io.to(ApiDataRoom.roomId(key)).emit(ApiDataRoom.eventId(key), json);
  }

  private onRoomChanged(key: string, json: string): void {
    if (this.debug) console.log('🟦 EMIT to all IO: ' + ApiDataRoom.roomId(key) + ' (' + ApiDataRoom.eventId(key));
    this.io.to(ApiDataRoom.roomId(key)).emit(ApiDataRoom.eventId(key), json);
  }

  private onRoomRemoved(key: string): void {
    if (this.debug) console.log('🟦 EMIT to all IO: ' + ApiDataRoom.roomId(key) + ' (' + ApiDataRoom.eventId(key));
    this.io.to(ServerStatusEvent.Room).emit(ServerStatusEvent.UrlsChanged, this.reducer.getUrlJson());
    this.io.to(ApiDataRoom.roomId(key)).emit(ApiDataRoom.eventId(key), '{}');
  }

  private lastTimeOut?: NodeJS.Timeout;

  private registerStatsTimeout(data: ServerData) {
    if (this.lastTimeOut) {
      clearTimeout(this.lastTimeOut);
    }
    this.lastTimeOut = setTimeout(() => {
      const roomName = CeTypes.ServerStats;
      const currentStatsJson = data.roomToJson[roomName];
      if (!currentStatsJson) {
        return;
      }
      const currentStats = JSON.parse(currentStatsJson);
      const newStats = { ...currentStats, eepDataUpToDate: false };
      const newStatsJsonString = JSON.stringify(newStats);
      data.roomToJson[roomName] = newStatsJsonString;
      this.io.to(ApiDataRoom.roomId(roomName)).emit(ApiDataRoom.eventId(roomName), newStatsJsonString);
    }, 1000);
  }
}
