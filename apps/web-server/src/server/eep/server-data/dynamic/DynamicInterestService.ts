import { DynamicInterestBinding } from './DomainDataProvider';
import DynamicInterestRegistry from './DynamicInterestRegistry';
import { Socket } from 'socket.io';

function socketRoomToken(socket: Socket, roomName: string): string {
  return 'socket:' + socket.id + '|room:' + roomName;
}

export default class DynamicInterestService {
  private socketTokens = new Map<string, Set<string>>();

  constructor(private dynamicInterestRegistry: DynamicInterestRegistry) {}

  retainRoomInterest(socket: Socket, roomName: string, binding: DynamicInterestBinding): void {
    const token = socketRoomToken(socket, roomName);
    const id = binding.idOfRoom ? binding.idOfRoom(roomName) : roomName;
    this.dynamicInterestRegistry.retainToken(token, binding.ceType, id);

    const tokens = this.socketTokens.get(socket.id) ?? new Set<string>();
    tokens.add(token);
    this.socketTokens.set(socket.id, tokens);
  }

  releaseRoomInterest(socket: Socket, roomName: string): void {
    const token = socketRoomToken(socket, roomName);
    this.dynamicInterestRegistry.releaseToken(token);

    const tokens = this.socketTokens.get(socket.id);
    tokens?.delete(token);
    if (tokens && tokens.size === 0) {
      this.socketTokens.delete(socket.id);
    }
  }

  releaseSocketInterests(socket: Socket): void {
    const tokens = this.socketTokens.get(socket.id);
    if (!tokens) {
      return;
    }

    for (const token of tokens) {
      this.dynamicInterestRegistry.releaseToken(token);
    }
    this.socketTokens.delete(socket.id);
  }

  touchLeasedToken(token: string, ceType: string, id: string, ttlMs: number): void {
    this.dynamicInterestRegistry.touchLeasedToken(token, ceType, id, ttlMs);
  }
}
