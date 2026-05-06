import { useState } from 'react';
import { VersionAppDto, VersionRoom } from '@ce/web-shared';
import { useDomainRoomHandler } from '../socket/useRoomHandler';
import Versions from '../lib/Versions';

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
    const data: Record<string, VersionAppDto> = JSON.parse(payload);
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
