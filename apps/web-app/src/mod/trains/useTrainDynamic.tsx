import { useDynamicRoomHandler } from '../../socket/useRoomHandler';
import { TrainDto, TrainRoom } from '@ce/web-shared';
import { useState } from 'react';

function useTrainDynamic(trainId: string): TrainDto | undefined {
  const [train, setTrain] = useState<TrainDto | undefined>(undefined);

  useDynamicRoomHandler(
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
