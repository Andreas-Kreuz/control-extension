import { OnInterestBinding } from './DomainDataProvider';
import InterestSyncRegistry from './InterestSyncRegistry';
import { Socket } from 'socket.io';

function socketRoomToken(socket: Socket, roomName: string): string {
  return 'socket:' + socket.id + '|room:' + roomName;
}

export default class InterestSyncService {
  private socketTokens = new Map<string, Set<string>>();
  private roomTokens = new Map<string, Set<string>>();

  constructor(private interestSyncRegistry: InterestSyncRegistry) {}

  retainRoomInterest(socket: Socket, roomName: string, bindings: OnInterestBinding[]): void {
    const roomToken = socketRoomToken(socket, roomName);
    const retainedTokens = new Set<string>();

    const tokens = this.socketTokens.get(socket.id) ?? new Set<string>();
    bindings.forEach((entry, index) => {
      const token = bindings.length === 1 ? roomToken : roomToken + '|interest:' + index;
      const id = entry.idOfRoom ? entry.idOfRoom(roomName) : roomName;
      this.interestSyncRegistry.retainToken(token, entry.ceType, id);
      tokens.add(token);
      retainedTokens.add(token);
    });
    this.socketTokens.set(socket.id, tokens);
    this.roomTokens.set(roomToken, retainedTokens);
  }

  releaseRoomInterest(socket: Socket, roomName: string): void {
    const roomToken = socketRoomToken(socket, roomName);
    const roomTokens = this.roomTokens.get(roomToken) ?? new Set([roomToken]);
    const tokens = this.socketTokens.get(socket.id);

    for (const token of roomTokens) {
      this.interestSyncRegistry.releaseToken(token);
      tokens?.delete(token);
    }
    this.roomTokens.delete(roomToken);

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

    for (const roomToken of this.roomTokens.keys()) {
      if (roomToken.startsWith('socket:' + socket.id + '|')) {
        this.roomTokens.delete(roomToken);
      }
    }
  }

  touchLeasedToken(token: string, ceType: string, id: string, ttlMs: number): void {
    this.interestSyncRegistry.touchLeasedToken(token, ceType, id, ttlMs);
  }
}
