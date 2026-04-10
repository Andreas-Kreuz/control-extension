import { useState } from 'react';
import { TrackType } from '@ce/web-shared';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardActions from '@mui/material/CardActions';
import Chip from '@mui/material/Chip';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import { styled } from '@mui/material/styles';
import AppCardGridContainer from '../../../shared/layouts/AppCardGridContainer';
import AppPage from '../../../shared/layouts/AppPage';
import AppPageHeadline from '../../../shared/layouts/AppPageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import setTrackType from '../hooks/useSetTrackType';
import useTrackType from '../hooks/useTrackType';
import useTrains from '../hooks/useTrains';
import TrainCamerasView from './TrainCamerasView';
import TrainInformationSection from './TrainInformationSection';
import TrainRollingStockSection from './TrainRollingStockSection';
import TrainLineInfoSection from './TrainLineInfoSection';
import TrainListEntryCard from './TrainListEntryCard';
import TrainListItem from './TrainListItem';

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

  const [chipData] = useState<readonly ChipData[]>([
    { key: TrackType.Rail, label: 'Gleise' },
    { key: TrackType.Tram, label: 'Straßenbahn' },
    { key: TrackType.Road, label: 'Straße' },
    { key: TrackType.Auxiliary, label: 'Sonstige Splines' },
    { key: TrackType.Control, label: 'Steuerstrecken' },
  ]);
  const selectedTrackLabel = chipData.find((entry) => entry.key === trackType)?.label;

  const filterSlot = (
    <>
      <Box
        component="ul"
        sx={{
          display: 'flex',
          justifyContent: { xs: 'center', md: 'flex-start' },
          flexWrap: 'wrap',
          listStyle: 'none',
          p: 0,
          m: 0,
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
      <AppPageHeadline gutterTop>Fahrzeuge {selectedTrackLabel}</AppPageHeadline>
    </>
  );

  return (
    <AppPage>
      <AppPageHeadline>Gleissystem</AppPageHeadline>
      <ListLayout
        items={trains}
        keyExtractor={(train) => train.id}
        getFilterText={(train) => train.id}
        filterLabel="Zugname filtern"
        emptyMessage={(ft) => (
          <Typography variant="body2">
            {ft
              ? `Es wurden keine Fahrzeuge mit dem Namen "${ft}" im Gleissystem ${selectedTrackLabel} gefunden.`
              : `Es wurden keine Fahrzeuge im Gleissystem ${selectedTrackLabel} gefunden. Wähle ein anderes Gleissystem oder füge Fahrzeuge in EEP hinzu.`}
          </Typography>
        )}
        renderListItem={(train, selected, onSelect) => (
          <TrainListItem train={train} selected={selected} onSelect={onSelect} />
        )}
        renderCard={(train, selected, onSelect, mobileExpansion) => (
          <TrainListEntryCard train={train} selected={selected} onSelect={onSelect}>
            {mobileExpansion}
          </TrainListEntryCard>
        )}
        getDetails={(train) => [
          {
            title: 'Kameras',
            component: <TrainCamerasView trainName={train.id} rollingStockName={train.firstRollingStockName} />,
          },
          { title: 'Information', component: <TrainInformationSection train={train} /> },
          { title: 'RollingStock', component: <TrainRollingStockSection trainId={train.id} /> },
          { title: 'Linien', component: <TrainLineInfoSection train={train} /> },
        ]}
        filterSlot={filterSlot}
      />

      {/* <AppPageHeadline gutterTop>Hilfe</AppPageHeadline>
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
      </AppCardGridContainer> */}
    </AppPage>
  );
};

export default TrainsPage;
