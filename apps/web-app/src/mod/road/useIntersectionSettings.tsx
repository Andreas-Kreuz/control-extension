import { CeTypes, SettingDto, SettingsDto } from '@ce/web-shared';
import useDebug from '../../socket/useDebug';
import { useApiDataRoomHandler } from '../../socket/useRoomHandler';
import Intersection from './model/Intersection';
import { useState } from 'react';

function useIntersectionSettings(): SettingsDto | undefined {
  const [settings, setSettings] = useState<SettingsDto | undefined>(undefined);
  const debug = useDebug();

  useApiDataRoomHandler(CeTypes.RoadModuleSetting, (payload: string) => {
    const data: SettingDto<any>[] = Object.values(JSON.parse(payload));
    const mySettings = {
      moduleName: 'Einstellungen für Kreuzungen',
      settings: data,
    };
    if (debug) console.log('                 |⚠️ FIRED ---', 'API: ' + CeTypes.RoadModuleSetting, mySettings);
    setSettings(mySettings);
  });

  return settings;
}

export default useIntersectionSettings;

