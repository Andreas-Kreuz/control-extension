import { DynamicRoom } from '@ce/web-shared';

export interface DynamicInterestBinding {
  ceType: string;
  idOfRoom?: (roomName: string) => string;
}

export interface DynamicDataProvider {
  roomType: DynamicRoom;
  id: string;
  jsonCreator: (roomName: string) => string;
  dynamicInterest?: DynamicInterestBinding;
}
