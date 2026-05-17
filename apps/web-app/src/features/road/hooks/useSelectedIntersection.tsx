import { DomainRoom, IntersectionRoom } from '@ce/web-shared';
import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import type Intersection from '../model/Intersection';

const noopRoom = new DomainRoom('__noop__');

function normalizeIntersection(intersection: Partial<Intersection>): Intersection {
  return {
    id: intersection.id ?? 0,
    name: intersection.name ?? '',
    eepSaveId: intersection.eepSaveId ?? -1,
    ...(intersection.scriptVariableName !== undefined ? { scriptVariableName: intersection.scriptVariableName } : {}),
    switchInStrictOrder: intersection.switchInStrictOrder ?? false,
    greenTimeSeconds: intersection.greenTimeSeconds ?? 0,
    ready: intersection.ready ?? false,
    currentPhase: intersection.currentPhase ?? '',
    manualPhase: intersection.manualPhase ?? '',
    nextPhase: intersection.nextPhase ?? '',
    ...(intersection.tippStructure !== undefined ? { tippStructure: intersection.tippStructure } : {}),
    staticCams: intersection.staticCams ?? [],
    phases: intersection.phases ?? [],
    signalGroupDefinitions: intersection.signalGroupDefinitions ?? [],
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
