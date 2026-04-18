import TerminalRoundedIcon from '@mui/icons-material/TerminalRounded';
import TrainRoundedIcon from '@mui/icons-material/TrainRounded';
import Box from '@mui/material/Box';
import useVersionStatus from '../../statistics/hooks/useVersionInfo';
import InsightsInfoList from './InsightsInfoList';

function InsightsVersionInfo() {
  const versions = useVersionStatus();

  return (
    <InsightsInfoList
      title="Versionen"
      description="Installierte Komponenten"
      items={[
        {
          icon: <Box component="img" alt="" src="/favicon.svg" sx={{ height: 20, width: 20 }} />,
          label: 'Control Extension',
          value: versions.appVersion,
        },
        {
          icon: <TrainRoundedIcon sx={{ fontSize: 20 }} />,
          label: 'EEP',
          value: versions.eepVersion,
        },
        {
          icon: <TerminalRoundedIcon sx={{ fontSize: 20 }} />,
          label: 'Lua',
          value: versions.luaVersion,
        },
      ]}
    />
  );
}

export default InsightsVersionInfo;
