import { ScenarioAppDto, ScenarioRoom } from '@ce/web-shared';
import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

function useSelectedScenario(): ScenarioAppDto | undefined {
  const [scenario, setScenario] = useState<ScenarioAppDto | undefined>(undefined);

  useDomainRoomHandler(
    ScenarioRoom,
    'current',
    (payload: string) => {
      const data = JSON.parse(payload) as Record<string, ScenarioAppDto>;
      setScenario(Object.values(data)[0]);
    },
    () => setScenario(undefined),
  );

  return scenario;
}

export default useSelectedScenario;
