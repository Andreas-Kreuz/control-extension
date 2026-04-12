import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import { DomainRoom } from '@ce/web-shared';

const noopRoom = new DomainRoom('__noop__');

function useDomainEntry(room: DomainRoom | undefined, entryId: string): Record<string, unknown> | undefined {
  const [entry, setEntry] = useState<Record<string, unknown> | undefined>(undefined);

  useDomainRoomHandler(
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

export default useDomainEntry;
