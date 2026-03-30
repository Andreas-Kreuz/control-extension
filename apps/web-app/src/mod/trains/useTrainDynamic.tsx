import { useDynamicRoomHandler } from '../../io/useRoomHandler';
import { TrainDynamicDto, TrainDynamicRoom } from '@ak/web-shared';
import { useState } from 'react';

function useTrainDynamic(trainId: string): TrainDynamicDto | undefined {
  const [train, setTrain] = useState<TrainDynamicDto | undefined>(undefined);

  useDynamicRoomHandler(
    TrainDynamicRoom,
    trainId,
    (payload: string) => {
      const data = JSON.parse(payload) as TrainDynamicDto | null;
      setTrain(data ?? undefined);
    },
    () => setTrain(undefined),
  );

  return train;
}

export default useTrainDynamic;
