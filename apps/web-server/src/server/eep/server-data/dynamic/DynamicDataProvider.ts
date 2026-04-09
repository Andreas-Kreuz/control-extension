import { DynamicRoom } from '@ce/web-shared';

export interface DynamicDataProvider {
  roomType: DynamicRoom;
  id: string;
  jsonCreator: (roomName: string) => string;
}
