import { TrainAppDto, TrainRoom } from '@ce/web-shared';
import { useEffect, useState } from 'react';
import { useSocketUrl } from '../../../app/hooks/useSocketUrl';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useTrainDynamic(trainId: string): TrainAppDto | undefined {
  const [train, setTrain] = useState<TrainAppDto | undefined>(undefined);
  const socketUrl = useSocketUrl();

  useEffect(() => {
    if (!trainId) {
      setTrain(undefined);
      return;
    }

    const controller = new AbortController();
    setTrain(undefined);

    async function loadTrain(): Promise<void> {
      try {
        const response = await fetch(new URL(`/api/v1/train-dynamic/${encodeURIComponent(trainId)}`, socketUrl), {
          signal: controller.signal,
        });
        if (!response.ok) {
          setTrain(undefined);
          return;
        }

        const data = (await response.json()) as TrainAppDto | null;
        setTrain(data ?? undefined);
      } catch (error) {
        if ((error as Error).name === 'AbortError') {
          return;
        }
        setTrain(undefined);
      }
    }

    void loadTrain();
    const intervalId = window.setInterval(() => void loadTrain(), 1000);

    return () => {
      window.clearInterval(intervalId);
      controller.abort();
    };
  }, [socketUrl, trainId]);

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
