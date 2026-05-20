import { useEffect, useState } from 'react';
import IntersectionPhase from '../model/IntersectionPhase';
import useIntersectionPhases from './useIntersectionPhases';

function useIntersectionPhase(id: string | undefined): IntersectionPhase[] {
  const allPhases = useIntersectionPhases();
  const [phases, setPhases] = useState<IntersectionPhase[]>([]);

  useEffect(() => {
    setPhases(
      allPhases
        .filter((is: IntersectionPhase) => id === is.intersectionId)
        .sort((a, b) => a.name.localeCompare(b.name)),
    );
  }, [allPhases, id]);

  return phases;
}

export default useIntersectionPhase;
