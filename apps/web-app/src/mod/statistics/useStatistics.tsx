import { useState } from 'react';
import { useDynamicRoomHandler } from '../../io/useRoomHandler';
import TimeDesc from './model/TimeDesc';
import { RuntimeStatisticsDto, RuntimeStatisticsRoom, RuntimeStatisticsTimeDto } from '@ce/web-shared';

function toTimeDescList(entries: RuntimeStatisticsTimeDto[] = []): TimeDesc[] {
  return entries.map((entry) => new TimeDesc(entry.id, entry.ms));
}

function toTimeDescHistory(entries: RuntimeStatisticsTimeDto[][] = []): TimeDesc[][] {
  return entries.map((sample) => toTimeDescList(sample));
}

function useStatistics() {
  const [publisherSyncTimes, setPublisherSyncTimes] = useState<TimeDesc[][]>([]);
  const [publisherInitTimes, setPublisherInitTimes] = useState<TimeDesc[]>([]);
  const [moduleRunTimes, setModuleRunTimes] = useState<TimeDesc[][]>([]);
  const [moduleInitTimes, setModuleInitTimes] = useState<TimeDesc[]>([]);
  const [controllerUpdateTimes, setControllerUpdateTimes] = useState<TimeDesc[][]>([]);

  useDynamicRoomHandler(
    RuntimeStatisticsRoom,
    'RuntimeStatisticsRoom',
    (payload: string) => {
      const statistics: RuntimeStatisticsDto = JSON.parse(payload);

      setPublisherSyncTimes(toTimeDescHistory(statistics.history?.publisherSyncTimes));
      setPublisherInitTimes(toTimeDescList(statistics.initialization?.publisherInitTimes));
      setModuleRunTimes(toTimeDescHistory(statistics.history?.moduleRunTimes));
      setModuleInitTimes(toTimeDescList(statistics.initialization?.moduleInitTimes));
      setControllerUpdateTimes(toTimeDescHistory(statistics.history?.controllerUpdateTimes));
    },
    () => {
      setPublisherSyncTimes([]);
      setPublisherInitTimes([]);
      setControllerUpdateTimes([]);
      setModuleInitTimes([]);
      setModuleRunTimes([]);
    },
  );

  return {
    publisherSyncTimes,
    publisherInitTimes,
    controllerUpdateTimes,
    moduleInitTimes,
    moduleRunTimes,
  };
}

export default useStatistics;

