import CableRoundedIcon from '@mui/icons-material/CableRounded';
import CheckIcon from '@mui/icons-material/Check';
import DnsRoundedIcon from '@mui/icons-material/DnsRounded';
import LinkOffRoundedIcon from '@mui/icons-material/LinkOffRounded';
import PauseRoundedIcon from '@mui/icons-material/PauseRounded';
import TrainRoundedIcon from '@mui/icons-material/TrainRounded';
import Box from '@mui/material/Box';
import { ReactNode } from 'react';
import { useSocketIsConnected } from '../../../app/hooks/useSocketConnection';
import { useServerStatus } from '../../status/hooks/useServerInfo';
import InsightsInfoList from './InsightsInfoList';

type ComponentIcon = 'eep' | 'bridge' | 'server';
type BadgeIcon = 'ok' | 'paused' | 'disconnected';
type BadgeColor = 'success' | 'warning' | 'error';

interface InsightsStatusInfoItem {
  label: string;
  detail: string;
  statusText: string;
  componentIcon: ComponentIcon;
  badgeIcon: BadgeIcon;
}

function getComponentIcon(icon: ComponentIcon, sx: { fontSize: number }): ReactNode {
  if (icon === 'eep') {
    return <TrainRoundedIcon sx={sx} />;
  }

  if (icon === 'bridge') {
    return <CableRoundedIcon sx={sx} />;
  }

  return <DnsRoundedIcon sx={sx} />;
}

function getBadgeColor(icon: BadgeIcon): BadgeColor {
  if (icon === 'ok') {
    return 'success';
  }

  if (icon === 'paused') {
    return 'warning';
  }

  return 'error';
}

function getBadgeIcon(icon: BadgeIcon): ReactNode {
  const iconSx = { fontSize: 13 };

  if (icon === 'ok') {
    return <CheckIcon sx={iconSx} />;
  }

  if (icon === 'paused') {
    return <PauseRoundedIcon sx={iconSx} />;
  }

  return <LinkOffRoundedIcon sx={iconSx} />;
}

function StatusBadge(props: { icon: BadgeIcon }) {
  const badgeColor = getBadgeColor(props.icon);

  return (
    <Box
      sx={{
        alignItems: 'center',
        bgcolor: badgeColor + '.main',
        borderRadius: '50%',
        color: '#ffffff',
        display: 'flex',
        flex: '0 0 auto',
        height: 18,
        justifyContent: 'center',
        width: 18,
      }}
    >
      {getBadgeIcon(props.icon)}
    </Box>
  );
}

function InsightsStatusInfo() {
  const isConnected = useSocketIsConnected();
  const [eepDataUpToDate, luaDataReceived, apiEntryCount] = useServerStatus();

  const items: InsightsStatusInfoItem[] = [
    {
      label: 'EEP',
      detail: isConnected ? (eepDataUpToDate ? 'OK' : 'Daten nicht aktuell') : 'Server nicht erreichbar',
      statusText: isConnected ? (eepDataUpToDate ? 'OK' : 'Pausiert') : 'Nicht verbunden',
      componentIcon: 'eep',
      badgeIcon: isConnected ? (eepDataUpToDate ? 'ok' : 'paused') : 'disconnected',
    },
    {
      label: 'Bridge',
      detail: isConnected
        ? luaDataReceived
          ? 'Stellt ' + apiEntryCount + ' verschiedene Informationen zur Verfügung'
          : 'Keine Daten empfangen'
        : 'Server nicht erreichbar',
      statusText: isConnected ? (luaDataReceived ? 'OK' : 'Keine Daten') : 'Nicht verbunden',
      componentIcon: 'bridge',
      badgeIcon: isConnected ? (luaDataReceived ? 'ok' : 'paused') : 'disconnected',
    },
    {
      label: 'Server',
      detail: isConnected ? 'OK' : 'Server nicht erreichbar',
      statusText: isConnected ? 'OK' : 'Nicht verbunden',
      componentIcon: 'server',
      badgeIcon: isConnected ? 'ok' : 'disconnected',
    },
  ];

  return (
    <InsightsInfoList
      title="Status"
      description="Verbindungszustand"
      items={items.map((item) => ({
        icon: getComponentIcon(item.componentIcon, { fontSize: 20 }),
        label: item.label,
        tooltip: `${item.label}: ${item.detail}`,
        value: item.statusText,
        valueIcon: <StatusBadge icon={item.badgeIcon} />,
      }))}
    />
  );
}

export default InsightsStatusInfo;
