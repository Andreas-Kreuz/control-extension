import { ModuleAppDto, ModuleRoom } from '@ce/web-shared';
import { useCallback, useState } from 'react';
import { useDomainRoomHandler } from '../../shared/socket/useRoomHandler';

function useModuleAvailability(): { isModuleAvailable: (moduleId: string) => boolean } {
  const [modules, setModules] = useState<Record<string, ModuleAppDto>>({});

  useDomainRoomHandler(
    ModuleRoom,
    'ModuleRoom',
    (payload: string) => {
      const nextModules: Record<string, ModuleAppDto> = JSON.parse(payload);
      setModules(nextModules);
    },
    () => setModules({}),
  );

  const isModuleAvailable = useCallback((moduleId: string) => modules[moduleId]?.enabled === true, [modules]);

  return { isModuleAvailable };
}

export default useModuleAvailability;
