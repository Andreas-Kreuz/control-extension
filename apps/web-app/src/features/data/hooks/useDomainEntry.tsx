import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import { CeTypeRoom } from '@ce/web-shared';

const noopRoom = new CeTypeRoom('__noop__');

function useDomainEntry(room: CeTypeRoom | undefined, entryId: string): Record<string, unknown> | undefined {
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
