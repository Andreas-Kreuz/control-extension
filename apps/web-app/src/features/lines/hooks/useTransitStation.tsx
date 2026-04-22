import { useState } from 'react';
import { DomainRoom, TransitStationDetailsRoom, type TransitStationAppDto } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

const noopRoom = new DomainRoom('__noop__');

function useTransitStation(stationId?: string): TransitStationAppDto | undefined {
  const [station, setStation] = useState<TransitStationAppDto | undefined>(undefined);

  useDomainRoomHandler(
    stationId ? TransitStationDetailsRoom : noopRoom,
    stationId ?? '__noop__',
    (payload: string) => {
      const data = JSON.parse(payload) as TransitStationAppDto | null;
      setStation(data ?? undefined);
    },
    () => setStation(undefined),
  );

  return stationId ? station : undefined;
}

export default useTransitStation;
