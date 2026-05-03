import DownloadRoundedIcon from '@mui/icons-material/DownloadRounded';
import TerminalRoundedIcon from '@mui/icons-material/TerminalRounded';
import TrainRoundedIcon from '@mui/icons-material/TrainRounded';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Tooltip from '@mui/material/Tooltip';
import { Link as RouterLink } from 'react-router-dom';
import useVersionStatus from '../../statistics/hooks/useVersionInfo';
import useUpdateStatus from '../../update/hooks/useUpdateStatus';
import type Versions from '../../statistics/lib/Versions';
import InsightsInfoList from './InsightsInfoList';

function displayVersion(version: string) {
  return version.startsWith('v') ? version : `v${version}`;
}

function UpdateVersionChip(props: { version: string }) {
  const version = displayVersion(props.version);

  return (
    <Tooltip title={`Update ${version} ist verfügbar`}>
      <Chip
        clickable
        color="success"
        component={RouterLink}
        icon={<DownloadRoundedIcon />}
        label={version}
        size="small"
        variant="filled"
        sx={{
          bgcolor: 'success.main',
          color: 'success.contrastText',
          height: 22,
          '& .MuiChip-icon': { color: 'inherit', fontSize: 16 },
          '& .MuiChip-label': { px: 0.75 },
        }}
        to="/about"
      />
    </Tooltip>
  );
}

export function InsightsVersionInfoContent(props: {
  versions: Versions;
  updateAvailable?: boolean;
  availableUpdateVersion?: string;
}) {
  const showUpdateChip = props.updateAvailable === true && props.availableUpdateVersion !== undefined;

  return (
    <InsightsInfoList
      title="Versionen"
      description="Installierte Komponenten"
      items={[
        {
          icon: <TerminalRoundedIcon sx={{ fontSize: 20 }} />,
          label: 'Lua',
          value: props.versions.luaVersion,
        },
        {
          icon: <TrainRoundedIcon sx={{ fontSize: 20 }} />,
          label: 'EEP',
          value: props.versions.eepVersion,
        },
        {
          icon: <Box component="img" alt="" src="/favicon.svg" sx={{ height: 20, width: 20 }} />,
          label: 'Control Extension',
          value: props.versions.appVersion,
          valuePrefix: showUpdateChip ? <UpdateVersionChip version={props.availableUpdateVersion} /> : undefined,
        },
      ]}
    />
  );
}

function InsightsVersionInfo() {
  const versions = useVersionStatus();
  const updateStatus = useUpdateStatus();
  const updateAvailable = updateStatus.state === 'stable-available' || updateStatus.state === 'prerelease-available';
  const availableUpdateVersion =
    updateStatus.availableRelease?.version ?? updateStatus.availablePrereleaseRelease?.version;

  return (
    <InsightsVersionInfoContent
      availableUpdateVersion={availableUpdateVersion}
      updateAvailable={updateAvailable}
      versions={versions}
    />
  );
}

export default InsightsVersionInfo;
