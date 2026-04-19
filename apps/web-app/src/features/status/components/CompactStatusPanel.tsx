import CableRoundedIcon from '@mui/icons-material/CableRounded';
import CheckIcon from '@mui/icons-material/Check';
import DnsRoundedIcon from '@mui/icons-material/DnsRounded';
import LinkOffRoundedIcon from '@mui/icons-material/LinkOffRounded';
import PauseRoundedIcon from '@mui/icons-material/PauseRounded';
import TrainRoundedIcon from '@mui/icons-material/TrainRounded';
import Badge from '@mui/material/Badge';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import { ReactNode } from 'react';
import { useSocketIsConnected } from '../../../app/hooks/useSocketConnection';
import { useServerStatus } from '../hooks/useServerInfo';

type ComponentIcon = 'eep' | 'bridge' | 'server';
type BadgeIcon = 'ok' | 'paused' | 'disconnected';
type BadgeColor = 'success' | 'warning' | 'error';

interface CompactStatusPanelItem {
  label: string;
  detail: string;
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
  const badgeColor = getBadgeColor(icon);

  if (icon === 'ok') {
    return (
      <Box
        sx={{
          alignItems: 'center',
          bgcolor: badgeColor + '.main',
          borderRadius: '50%',
          color: '#ffffff',
          display: 'flex',
          height: 18,
          justifyContent: 'center',
          width: 18,
        }}
      >
        <CheckIcon sx={iconSx} />
      </Box>
    );
  }

  if (icon === 'paused') {
    return (
      <Box
        sx={{
          alignItems: 'center',
          bgcolor: badgeColor + '.main',
          borderRadius: '50%',
          color: '#ffffff',
          display: 'flex',
          height: 18,
          justifyContent: 'center',
          width: 18,
        }}
      >
        <PauseRoundedIcon sx={iconSx} />
      </Box>
    );
  }

  return (
    <Box
      sx={{
        alignItems: 'center',
        bgcolor: badgeColor + '.main',
        borderRadius: '50%',
        color: '#ffffff',
        display: 'flex',
        height: 18,
        justifyContent: 'center',
        width: 18,
      }}
    >
      <LinkOffRoundedIcon sx={iconSx} />
    </Box>
  );
}

function StatusIconNode(props: CompactStatusPanelItem) {
  return (
    <Tooltip title={`${props.label}: ${props.detail}`}>
      <Badge
        aria-label={`${props.label}: ${props.detail}`}
        anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
        badgeContent={getBadgeIcon(props.badgeIcon)}
        overlap="circular"
        sx={{
          '& .MuiBadge-badge': {
            bgcolor: 'transparent',
            height: 18,
            minWidth: 18,
            p: 0,
            right: 3,
            top: 3,
          },
        }}
      >
        <Box
          sx={{
            alignItems: 'center',
            bgcolor: 'background.paper',
            border: 1,
            borderColor: 'divider',
            borderRadius: '50%',
            color: 'text.primary',
            display: 'flex',
            flex: '0 0 auto',
            height: 36,
            justifyContent: 'center',
            width: 36,
          }}
        >
          {getComponentIcon(props.componentIcon, { fontSize: 22 })}
        </Box>
      </Badge>
    </Tooltip>
  );
}

function StatusConnector() {
  return <Box sx={{ bgcolor: 'divider', flex: '0 0 24px', height: 2 }} />;
}

function CompactStatusPanel() {
  const isConnected = useSocketIsConnected();
  const [eepDataUpToDate, luaDataReceived, apiEntryCount] = useServerStatus();

  const items: CompactStatusPanelItem[] = [
    {
      label: 'EEP sendet Daten',
      detail: isConnected ? (eepDataUpToDate ? 'OK' : 'Daten nicht aktuell') : 'Server nicht erreichbar',
      componentIcon: 'eep',
      badgeIcon: isConnected ? (eepDataUpToDate ? 'ok' : 'paused') : 'disconnected',
    },
    {
      label: 'Data-Bridge hat Daten',
      detail: isConnected
        ? luaDataReceived
          ? 'Stellt ' + apiEntryCount + ' verschiedene Informationen zur Verfügung'
          : 'Keine Daten empfangen'
        : 'Server nicht erreichbar',
      componentIcon: 'bridge',
      badgeIcon: isConnected ? (luaDataReceived ? 'ok' : 'paused') : 'disconnected',
    },
    {
      label: 'Web-Server verbunden',
      detail: isConnected ? 'OK' : 'Server nicht erreichbar',
      componentIcon: 'server',
      badgeIcon: isConnected ? 'ok' : 'disconnected',
    },
  ];

  return (
    <Box
      sx={{
        alignItems: 'center',
        border: 1,
        borderColor: 'divider',
        borderRadius: 1,
        display: 'inline-flex',
        px: 1.5,
        py: 1,
      }}
    >
      <Stack direction="row" sx={{ alignItems: 'center' }}>
        {items.map((item, index) => (
          <Stack key={item.label} direction="row" sx={{ alignItems: 'center' }}>
            {index > 0 && <StatusConnector />}
            <StatusIconNode {...item} />
          </Stack>
        ))}
      </Stack>
    </Box>
  );
}

export default CompactStatusPanel;
