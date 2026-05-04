import { TransitSettingsRoom, SettingsAppDto } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

import { useState } from 'react';
import useDebug from '../../../shared/socket/useDebug';

function useIntersectionSettings(): SettingsAppDto | undefined {
  const [settings, setSettings] = useState<SettingsAppDto | undefined>(undefined);
  const debug = useDebug();

  useDomainRoomHandler(TransitSettingsRoom, 'All', (payload: string) => {
    const data = JSON.parse(payload) as SettingsAppDto;
    if (debug) console.log('                 |⚠️ FIRED ---', 'TransitSettingsRoom', data);
    setSettings(data);
  });

  return settings;
}

export default useIntersectionSettings;
