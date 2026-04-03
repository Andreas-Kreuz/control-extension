import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
import DynamicInterestRegistry from '../../eep/server-data/dynamic/DynamicInterestRegistry';
import { RollingStockDynamicSelector } from './RollingStockDynamicSelector';
import { RollingStockStaticSelector } from './RollingStockStaticSelector';
import { TrainDynamicSelector } from './TrainDynamicSelector';
import { TrainStaticSelector } from './TrainStaticSelector';
import EepService from '../../eep/service/EepService';
import { State } from '../../eep/server-data/EepDataStore';
import {
  CeTypes,
  RollingStockDynamicRoom,
  RollingStockStaticRoom,
  TrainDynamicRoom,
  TrainListRoom,
  TrainStaticRoom,
} from '@ce/web-shared';
import express from 'express';
import { Server, Socket } from 'socket.io';

const jsonInterestTtlMs = 5000;
const jsonDataTimeoutMs = 1000;
const waitForDynamicDataPollMs = 25;

function roomToken(socket: Socket, roomName: string): string {
  return 'socket:' + socket.id + '|room:' + roomName;
}

export default class TrainUpdateService implements DynamicRoomService {
  private roomDataProviders: DynamicDataProvider[] = [];
  private rollingStockStaticSelector = new RollingStockStaticSelector();
  private rollingStockDynamicSelector = new RollingStockDynamicSelector();
  private trainStaticSelector = new TrainStaticSelector(this.rollingStockStaticSelector);
  private trainDynamicSelector = new TrainDynamicSelector();
  private dynamicInterestRegistry: DynamicInterestRegistry;
  private socketTokens = new Map<string, Set<string>>();

  constructor(
    private io: Server,
    private router: express.Router,
    eepService: EepService,
  ) {
    this.dynamicInterestRegistry = new DynamicInterestRegistry(eepService.queueCommand);

    this.roomDataProviders.push({
      roomType: TrainListRoom,
      id: 'TrainListRoom',
      jsonCreator: (room: string): string => {
        const trackType = TrainListRoom.idOfRoom(room);
        return JSON.stringify(this.trainStaticSelector.getTrainList(trackType));
      },
    });
    this.roomDataProviders.push({
      roomType: TrainStaticRoom,
      id: 'TrainStaticRoom',
      jsonCreator: (room: string): string => {
        const trainId = TrainStaticRoom.idOfRoom(room);
        return JSON.stringify(this.trainStaticSelector.getTrain(trainId) ?? null);
      },
    });
    this.roomDataProviders.push({
      roomType: TrainDynamicRoom,
      id: 'TrainDynamicRoom',
      jsonCreator: (room: string): string => {
        const trainId = TrainDynamicRoom.idOfRoom(room);
        return JSON.stringify(this.trainDynamicSelector.getTrain(trainId) ?? null);
      },
    });
    this.roomDataProviders.push({
      roomType: RollingStockStaticRoom,
      id: 'RollingStockStaticRoom',
      jsonCreator: (room: string): string => {
        const rollingStockId = RollingStockStaticRoom.idOfRoom(room);
        return JSON.stringify(this.rollingStockStaticSelector.getRollingStock(rollingStockId) ?? null);
      },
    });
    this.roomDataProviders.push({
      roomType: RollingStockDynamicRoom,
      id: 'RollingStockDynamicRoom',
      jsonCreator: (room: string): string => {
        const rollingStockId = RollingStockDynamicRoom.idOfRoom(room);
        return JSON.stringify(this.rollingStockDynamicSelector.getRollingStock(rollingStockId) ?? null);
      },
    });

    this.registerRoutes();
  }

  getUpdaters = () => [
    { updateFromState: this.trainStaticSelector.updateFromState },
    { updateFromState: this.trainDynamicSelector.updateFromState },
    { updateFromState: (state: Readonly<State>) => this.rollingStockStaticSelector.updateFromState(state) },
    { updateFromState: (state: Readonly<State>) => this.rollingStockDynamicSelector.updateFromState(state) },
  ];

  getDataProviders = () => this.roomDataProviders;

  onJoinRoom(socket: Socket, roomName: string): void {
    if (TrainDynamicRoom.matchesRoom(roomName)) {
      const trainId = TrainDynamicRoom.idOfRoom(roomName);
      this.retainSocketRoomInterest(socket, roomName, CeTypes.HubTrainDynamic, trainId);
      return;
    }

    if (RollingStockDynamicRoom.matchesRoom(roomName)) {
      const rollingStockId = RollingStockDynamicRoom.idOfRoom(roomName);
      this.retainSocketRoomInterest(socket, roomName, CeTypes.HubRollingStockDynamic, rollingStockId);
    }
  }

  onLeaveRoom(socket: Socket, roomName: string): void {
    if (TrainDynamicRoom.matchesRoom(roomName) || RollingStockDynamicRoom.matchesRoom(roomName)) {
      this.releaseSocketRoomInterest(socket, roomName);
    }
  }

  onSocketClose(socket: Socket): void {
    const tokens = this.socketTokens.get(socket.id);
    if (!tokens) {
      return;
    }

    for (const token of tokens) {
      this.dynamicInterestRegistry.releaseToken(token);
    }
    this.socketTokens.delete(socket.id);
  }

  private registerRoutes(): void {
    this.router.get('/train-static', (_req, res) => {
      res.json(this.trainStaticSelector.getAllTrains());
    });

    this.router.get('/train-static/:id', (req, res) => {
      const train = this.trainStaticSelector.getTrain(req.params.id);
      if (!train) {
        res.status(404).json({ error: 'not found' });
        return;
      }
      res.json(train);
    });

    this.router.get('/rollingstock-static', (_req, res) => {
      res.json(this.rollingStockStaticSelector.getAllRollingStock());
    });

    this.router.get('/rollingstock-static/:id', (req, res) => {
      const rollingStock = this.rollingStockStaticSelector.getRollingStock(req.params.id);
      if (!rollingStock) {
        res.status(404).json({ error: 'not found' });
        return;
      }
      res.json(rollingStock);
    });

    this.router.get('/train-dynamic/:id', async (req, res) => {
      const trainId = req.params.id;
      if (!this.trainStaticSelector.getTrain(trainId)) {
        res.status(404).json({ error: 'not found' });
        return;
      }

      const token = 'json:' + CeTypes.HubTrainDynamic + ':' + trainId;
      this.dynamicInterestRegistry.touchLeasedToken(token, CeTypes.HubTrainDynamic, trainId, jsonInterestTtlMs);
      const train = await this.waitForDynamicData(() => this.trainDynamicSelector.getTrain(trainId));
      if (!train) {
        res.status(504).json({ error: 'timeout' });
        return;
      }
      res.json(train);
    });

    this.router.get('/rollingstock-dynamic/:id', async (req, res) => {
      const rollingStockId = req.params.id;
      if (!this.rollingStockStaticSelector.getRollingStock(rollingStockId)) {
        res.status(404).json({ error: 'not found' });
        return;
      }

      const token = 'json:' + CeTypes.HubRollingStockDynamic + ':' + rollingStockId;
      this.dynamicInterestRegistry.touchLeasedToken(
        token,
        CeTypes.HubRollingStockDynamic,
        rollingStockId,
        jsonInterestTtlMs,
      );
      const rollingStock = await this.waitForDynamicData(() => this.rollingStockDynamicSelector.getRollingStock(rollingStockId));
      if (!rollingStock) {
        res.status(504).json({ error: 'timeout' });
        return;
      }
      res.json(rollingStock);
    });
  }

  private retainSocketRoomInterest(socket: Socket, roomName: string, ceType: string, id: string): void {
    const token = roomToken(socket, roomName);
    this.dynamicInterestRegistry.retainToken(token, ceType, id);

    const tokens = this.socketTokens.get(socket.id) ?? new Set<string>();
    tokens.add(token);
    this.socketTokens.set(socket.id, tokens);
  }

  private releaseSocketRoomInterest(socket: Socket, roomName: string): void {
    const token = roomToken(socket, roomName);
    this.dynamicInterestRegistry.releaseToken(token);

    const tokens = this.socketTokens.get(socket.id);
    tokens?.delete(token);
    if (tokens && tokens.size === 0) {
      this.socketTokens.delete(socket.id);
    }
  }

  private async waitForDynamicData<T>(getter: () => T | undefined): Promise<T | undefined> {
    const immediate = getter();
    if (immediate !== undefined) {
      return immediate;
    }

    return new Promise((resolve) => {
      const startedAt = Date.now();
      const timer = setInterval(() => {
        const currentValue = getter();
        if (currentValue !== undefined) {
          clearInterval(timer);
          resolve(currentValue);
          return;
        }

        if (Date.now() - startedAt >= jsonDataTimeoutMs) {
          clearInterval(timer);
          resolve(undefined);
        }
      }, waitForDynamicDataPollMs);
    });
  }
}

