import { useState } from 'react';
import { TrainAppDto, TrainRoom } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useTrainDynamic(trainId: string): TrainAppDto | undefined {
  const [train, setTrain] = useState<TrainAppDto | undefined>(undefined);

  useDomainRoomHandler(
    TrainRoom,
    trainId,
    (payload: string) => {
      const data = JSON.parse(payload) as TrainAppDto | null;
      setTrain(data ?? undefined);
    },
    () => setTrain(undefined),
  );

  return train;
}

export default useTrainDynamic;
