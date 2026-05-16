import { IntersectionPhaseListRoom } from '@ce/web-shared';
import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import IntersectionPhase from '../model/IntersectionPhase';

function useIntersectionPhases(): IntersectionPhase[] {
  const [intersectionPhases, setIntersectionPhases] = useState<IntersectionPhase[]>([]);

  useDomainRoomHandler(IntersectionPhaseListRoom, 'All', (payload: string) => {
    const data: Record<string, IntersectionPhase> = JSON.parse(payload);
    setIntersectionPhases(Object.values(data));
  });

  return intersectionPhases;
}

export default useIntersectionPhases;
