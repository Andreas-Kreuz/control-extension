import { useState } from 'react';
import { useApiDataRoomHandler } from '../../../shared/socket/useRoomHandler';
import { DataType } from '@ce/web-shared';

const serverApiEntriesName = 'server.api-entries';

function useApiEntries(): DataType[] {
  const [entries, setEntries] = useState<DataType[]>([]);

  useApiDataRoomHandler(serverApiEntriesName, (payload: string) => {
    const data: DataType[] = JSON.parse(payload);
    setEntries(data);
  });

  return entries;
}

export default useApiEntries;
