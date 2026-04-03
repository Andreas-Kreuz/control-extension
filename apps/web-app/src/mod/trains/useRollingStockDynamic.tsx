import { useDynamicRoomHandler } from '../../socket/useRoomHandler';
import { RollingStockDynamicDto, RollingStockDynamicRoom } from '@ce/web-shared';
import { useState } from 'react';

function useRollingStockDynamic(rollingStockId: string): RollingStockDynamicDto | undefined {
  const [rollingStock, setRollingStock] = useState<RollingStockDynamicDto | undefined>(undefined);

  useDynamicRoomHandler(
    RollingStockDynamicRoom,
    rollingStockId,
    (payload: string) => {
      const data = JSON.parse(payload) as RollingStockDynamicDto | null;
      setRollingStock(data ?? undefined);
    },
    () => setRollingStock(undefined),
  );

  return rollingStock;
}

export default useRollingStockDynamic;

