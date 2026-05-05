import type { TrainNextStationAppDto } from '@ce/web-shared';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import RouteIcon from '@mui/icons-material/Route';
import { Fragment } from 'react';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import List from '@mui/material/List';
import Stack from '@mui/material/Stack';
import type { SxProps, Theme } from '@mui/material/styles';
import Typography from '@mui/material/Typography';
import { IconListEntry } from '../../../../shared/components/iconlist';
import { FullBleedDivider } from '../../../../shared/components/sections';

function formatDeparture(entry: TrainNextStationAppDto) {
  if (entry.departureInMinutes <= 0) return '0 min';
  return `${entry.departureInMinutes} min`;
}

function TrainNextStationList({ nextStations }: { nextStations: TrainNextStationAppDto[] }) {
  if (nextStations.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary" sx={{ py: 2 }}>
        Keine nächsten Stationen vorhanden.
      </Typography>
    );
  }

  const cellSx = (index: number): SxProps<Theme> => ({
    borderTop: index > 0 ? '1px solid' : 0,
    borderColor: 'divider',
    display: 'flex',
    alignItems: 'center',
    py: 1.5,
  });

  return (
    <Box
      sx={{
        display: 'grid',
        gridTemplateColumns: 'minmax(0, 1fr) 3.5rem minmax(0, auto)',
        alignItems: 'stretch',
      }}
    >
      {nextStations.map((entry, index) => (
        <Fragment key={`${entry.station.name}-${entry.station.platform}-${index}`}>
          <Typography
            component="span"
            sx={{
              ...cellSx(index),
              minWidth: 0,
              wordBreak: 'break-word',
              lineHeight: 'inherit',
            }}
          >
            {entry.station.name}
          </Typography>
          <Typography
            component="span"
            variant="body2"
            color="textSecondary"
            sx={{
              ...cellSx(index),
              textAlign: 'right',
              justifyContent: 'flex-end',
              whiteSpace: 'nowrap',
              lineHeight: 'inherit',
              px: 1,
            }}
          >
            {formatDeparture(entry)}
          </Typography>
          <Box sx={{ ...cellSx(index), minWidth: 0, justifyContent: 'flex-start' }}>
            <Chip
              size="small"
              label={`Steig ${entry.station.platform}`}
              sx={{
                minWidth: 0,
                maxWidth: '100%',
                '& .MuiChip-label': {
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                },
              }}
            />
          </Box>
        </Fragment>
      ))}
    </Box>
  );
}

function TrainLinePanel(props: { line?: string; destination?: string; nextStations?: TrainNextStationAppDto[] }) {
  return (
    <Stack spacing={0}>
      <List
        dense
        disablePadding
        sx={{
          '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
        }}
      >
        <IconListEntry icon={<RouteIcon />} title="Linie" value={props.line ?? '-'} />
        <IconListEntry icon={<LocationOnIcon />} title="Ziel" value={props.destination ?? '-'} />
      </List>
      <FullBleedDivider />
      <Typography variant="subtitle2" sx={{ pt: 2, pb: 1 }}>
        Nächste Stationen
      </Typography>
      <FullBleedDivider />
      <TrainNextStationList nextStations={props.nextStations ?? []} />
    </Stack>
  );
}

export default TrainLinePanel;
