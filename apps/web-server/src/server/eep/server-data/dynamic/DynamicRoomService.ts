import { DynamicDataProvider } from './DynamicDataProvider';
import { DynamicDataUpdater } from './DynamicDataUpdater';
import { Socket } from 'socket.io';

export default interface DynamicRoomService {
  getUpdaters(): DynamicDataUpdater[];
  getDataProviders(): DynamicDataProvider[];
  onJoinRoom?(socket: Socket, roomName: string): void;
  onLeaveRoom?(socket: Socket, roomName: string): void;
  onSocketClose?(socket: Socket): void;
}
