import { useState } from 'react';
import { useApiDataRoomHandler } from '../../socket/useRoomHandler';
import { CeTypes, DataType } from '@ce/web-shared';

function useApiEntries(): DataType[] {
  const [entries, setEntries] = useState<DataType[]>([]);

  useApiDataRoomHandler(CeTypes.ServerApiEntries, (payload: string) => {
    const data: DataType[] = JSON.parse(payload);
    setEntries(data);
  });

  return entries;
}

export default useApiEntries;
