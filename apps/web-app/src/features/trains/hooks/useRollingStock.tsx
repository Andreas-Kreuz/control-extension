import { useState } from 'react';
import { RollingStockAppDto, RollingStockRoom } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useRollingStock(name: string): RollingStockAppDto | undefined {
  const [rollingStock, setRollingStock] = useState<RollingStockAppDto | undefined>(undefined);

  useDomainRoomHandler(
    RollingStockRoom,
    name,
    (payload: string) => {
      const data = JSON.parse(payload) as RollingStockAppDto | null;
      setRollingStock(data ?? undefined);
    },
    () => setRollingStock(undefined),
  );

  return rollingStock;
}

export default useRollingStock;
