import { useDynamicRoomHandler } from '../../io/useRoomHandler';
import { RollingStockStaticDto, RollingStockStaticRoom } from '@ce/web-shared';
import { useState } from 'react';

function useRollingStock(name: string): RollingStockStaticDto | undefined {
  const [rollingStock, setRollingStock] = useState<RollingStockStaticDto | undefined>(undefined);

  useDynamicRoomHandler(
    RollingStockStaticRoom,
    name,
    (payload: string) => {
      const data = JSON.parse(payload) as RollingStockStaticDto | null;
      setRollingStock(data ?? undefined);
    },
    () => setRollingStock(undefined),
  );

  return rollingStock;
}

export default useRollingStock;

