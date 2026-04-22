import { useState } from 'react';
import { TransitStationListRoom, type TransitStationAppDto } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useStations(): TransitStationAppDto[] {
  const [stations, setStations] = useState<TransitStationAppDto[]>([]);

  useDomainRoomHandler(TransitStationListRoom, 'All', (payload: string) => {
    const data = JSON.parse(payload) as TransitStationAppDto[];
    setStations(data);
  });

  return stations;
}

export default useStations;
