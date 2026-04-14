import { OnInterestBinding } from './DomainDataProvider';
import InterestSyncRegistry from './InterestSyncRegistry';
import { Socket } from 'socket.io';

function socketRoomToken(socket: Socket, roomName: string): string {
  return 'socket:' + socket.id + '|room:' + roomName;
}

export default class InterestSyncService {
  private socketTokens = new Map<string, Set<string>>();

  constructor(private interestSyncRegistry: InterestSyncRegistry) {}

  retainRoomInterest(socket: Socket, roomName: string, binding: OnInterestBinding): void {
    const token = socketRoomToken(socket, roomName);
    const id = binding.idOfRoom ? binding.idOfRoom(roomName) : roomName;
    this.interestSyncRegistry.retainToken(token, binding.ceType, id);

    const tokens = this.socketTokens.get(socket.id) ?? new Set<string>();
    tokens.add(token);
    this.socketTokens.set(socket.id, tokens);
  }

  releaseRoomInterest(socket: Socket, roomName: string): void {
    const token = socketRoomToken(socket, roomName);
    this.interestSyncRegistry.releaseToken(token);

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
      this.interestSyncRegistry.releaseToken(token);
    }
    this.socketTokens.delete(socket.id);
  }

  touchLeasedToken(token: string, ceType: string, id: string, ttlMs: number): void {
    this.interestSyncRegistry.touchLeasedToken(token, ceType, id, ttlMs);
  }
}
