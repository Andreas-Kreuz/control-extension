import { lazy, useState } from 'react';
import { TrackType } from '@ce/web-shared';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardActions from '@mui/material/CardActions';
import Chip from '@mui/material/Chip';
import Grid from '@mui/material/Grid';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { styled, useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';
import setTrackType from '../hooks/useSetTrackType';
import useTrackType from '../hooks/useTrackType';
import useTrains from '../hooks/useTrains';

const AppCardGridContainer = lazy(() => import('../../../shared/ui/AppCardGridContainer'));
const AppPageHeadline = lazy(() => import('../../../shared/ui/AppPageHeadline'));
const AppPage = lazy(() => import('../../../shared/ui/AppPage'));
const TrainListEntryCard = lazy(() => import('./TrainListEntryCard'));

interface ChipData {
  key: TrackType;
  label: string;
}

const ListItem = styled('li')(({ theme }) => ({
  margin: theme.spacing(0.5),
}));

const TrainsPage = () => {
  const trains = useTrains();
  const trackType = useTrackType();
  const setType = setTrackType();
  const theme = useTheme();
  const showNameFilter = useMediaQuery(theme.breakpoints.up('md'));
  const [nameFilter, setNameFilter] = useState('');

  const [chipData] = useState<readonly ChipData[]>([
    { key: TrackType.Rail, label: 'Gleise' },
    { key: TrackType.Tram, label: 'Straßenbahn' },
    { key: TrackType.Road, label: 'Straße' },
    { key: TrackType.Auxiliary, label: 'Sonstige Splines' },
    { key: TrackType.Control, label: 'Steuerstrecken' },
  ]);
  const selectedTrackLabel = chipData.find((entry) => entry.key === trackType)?.label;
  const normalizedNameFilter = nameFilter.trim().toLocaleLowerCase();
  const filteredTrains = trains.filter((train) => train.name.toLocaleLowerCase().includes(normalizedNameFilter));

  return (
    <AppPage>
      <AppPageHeadline>Gleissystem</AppPageHeadline>
      <Box
        sx={{
          display: 'flex',
          alignItems: 'center',
          flexWrap: 'wrap',
          listStyle: 'none',
          p: 0.5,
          m: 0,
        }}
      >
        {showNameFilter && (
          <Box sx={{ px: 0.5, py: 0.5, mr: 1, minWidth: 240 }}>
            <TextField
              size="small"
              label="Zugname filtern"
              value={nameFilter}
              onChange={(event) => setNameFilter(event.target.value)}
              fullWidth
            />
          </Box>
        )}
        <Box
          component="ul"
          sx={{
            display: 'flex',
            justifyContent: { xs: 'center', md: 'flex-start' },
            flexWrap: 'wrap',
            listStyle: 'none',
            p: 0,
            m: 0,
            flexGrow: 1,
          }}
        >
          {chipData.map((data) => (
            <ListItem key={data.key}>
              <Chip
                label={data.label}
                variant="filled"
                color={trackType === data.key ? 'primary' : 'default'}
                onClick={() => setType(data.key)}
              />
            </ListItem>
          ))}
        </Box>
      </Box>
      <AppCardGridContainer>
        <AppPageHeadline gutterTop>Fahrzeuge {selectedTrackLabel}</AppPageHeadline>
        {filteredTrains.length === 0 ? (
          <Grid size={{ xs: 12 }}>
            <Typography variant="body2">
              {normalizedNameFilter
                ? `Es wurden keine Fahrzeuge mit dem Namen "${nameFilter}" im Gleissystem ${selectedTrackLabel} gefunden.`
                : `Es wurden keine Fahrzeuge im Gleissystem ${selectedTrackLabel} gefunden. Wähle ein anderes Gleissystem oder füge Fahrzeuge in EEP hinzu.`}
            </Typography>
          </Grid>
        ) : (
          <>
            {filteredTrains.map((train) => (
              <Grid size={{ xs: 12 }} key={train.id}>
                <TrainListEntryCard train={train} />
              </Grid>
            ))}
          </>
        )}
      </AppCardGridContainer>

      <AppPageHeadline gutterTop>Hilfe</AppPageHeadline>
      <AppCardGridContainer>
        <Grid size={{ xs: 12 }}>
          <Card>
            <CardActionArea sx={{ p: 2 }} disabled>
              <Typography variant="h5" gutterBottom>
                Hilfe
              </Typography>
              <Typography variant="body2">Erfahre, wie Du Fahrzeuge verwalten kannst.</Typography>
            </CardActionArea>
            <CardActions>
              <Button
                href="https://andreas-kreuz.github.io/control-extension/docs/anleitungen/"
                target="_blank"
                rel="noopener noreferrer"
              >
                Anleitung
              </Button>
            </CardActions>
          </Card>
        </Grid>
      </AppCardGridContainer>
    </AppPage>
  );
};

export default TrainsPage;



