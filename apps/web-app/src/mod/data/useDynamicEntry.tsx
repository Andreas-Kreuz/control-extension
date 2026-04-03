import { useState } from 'react';
import { useDynamicRoomHandler } from '../../socket/useRoomHandler';
import { DynamicRoom } from '@ce/web-shared';

const noopRoom = new DynamicRoom('__noop__');

function useDynamicEntry(
  room: DynamicRoom | undefined,
  entryId: string,
): Record<string, unknown> | undefined {
  const [entry, setEntry] = useState<Record<string, unknown> | undefined>(undefined);

  useDynamicRoomHandler(
    room ?? noopRoom,
    entryId,
    (payload: string) => {
      const data = JSON.parse(payload) as Record<string, unknown> | null;
      setEntry(data ?? undefined);
    },
    () => setEntry(undefined),
  );

  return room ? entry : undefined;
}

export default useDynamicEntry;
