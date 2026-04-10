import { useState } from 'react';
import { RollingStockDto, RollingStockRoom } from '@ce/web-shared';
import { useDynamicRoomHandler } from '../../../shared/socket/useRoomHandler';

function useRollingStock(name: string): RollingStockDto | undefined {
  const [rollingStock, setRollingStock] = useState<RollingStockDto | undefined>(undefined);

  useDynamicRoomHandler(
    RollingStockRoom,
    name,
    (payload: string) => {
      const data = JSON.parse(payload) as RollingStockDto | null;
      setRollingStock(data ?? undefined);
    },
    () => setRollingStock(undefined),
  );

  return rollingStock;
}

export default useRollingStock;
