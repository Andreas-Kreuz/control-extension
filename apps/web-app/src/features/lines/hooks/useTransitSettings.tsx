import { TransitSettingsRoom, SettingAppDto, SettingsAppDto } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';

import { useState } from 'react';
import useDebug from '../../../shared/socket/useDebug';

function useIntersectionSettings(): SettingsAppDto | undefined {
  const [settings, setSettings] = useState<SettingsAppDto | undefined>(undefined);
  const debug = useDebug();

  useDomainRoomHandler(TransitSettingsRoom, 'All', (payload: string) => {
    const data: SettingAppDto<any>[] = Object.values(JSON.parse(payload));
    const mySettings = {
      moduleName: 'Einstellungen für ÖPNV',
      settings: data,
    };
    if (debug) console.log('                 |⚠️ FIRED ---', 'TransitSettingsRoom', mySettings);
    setSettings(mySettings);
  });

  return settings;
}

export default useIntersectionSettings;
