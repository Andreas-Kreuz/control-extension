import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
import DynamicInterestRegistry from '../../eep/server-data/dynamic/DynamicInterestRegistry';
import { RollingStockSelector } from './RollingStockSelector';
import { TrainSelector } from './TrainSelector';
import EepService from '../../eep/service/EepService';
import { State } from '../../eep/server-data/EepDataStore';
import {
  CeTypes,
  RollingStockRoom,
  RollingStockTexturesRoom,
  RollingStockRotationRoom,
  TrainListRoom,
  TrainRoom,
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
  private rollingStockSelector = new RollingStockSelector();
  private trainSelector = new TrainSelector(this.rollingStockSelector);
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
        return JSON.stringify(this.trainSelector.getTrainList(trackType));
      },
    });
    this.roomDataProviders.push({
      roomType: TrainRoom,
      id: 'TrainRoom',
      jsonCreator: (room: string): string => {
        const trainId = TrainRoom.idOfRoom(room);
        return JSON.stringify(this.trainSelector.getTrain(trainId) ?? null);
      },
    });
    this.roomDataProviders.push({
      roomType: RollingStockRoom,
      id: 'RollingStockRoom',
      jsonCreator: (room: string): string => {
        const rollingStockId = RollingStockRoom.idOfRoom(room);
        return JSON.stringify(this.rollingStockSelector.getRollingStock(rollingStockId) ?? null);
      },
    });
    this.roomDataProviders.push({
      roomType: RollingStockTexturesRoom,
      id: 'RollingStockTexturesRoom',
      jsonCreator: (room: string): string => {
        const rollingStockId = RollingStockTexturesRoom.idOfRoom(room);
        return JSON.stringify(this.rollingStockSelector.getRollingStockTextures(rollingStockId) ?? null);
      },
    });
    this.roomDataProviders.push({
      roomType: RollingStockRotationRoom,
      id: 'RollingStockRotationRoom',
      jsonCreator: (room: string): string => {
        const rollingStockId = RollingStockRotationRoom.idOfRoom(room);
        return JSON.stringify(this.rollingStockSelector.getRollingStockRotation(rollingStockId) ?? null);
      },
    });

    this.registerRoutes();
  }

  getUpdaters = () => [
    { updateFromState: this.trainSelector.updateFromState },
    { updateFromState: (state: Readonly<State>) => this.rollingStockSelector.updateFromState(state) },
  ];

  getDataProviders = () => this.roomDataProviders;

  onJoinRoom(socket: Socket, roomName: string): void {
    if (TrainRoom.matchesRoom(roomName)) {
      const trainId = TrainRoom.idOfRoom(roomName);
      this.retainSocketRoomInterest(socket, roomName, CeTypes.HubTrain, trainId);
      return;
    }

    if (RollingStockRoom.matchesRoom(roomName)) {
      const rollingStockId = RollingStockRoom.idOfRoom(roomName);
      this.retainSocketRoomInterest(socket, roomName, CeTypes.HubRollingStock, rollingStockId);
    }
  }

  onLeaveRoom(socket: Socket, roomName: string): void {
    if (TrainRoom.matchesRoom(roomName) || RollingStockRoom.matchesRoom(roomName)) {
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
      res.json(this.trainSelector.getAllTrains());
    });

    this.router.get('/train-static/:id', (req, res) => {
      const train = this.trainSelector.getTrain(req.params.id);
      if (!train) {
        res.status(404).json({ error: 'not found' });
        return;
      }
      res.json(train);
    });

    this.router.get('/train-static/:id/rollingstock', (req, res) => {
      const train = this.trainSelector.getTrain(req.params.id);
      if (!train) {
        res.status(404).json({ error: 'not found' });
        return;
      }

      const rollingStockById = this.rollingStockSelector.rollingStockListOfTrain(train.id);
      if (rollingStockById.length > 0 || train.name === train.id) {
        res.json(rollingStockById);
        return;
      }

      res.json(this.rollingStockSelector.rollingStockListOfTrain(train.name));
    });

    this.router.get('/rollingstock-static', (_req, res) => {
      res.json(this.rollingStockSelector.getAllRollingStock());
    });

    this.router.get('/rollingstock-static/:id', (req, res) => {
      const rollingStock = this.rollingStockSelector.getRollingStock(req.params.id);
      if (!rollingStock) {
        res.status(404).json({ error: 'not found' });
        return;
      }
      res.json(rollingStock);
    });

    this.router.get('/train-dynamic/:id', async (req, res) => {
      const trainId = req.params.id;
      if (!this.trainSelector.getTrain(trainId)) {
        res.status(404).json({ error: 'not found' });
        return;
      }

      const token = 'json:' + CeTypes.HubTrain + ':' + trainId;
      this.dynamicInterestRegistry.touchLeasedToken(token, CeTypes.HubTrain, trainId, jsonInterestTtlMs);
      const train = await this.waitForDynamicData(() => this.trainSelector.getTrain(trainId));
      if (!train) {
        res.status(504).json({ error: 'timeout' });
        return;
      }
      res.json(train);
    });

    this.router.get('/rollingstock-dynamic/:id', async (req, res) => {
      const rollingStockId = req.params.id;
      if (!this.rollingStockSelector.getRollingStock(rollingStockId)) {
        res.status(404).json({ error: 'not found' });
        return;
      }

      const token = 'json:' + CeTypes.HubRollingStock + ':' + rollingStockId;
      this.dynamicInterestRegistry.touchLeasedToken(
        token,
        CeTypes.HubRollingStock,
        rollingStockId,
        jsonInterestTtlMs,
      );
      const rollingStock = await this.waitForDynamicData(() => this.rollingStockSelector.getRollingStock(rollingStockId));
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
