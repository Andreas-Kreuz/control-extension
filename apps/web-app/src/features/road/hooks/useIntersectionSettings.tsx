import { RoadSettingsRoom, SettingAppDto, SettingsAppDto } from '@ce/web-shared';
import useDebug from '../../../shared/socket/useDebug';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import { useState } from 'react';

function useIntersectionSettings(): SettingsAppDto | undefined {
  const [settings, setSettings] = useState<SettingsAppDto | undefined>(undefined);
  const debug = useDebug();

  useDomainRoomHandler(RoadSettingsRoom, 'All', (payload: string) => {
    const data: SettingAppDto<any>[] = Object.values(JSON.parse(payload));
    const mySettings = {
      moduleName: 'Einstellungen für Kreuzungen',
      settings: data,
    };
    if (debug) console.log('                 |⚠️ FIRED ---', 'RoadSettingsRoom', mySettings);
    setSettings(mySettings);
  });

  return settings;
}

export default useIntersectionSettings;
