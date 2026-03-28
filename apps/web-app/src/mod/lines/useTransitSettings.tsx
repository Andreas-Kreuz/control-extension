import { CeTypes, SettingDto, SettingsDto } from '@ak/web-shared';
import { useApiDataRoomHandler } from '../../io/useRoomHandler';

import { useState } from 'react';
import useDebug from '../../io/useDebug';

function useIntersectionSettings(): SettingsDto | undefined {
  const [settings, setSettings] = useState<SettingsDto | undefined>(undefined);
  const debug = useDebug();

  useApiDataRoomHandler(CeTypes.TransitModuleSetting, (payload: string) => {
    const data: SettingDto<any>[] = Object.values(JSON.parse(payload));
    const mySettings = {
      moduleName: 'Einstellungen für ÖPNV',
      settings: data,
    };
    if (debug) console.log('                 |⚠️ FIRED ---', 'API: ' + CeTypes.TransitModuleSetting, mySettings);
    setSettings(mySettings);
  });

  return settings;
}

export default useIntersectionSettings;
