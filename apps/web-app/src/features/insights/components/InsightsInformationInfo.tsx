import ExtensionRoundedIcon from '@mui/icons-material/ExtensionRounded';
import SpeedRoundedIcon from '@mui/icons-material/SpeedRounded';
import StorageRoundedIcon from '@mui/icons-material/StorageRounded';
import { ModuleDto, ModuleRoom } from '@ce/web-shared';
import { useState } from 'react';
import { useServerStatus } from '../../status/hooks/useServerInfo';
import TimeDesc from '../../statistics/model/TimeDesc';
import { useDomainRoomHandler } from '../../../shared/socket/useRoomHandler';
import InsightsInfoList from './InsightsInfoList';

function sumTimeDescMs(entries: TimeDesc[]): number {
  return entries.reduce((sum, entry) => sum + entry.ms, 0);
}

function formatMs(ms: number | undefined): string {
  if (ms === undefined) {
    return '-';
  }

  return `${Math.round(ms)} ms`;
}

function useModuleCount(): number | undefined {
  const [moduleCount, setModuleCount] = useState<number>();

  useDomainRoomHandler(
    ModuleRoom,
    'ModuleRoom',
    (payload: string) => {
      const modules: Record<string, ModuleDto> = JSON.parse(payload);
      setModuleCount(Object.keys(modules).length);
    },
    () => setModuleCount(undefined),
  );

  return moduleCount;
}

function InsightsInformationInfo(props: { updateTimes: TimeDesc[][] }) {
  const [, luaDataReceived, apiEntryCount] = useServerStatus();
  const moduleCount = useModuleCount();
  const maxUpdateTime = props.updateTimes.length
    ? Math.max(...props.updateTimes.map((sample) => sumTimeDescMs(sample)))
    : undefined;

  return (
    <InsightsInfoList
      title="Informationen"
      description="Datenbestand und Laufzeit"
      items={[
        {
          icon: <StorageRoundedIcon sx={{ fontSize: 20 }} />,
          label: 'Daten',
          value: luaDataReceived ? String(apiEntryCount) : '-',
          href: '/data',
        },
        {
          icon: <ExtensionRoundedIcon sx={{ fontSize: 20 }} />,
          label: 'Module',
          value: moduleCount === undefined ? '-' : String(moduleCount),
        },
        {
          icon: <SpeedRoundedIcon sx={{ fontSize: 20 }} />,
          label: 'Max Update time',
          value: formatMs(maxUpdateTime),
        },
      ]}
    />
  );
}

export default InsightsInformationInfo;
