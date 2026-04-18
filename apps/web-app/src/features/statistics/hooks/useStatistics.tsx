import { useState } from 'react';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import TimeDesc from '../model/TimeDesc';
import { RuntimeStatisticsDto, RuntimeStatisticsRoom, RuntimeStatisticsTimeDto } from '@ce/web-shared';

function toTimeDescList(entries: RuntimeStatisticsTimeDto[] = []): TimeDesc[] {
  return entries.map((entry) => new TimeDesc(entry.id, entry.ms));
}

function toTimeDescHistory(entries: RuntimeStatisticsTimeDto[][] = []): TimeDesc[][] {
  return entries.map((sample) => toTimeDescList(sample));
}

function combineOverallTimes(
  publisherSyncTimes: TimeDesc[][],
  moduleRunTimes: TimeDesc[][],
  updateTimes: TimeDesc[][],
): TimeDesc[][] {
  const maxLength = Math.max(publisherSyncTimes.length, moduleRunTimes.length, updateTimes.length);
  const combined: TimeDesc[][] = [];

  for (let index = 0; index < maxLength; index += 1) {
    const discoveryEntries = (moduleRunTimes[index] ?? []).map((entry) => new TimeDesc(entry.id, entry.ms));
    const updaterEntries = (updateTimes[index] ?? []).map((entry) => new TimeDesc(entry.id, entry.ms));
    const publisherEntries = (publisherSyncTimes[index] ?? []).map(
      (entry) => new TimeDesc('Publisher/' + entry.id, entry.ms),
    );

    combined.push([...discoveryEntries, ...updaterEntries, ...publisherEntries]);
  }

  return combined;
}

function combineInitializationTimes(publisherInitTimes: TimeDesc[], moduleInitTimes: TimeDesc[]): TimeDesc[][] {
  const combined = [...moduleInitTimes, ...publisherInitTimes];

  return combined.length > 0 ? [combined] : [];
}

function toSingleSample(entries: TimeDesc[]): TimeDesc[][] {
  return entries.length > 0 ? [entries] : [];
}

function entriesWithPrefix(entries: TimeDesc[], prefix: string): TimeDesc[] {
  return entries.filter((entry) => entry.id.startsWith(prefix));
}

function entriesWithoutPrefix(entries: TimeDesc[], prefix: string): TimeDesc[] {
  return entries.filter((entry) => !entry.id.startsWith(prefix));
}

function useStatistics() {
  const [publisherSyncTimes, setPublisherSyncTimes] = useState<TimeDesc[][]>([]);
  const [publisherInitTimes, setPublisherInitTimes] = useState<TimeDesc[]>([]);
  const [moduleRunTimes, setModuleRunTimes] = useState<TimeDesc[][]>([]);
  const [updateTimes, setUpdateTimes] = useState<TimeDesc[][]>([]);
  const [moduleInitTimes, setModuleInitTimes] = useState<TimeDesc[]>([]);
  const [controllerUpdateTimes, setControllerUpdateTimes] = useState<TimeDesc[][]>([]);

  useDomainRoomHandler(
    RuntimeStatisticsRoom,
    'RuntimeStatisticsRoom',
    (payload: string) => {
      const statistics: RuntimeStatisticsDto = JSON.parse(payload);

      setPublisherSyncTimes(toTimeDescHistory(statistics.history?.publisherSyncTimes));
      setPublisherInitTimes(toTimeDescList(statistics.initialization?.publisherInitTimes));
      setModuleRunTimes(toTimeDescHistory(statistics.history?.moduleRunTimes));
      setUpdateTimes(toTimeDescHistory(statistics.history?.updateTimes));
      setModuleInitTimes(toTimeDescList(statistics.initialization?.moduleInitTimes));
      setControllerUpdateTimes(toTimeDescHistory(statistics.history?.controllerUpdateTimes));
    },
    () => {
      setPublisherSyncTimes([]);
      setPublisherInitTimes([]);
      setControllerUpdateTimes([]);
      setUpdateTimes([]);
      setModuleInitTimes([]);
      setModuleRunTimes([]);
    },
  );

  return {
    overallTimes: combineOverallTimes(publisherSyncTimes, moduleRunTimes, updateTimes),
    initializationTimes: combineInitializationTimes(publisherInitTimes, moduleInitTimes),
    discoveryTimes: moduleRunTimes,
    discoveryInitializationTimes: toSingleSample(moduleInitTimes),
    updateTimes,
    updateInitializationTimes: toSingleSample(entriesWithPrefix(publisherInitTimes, 'Update-init/')),
    publisherTimes: publisherSyncTimes,
    publisherInitializationTimes: toSingleSample(entriesWithoutPrefix(publisherInitTimes, 'Update-init/')),
    controllerUpdateTimes,
  };
}

export default useStatistics;
