import type { TrainNextStationAppDto } from '@ce/web-shared';
import { Fragment } from 'react';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import RouteIcon from '@mui/icons-material/Route';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Stack from '@mui/material/Stack';
import type { SxProps, Theme } from '@mui/material/styles';
import Typography from '@mui/material/Typography';

function formatDeparture(entry: TrainNextStationAppDto) {
  if (entry.departureInMinutes <= 0) return '0 min';
  return `${entry.departureInMinutes} min`;
}

function TrainNextStationList({ nextStations }: { nextStations: TrainNextStationAppDto[] }) {
  if (nextStations.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary" sx={{ p: 2 }}>
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
              pl: 2,
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
          <Box sx={{ ...cellSx(index), pr: 2, minWidth: 0, justifyContent: 'flex-start' }}>
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

function TrainLineView(props: { line?: string; destination?: string; nextStations?: TrainNextStationAppDto[] }) {
  const rows = [
    { label: 'Linie', value: props.line ?? '-', icon: RouteIcon },
    { label: 'Ziel', value: props.destination ?? '-', icon: LocationOnIcon },
  ];

  return (
    <Stack spacing={0}>
      <List
        dense
        sx={{
          '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
        }}
      >
        {rows.map((row) => (
          <ListItem key={row.label} sx={{ alignItems: 'flex-start' }}>
            <ListItemIcon sx={{ mt: 0.5 }}>
              <row.icon />
            </ListItemIcon>
            <ListItemText primary={row.value} secondary={row.label} />
          </ListItem>
        ))}
      </List>
      <Divider />
      <Typography variant="subtitle2" sx={{ px: 2, pt: 2, pb: 1 }}>
        Nächste Stationen
      </Typography>
      <Divider />
      <TrainNextStationList nextStations={props.nextStations ?? []} />
    </Stack>
  );
}

export default TrainLineView;
