import { useState } from 'react';
import { TransitTrainRoom, type TransitTrainAppDto } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useTransitTrain(trainId: string): TransitTrainAppDto | undefined {
  const [transitTrain, setTransitTrain] = useState<TransitTrainAppDto | undefined>(undefined);

  useDomainRoomHandler(
    TransitTrainRoom,
    trainId,
    (payload: string) => {
      const data = JSON.parse(payload) as TransitTrainAppDto | null;
      setTransitTrain(data ?? undefined);
    },
    () => setTransitTrain(undefined),
  );

  return transitTrain;
}

export default useTransitTrain;
