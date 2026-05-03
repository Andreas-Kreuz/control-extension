import { useState, SetStateAction } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import { ServerStatsRoom, ServerStatsAppDto } from '@ce/web-shared';

export function useServerStatus(): [SetStateAction<boolean>, SetStateAction<boolean>, SetStateAction<number>] {
  const [eepDataUpToDate, setEepDataUpToDate] = useState(false);
  const [luaDataReceived, setLuaDataReceived] = useState(false);
  const [apiEntryCount, setApiEntryCount] = useState(0);

  useDomainRoomHandler(ServerStatsRoom, 'ServerStats', (payload: string) => {
    const data: ServerStatsAppDto = JSON.parse(payload);
    setEepDataUpToDate(data.eepDataUpToDate);
    setLuaDataReceived(data.luaDataReceived);
    setApiEntryCount(data.apiEntryCount);
  });

  return [eepDataUpToDate, luaDataReceived, apiEntryCount];
}
