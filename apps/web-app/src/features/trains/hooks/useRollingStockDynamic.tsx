import { useState } from 'react';
import { RollingStockAppDto, RollingStockRoom } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useRollingStockDynamic(rollingStockId: string): RollingStockAppDto | undefined {
  const [rollingStock, setRollingStock] = useState<RollingStockAppDto | undefined>(undefined);

  useDomainRoomHandler(
    RollingStockRoom,
    rollingStockId,
    (payload: string) => {
      const data = JSON.parse(payload) as RollingStockAppDto | null;
      setRollingStock(data ?? undefined);
    },
    () => setRollingStock(undefined),
  );

  return rollingStock;
}

export default useRollingStockDynamic;
