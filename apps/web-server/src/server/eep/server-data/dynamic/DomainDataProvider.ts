import { DomainRoom } from '@ce/web-shared';

export interface OnInterestBinding {
  ceType: string;
  idOfRoom?: (roomName: string) => string;
}

export interface DomainDataProvider {
  roomType: DomainRoom;
  id: string;
  jsonCreator: (roomName: string) => string;
  onInterest?: OnInterestBinding;
}
