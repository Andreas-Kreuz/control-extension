import { RoadSettingsRoom, SettingsAppDto } from '@ce/web-shared';
import useDebug from '../../../shared/socket/useDebug';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import { useState } from 'react';

function useIntersectionSettings(): SettingsAppDto | undefined {
  const [settings, setSettings] = useState<SettingsAppDto | undefined>(undefined);
  const debug = useDebug();

  useDomainRoomHandler(RoadSettingsRoom, 'All', (payload: string) => {
    const data = JSON.parse(payload) as SettingsAppDto;
    if (debug) console.log('                 |⚠️ FIRED ---', 'RoadSettingsRoom', data);
    setSettings(data);
  });

  return settings;
}

export default useIntersectionSettings;
