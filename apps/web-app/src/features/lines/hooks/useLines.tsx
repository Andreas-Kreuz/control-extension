import { CeTypes } from '@ce/web-shared';
import { useApiDataRoomHandler } from '../../../shared/socket/useRoomHandler';
import Line from '../model/Line';
import { useState } from 'react';

function useLines(): Line[] {
  const [lines, setLines] = useState<Line[]>([]);

  useApiDataRoomHandler(CeTypes.TransitLine, (payload: string) => {
    const data: Record<string, Line> = JSON.parse(payload);
    setLines(Object.values(data));
  });

  return lines;
}

export default useLines;
