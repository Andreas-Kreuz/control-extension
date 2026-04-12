import { useState } from 'react';
import { CeTypes, type TransitStationDto } from '@ce/web-shared';
import { useApiDataRoomHandler } from '../../../shared/socket/useRoomHandler';

function useStations(): TransitStationDto[] {
  const [stations, setStations] = useState<TransitStationDto[]>([]);

  useApiDataRoomHandler(CeTypes.TransitStation, (payload: string) => {
    const data = JSON.parse(payload) as Record<string, TransitStationDto>;
    setStations(Object.values(data));
  });

  return stations;
}

export default useStations;
