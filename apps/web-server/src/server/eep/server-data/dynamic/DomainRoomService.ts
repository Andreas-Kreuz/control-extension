import { DomainDataProvider } from './DomainDataProvider';
import { StateDataUpdater } from './StateDataUpdater';
import { Socket } from 'socket.io';

export default interface DomainRoomService {
  getUpdaters(): StateDataUpdater[];
  getDataProviders(): DomainDataProvider[];
  onJoinRoom?(socket: Socket, roomName: string): void;
  onLeaveRoom?(socket: Socket, roomName: string): void;
  onSocketClose?(socket: Socket): void;
}
