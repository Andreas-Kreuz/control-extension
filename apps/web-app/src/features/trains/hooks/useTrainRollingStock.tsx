import { RollingStockDto } from '@ce/web-shared';
import { useEffect, useState } from 'react';
import { useSocketUrl } from '../../../app/hooks/useSocketUrl';

function useTrainRollingStock(trainId: string): RollingStockDto[] | undefined {
  const [rollingStock, setRollingStock] = useState<RollingStockDto[] | undefined>(undefined);
  const socketUrl = useSocketUrl();

  useEffect(() => {
    const controller = new AbortController();

    async function loadRollingStock(): Promise<void> {
      try {
        const response = await fetch(
          new URL(`/api/v1/train-static/${encodeURIComponent(trainId)}/rollingstock`, socketUrl).toString(),
          {
            signal: controller.signal,
          },
        );
        if (!response.ok) {
          setRollingStock(undefined);
          return;
        }

        const data = (await response.json()) as RollingStockDto[];
        setRollingStock(data);
      } catch (error) {
        if ((error as Error).name === 'AbortError') {
          return;
        }
        setRollingStock(undefined);
      }
    }

    void loadRollingStock();

    return () => controller.abort();
  }, [socketUrl, trainId]);

  return rollingStock;
}

export default useTrainRollingStock;
