import { useState } from 'react';
import { TransitTrainRoom, type TransitTrainDto } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useTransitTrain(trainId: string): TransitTrainDto | undefined {
  const [transitTrain, setTransitTrain] = useState<TransitTrainDto | undefined>(undefined);

  useDomainRoomHandler(
    TransitTrainRoom,
    trainId,
    (payload: string) => {
      const data = JSON.parse(payload) as TransitTrainDto | null;
      setTransitTrain(data ?? undefined);
    },
    () => setTransitTrain(undefined),
  );

  return transitTrain;
}

export default useTransitTrain;
