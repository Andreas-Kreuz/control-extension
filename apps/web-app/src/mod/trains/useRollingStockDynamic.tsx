import { useDynamicRoomHandler } from '../../socket/useRoomHandler';
import { RollingStockDto, RollingStockRoom } from '@ce/web-shared';
import { useState } from 'react';

function useRollingStockDynamic(rollingStockId: string): RollingStockDto | undefined {
  const [rollingStock, setRollingStock] = useState<RollingStockDto | undefined>(undefined);

  useDynamicRoomHandler(
    RollingStockRoom,
    rollingStockId,
    (payload: string) => {
      const data = JSON.parse(payload) as RollingStockDto | null;
      setRollingStock(data ?? undefined);
    },
    () => setRollingStock(undefined),
  );

  return rollingStock;
}

export default useRollingStockDynamic;
