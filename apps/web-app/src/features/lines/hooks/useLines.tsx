import { TransitLineListRoom } from '@ce/web-shared';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import Line from '../model/Line';
import { useState } from 'react';

function useLines(): Line[] {
  const [lines, setLines] = useState<Line[]>([]);

  useDomainRoomHandler(TransitLineListRoom, 'All', (payload: string) => {
    const data: Line[] = JSON.parse(payload);
    setLines(data);
  });

  return lines;
}

export default useLines;
