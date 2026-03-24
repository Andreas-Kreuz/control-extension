import { useState } from 'react';
import { useDynamicRoomHandler } from '../../io/useRoomHandler';
import Versions from './Versions';
import { VersionRoom, VersionDto } from '@ak/web-shared';

function cutOutLua(versionString: string) {
  if (versionString && versionString.startsWith('Lua ')) {
    return versionString.substring('Lua '.length);
  }
  return versionString;
}

export default function useVersionInfo(): Versions {
  const [versions, setVersions] = useState<Versions>({
    appVersion: '?',
    eepVersion: '?',
    luaVersion: '?',
  });

  useDynamicRoomHandler(VersionRoom, 'VersionRoom', (payload: string) => {
    const data: Record<string, VersionDto> = JSON.parse(payload);
    if (data.versionInfo) {
      setVersions({
        appVersion: data.versionInfo.singleVersion,
        eepVersion: data.versionInfo.eepVersion,
        luaVersion: cutOutLua(data.versionInfo.luaVersion),
      });
    }
  });

  return versions;
}
