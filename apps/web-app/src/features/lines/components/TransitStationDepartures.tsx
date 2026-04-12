import { useMemo, useState } from 'react';
import type { TransitStationDto, TransitStationQueueEntryDto } from '@ce/web-shared';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Stack from '@mui/material/Stack';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import Typography from '@mui/material/Typography';

function formatDeparture(entry: TransitStationQueueEntryDto) {
  if (entry.timeInMinutes <= 0) return '0 min';
  return `${entry.timeInMinutes} min`;
}

function TransitStationDepartureList({
  departures,
  showPlatform,
}: {
  departures: TransitStationQueueEntryDto[];
  showPlatform: boolean;
}) {
  if (departures.length === 0) {
    return (
      <Typography variant="body2" color="text.secondary" sx={{ p: 2 }}>
        Keine Abfahrten vorhanden.
      </Typography>
    );
  }

  return (
    <List disablePadding>
      {departures.map((entry, index) => (
        <Box key={`${entry.trainName}-${entry.platform}-${index}`}>
          {index > 0 && <Divider />}
          <ListItem sx={{ py: 1.5 }}>
            <Box
              sx={{
                display: 'flex',
                alignItems: 'baseline',
                justifyContent: 'space-between',
                gap: 2,
                width: 1,
              }}
            >
              <Stack
                direction="row"
                spacing={1}
                sx={{ alignItems: 'baseline', minWidth: 0, flexGrow: 1 }}
              >
                <Typography component="span" fontWeight={600} sx={{ minWidth: '2.5rem', textAlign: 'right' }}>
                  {entry.line}
                </Typography>
                <Stack spacing={0.75} sx={{ minWidth: 0, alignSelf: 'flex-start' }}>
                  <Typography component="span" sx={{ minWidth: 0, wordBreak: 'break-word', lineHeight: 'inherit' }}>
                    {entry.destination}
                  </Typography>
                  {showPlatform && <Chip size="small" label={`Steig ${entry.platform}`} sx={{ width: 'fit-content' }} />}
                </Stack>
              </Stack>
              <Typography
                variant="body2"
                color="text.secondary"
                sx={{ flexShrink: 0, textAlign: 'right', whiteSpace: 'nowrap', minWidth: '3.5rem', lineHeight: 'inherit' }}
              >
                {formatDeparture(entry)}
              </Typography>
            </Box>
          </ListItem>
        </Box>
      ))}
    </List>
  );
}

function TransitStationDepartures({
  station,
}: {
  station: TransitStationDto;
}) {
  const [activeTab, setActiveTab] = useState(0);
  const queue = useMemo(
    () => [...(station.queue ?? [])].sort((left, right) => left.timeInMinutes - right.timeInMinutes),
    [station.queue],
  );
  const platformNumbers = useMemo(() => {
    const configuredPlatforms = (station.platforms ?? []).map((platform) => platform.nr);
    if (configuredPlatforms.length > 0) return configuredPlatforms;

    return [...new Set(queue.map((entry) => entry.platform))].sort((left, right) => left - right);
  }, [station.platforms, queue]);
  const tabs = [
    { key: 'all', label: 'Abfahrten', departures: queue, showPlatform: true },
    ...platformNumbers.map((platformNumber) => ({
      key: `platform-${platformNumber}`,
      label: `Steig ${platformNumber}`,
      departures: queue.filter((entry) => entry.platform === platformNumber),
      showPlatform: false,
    })),
  ];
  const safeTabIndex = Math.min(activeTab, tabs.length - 1);
  const selectedTab = tabs[safeTabIndex];

  return (
    <Stack spacing={0}>
      <Tabs
        value={safeTabIndex}
        onChange={(_event, value: number) => setActiveTab(value)}
        variant="scrollable"
        allowScrollButtonsMobile
        sx={{ minHeight: 44 }}
      >
        {tabs.map((tab) => (
          <Tab key={tab.key} label={tab.label} />
        ))}
      </Tabs>
      <Divider />
      {selectedTab && (
        <TransitStationDepartureList
          departures={selectedTab.departures}
          showPlatform={selectedTab.showPlatform}
        />
      )}
    </Stack>
  );
}

export default TransitStationDepartures;
