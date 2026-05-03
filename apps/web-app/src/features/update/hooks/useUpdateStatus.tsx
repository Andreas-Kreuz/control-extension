import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import { UpdateStatusAppDto, UpdateStatusRoom } from '@ce/web-shared';

const UPDATE_STATUS_ROOM_ELEMENT = 'UpdateStatus';

const initialUpdateStatus: UpdateStatusAppDto = {
  state: 'unknown',
  currentVersion: '?',
};

export default function useUpdateStatus(): UpdateStatusAppDto {
  const [updateStatus, setUpdateStatus] = useState<UpdateStatusAppDto>(initialUpdateStatus);

  useDomainRoomHandler(UpdateStatusRoom, UPDATE_STATUS_ROOM_ELEMENT, (payload: string) => {
    setUpdateStatus(JSON.parse(payload) as UpdateStatusAppDto);
  });

  return updateStatus;
}
