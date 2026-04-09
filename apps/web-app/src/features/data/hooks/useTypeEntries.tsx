import { useState } from 'react';
import { useApiDataRoomHandler } from '../../../shared/socket/useRoomHandler';

type EntryMap = Record<string, Record<string, unknown>>;

function useTypeEntries(ceType: string): EntryMap {
  const [entries, setEntries] = useState<EntryMap>({});

  useApiDataRoomHandler(ceType, (payload: string) => {
    const data: EntryMap = JSON.parse(payload);
    setEntries(data);
  });

  return entries;
}

export default useTypeEntries;

