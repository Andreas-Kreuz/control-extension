import { CeTypes } from '@ce/web-shared';
import { useState } from 'react';
import { useApiDataRoomHandler } from '../../../shared/socket/useRoomHandler';
import type Intersection from '../model/Intersection';

function normalizeIntersection(intersection: Partial<Intersection>): Intersection {
  return {
    id: intersection.id ?? 0,
    name: intersection.name ?? '',
    timeForGreen: intersection.timeForGreen ?? 0,
    ready: intersection.ready ?? false,
    currentSwitching: intersection.currentSwitching ?? '',
    manualSwitching: intersection.manualSwitching ?? '',
    nextSwitching: intersection.nextSwitching ?? '',
    staticCams: intersection.staticCams ?? [],
    phases: intersection.phases ?? [],
  };
}

function useIntersections(): Intersection[] {
  const [intersections, setIntersections] = useState<Intersection[]>([]);

  useApiDataRoomHandler(CeTypes.RoadIntersection, (payload: string) => {
    const data: Record<string, Partial<Intersection>> = JSON.parse(payload);
    setIntersections(Object.values(data).map(normalizeIntersection));
  });

  return intersections;
}

export default useIntersections;
