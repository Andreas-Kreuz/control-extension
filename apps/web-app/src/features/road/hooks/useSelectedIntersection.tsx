import { DomainRoom, IntersectionRoom } from '@ce/web-shared';
import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import type Intersection from '../model/Intersection';

const noopRoom = new DomainRoom('__noop__');

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

function useSelectedIntersection(intersectionId?: string): Intersection | undefined {
  const [intersection, setIntersection] = useState<Intersection | undefined>(undefined);

  useDomainRoomHandler(
    intersectionId ? IntersectionRoom : noopRoom,
    intersectionId ?? '__noop__',
    (payload: string) => {
      const data = JSON.parse(payload) as Partial<Intersection> | null;
      setIntersection(data ? normalizeIntersection(data) : undefined);
    },
    () => setIntersection(undefined),
  );

  return intersectionId ? intersection : undefined;
}

export default useSelectedIntersection;
