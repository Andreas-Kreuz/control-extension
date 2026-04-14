import { useState } from 'react';
import { DomainRoom, TransitStationDetailsRoom, type TransitStationDto } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

const noopRoom = new DomainRoom('__noop__');

function useTransitStation(stationId?: string): TransitStationDto | undefined {
  const [station, setStation] = useState<TransitStationDto | undefined>(undefined);

  useDomainRoomHandler(
    stationId ? TransitStationDetailsRoom : noopRoom,
    stationId ?? '__noop__',
    (payload: string) => {
      const data = JSON.parse(payload) as TransitStationDto | null;
      setStation(data ?? undefined);
    },
    () => setStation(undefined),
  );

  return stationId ? station : undefined;
}

export default useTransitStation;
