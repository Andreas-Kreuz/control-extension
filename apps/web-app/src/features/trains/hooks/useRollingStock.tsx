import { useState } from 'react';
import { RollingStockDto, RollingStockRoom } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useRollingStock(name: string): RollingStockDto | undefined {
  const [rollingStock, setRollingStock] = useState<RollingStockDto | undefined>(undefined);

  useDomainRoomHandler(
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
