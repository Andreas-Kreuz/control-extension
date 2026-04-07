import { CeTypes } from '@ce/web-shared';
import { useState } from 'react';
import { useApiDataRoomHandler } from '../../socket/useRoomHandler';
import Intersection from './model/Intersection';

function useIntersections(): Intersection[] {
  const [intersections, setIntersections] = useState<Intersection[]>([]);

  useApiDataRoomHandler(CeTypes.RoadIntersection, (payload: string) => {
    const data: Record<string, Intersection> = JSON.parse(payload);
    setIntersections(Object.values(data));
  });

  return intersections;
}

export default useIntersections;

