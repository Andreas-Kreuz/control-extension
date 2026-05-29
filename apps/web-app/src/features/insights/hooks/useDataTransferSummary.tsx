import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import { DataTransferSummaryAppDto, DataTransferSummaryRoom } from '@ce/web-shared';

const dataTransferSummaryRoomId = 'DataTransferSummary';

const emptySummary: DataTransferSummaryAppDto = {
  eventCounter: 0,
  ceTypes: [],
};

function useDataTransferSummary(): DataTransferSummaryAppDto {
  const [summary, setSummary] = useState<DataTransferSummaryAppDto>(emptySummary);

  useDomainRoomHandler(
    DataTransferSummaryRoom,
    dataTransferSummaryRoomId,
    (payload: string) => {
      setSummary(JSON.parse(payload));
    },
    () => {
      setSummary(emptySummary);
    },
  );

  return summary;
}

export default useDataTransferSummary;
