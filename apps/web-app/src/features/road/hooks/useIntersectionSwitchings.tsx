import { CeTypes } from '@ce/web-shared';
import { useState } from 'react';
import { useApiDataRoomHandler } from '../../../shared/socket/useRoomHandler';
import IntersectionSwitching from '../model/IntersectionSwitching';

function useIntersectionSwitchings(): IntersectionSwitching[] {
  const [intersectionSwitchings, setIntersectionSwitchings] = useState<IntersectionSwitching[]>([]);

  useApiDataRoomHandler(CeTypes.RoadIntersectionSwitching, (payload: string) => {
    const data: Record<string, IntersectionSwitching> = JSON.parse(payload);
    setIntersectionSwitchings(Object.values(data));
  });

  return intersectionSwitchings;
}

export default useIntersectionSwitchings;
