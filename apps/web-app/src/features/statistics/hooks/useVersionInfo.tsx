import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import Versions from '../lib/Versions';
import { VersionRoom, VersionDto } from '@ce/web-shared';

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

  useDomainRoomHandler(VersionRoom, 'VersionRoom', (payload: string) => {
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
