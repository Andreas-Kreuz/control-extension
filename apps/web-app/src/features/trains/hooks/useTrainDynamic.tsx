import { useState } from 'react';
import { TrainDto, TrainRoom } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useTrainDynamic(trainId: string): TrainDto | undefined {
  const [train, setTrain] = useState<TrainDto | undefined>(undefined);

  useDomainRoomHandler(
    TrainRoom,
    trainId,
    (payload: string) => {
      const data = JSON.parse(payload) as TrainDto | null;
      setTrain(data ?? undefined);
    },
    () => setTrain(undefined),
  );

  return train;
}

export default useTrainDynamic;
