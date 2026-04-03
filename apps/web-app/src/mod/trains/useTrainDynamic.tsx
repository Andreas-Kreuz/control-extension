import { useDynamicRoomHandler } from '../../socket/useRoomHandler';
import { TrainDynamicDto, TrainDynamicRoom } from '@ce/web-shared';
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

