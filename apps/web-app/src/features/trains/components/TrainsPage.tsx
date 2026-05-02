import { useState } from 'react';
import { TrackType } from '@ce/web-shared';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardActions from '@mui/material/CardActions';
import Chip from '@mui/material/Chip';
import FormControlLabel from '@mui/material/FormControlLabel';
import Grid from '@mui/material/Grid';
import Switch from '@mui/material/Switch';
import Typography from '@mui/material/Typography';
import { styled } from '@mui/material/styles';
import CardGridContainer from '../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import useSelectedElementNavigation from '../../../shared/layouts/useSelectedElementNavigation';
import setTrackType from '../hooks/useSetTrackType';
import useTrackType from '../hooks/useTrackType';
import useTrains from '../hooks/useTrains';
import TrainCamerasView from './TrainCamerasView';
import TrainInformationSection from './TrainInformationSection';
import RollingStockSection from './RollingStockSection';
import TrainLineSection from './TrainLineSection';
import TrainListCard from './TrainListCard';
import TrainListItem from './TrainListItem';

interface ChipData {
  key: TrackType;
  label: string;
}

const TrackTypeChipItem = styled('li')(({ theme }) => ({
  margin: theme.spacing(0.5),
}));

function hasTransitLineInfo(train: { line?: string }) {
  const line = (train.line ?? '').trim();
  return line.length > 0 && line !== '-';
}

interface TrainsPageProps {
  selectedElement?: string;
}

const TrainsPage = ({ selectedElement }: TrainsPageProps) => {
  const trains = useTrains();
  const trackType = useTrackType();
  const setType = setTrackType();
  const handleSelectedElementChange = useSelectedElementNavigation(selectedElement);
  const [lineInfoOnly, setLineInfoOnly] = useState(false);

  const [chipData] = useState<readonly ChipData[]>([
    { key: TrackType.Rail, label: 'Gleise' },
    { key: TrackType.Tram, label: 'Straßenbahn' },
    { key: TrackType.Road, label: 'Straße' },
    { key: TrackType.Auxiliary, label: 'Sonstige Splines' },
    { key: TrackType.Control, label: 'Steuerstrecken' },
  ]);
  const selectedTrackLabel = chipData.find((entry) => entry.key === trackType)?.label;
  const filteredTrains = lineInfoOnly ? trains.filter(hasTransitLineInfo) : trains;

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
          <TrackTypeChipItem key={data.key}>
            <Chip
              label={data.label}
              variant="filled"
              color={trackType === data.key ? 'primary' : 'default'}
              onClick={() => setType(data.key)}
            />
          </TrackTypeChipItem>
        ))}
      </Box>
      <FormControlLabel
        control={
          <Switch
            checked={lineInfoOnly}
            onChange={(event) => setLineInfoOnly(event.target.checked)}
            slotProps={{ input: { 'aria-label': 'Nur Fahrzeuge mit Linieninformation anzeigen' } }}
          />
        }
        label="Nur mit Linieninformation"
      />
      <PageHeadline gutterTop>Fahrzeuge {selectedTrackLabel}</PageHeadline>
    </>
  );

  return (
    <PageContainer>
      <PageHeadline>Gleissystem</PageHeadline>
      <ListLayout
        items={filteredTrains}
        keyExtractor={(train) => train.id}
        getFilterText={(train) => train.id}
        filterLabel="Zugname filtern"
        emptyMessage={(ft) => (
          <Typography variant="body2">
            {ft
              ? `Es wurden keine Fahrzeuge mit dem Namen "${ft}" im Gleissystem ${selectedTrackLabel}${lineInfoOnly ? ' mit Linieninformation' : ''} gefunden.`
              : `Es wurden keine Fahrzeuge im Gleissystem ${selectedTrackLabel}${lineInfoOnly ? ' mit Linieninformation' : ''} gefunden. Wähle ein anderes Gleissystem oder füge Fahrzeuge in EEP hinzu.`}
          </Typography>
        )}
        renderListItem={(train, selected, onSelect) => (
          <TrainListItem train={train} selected={selected} onSelect={onSelect} />
        )}
        renderCard={(train, selected, onSelect, mobileExpansion) => (
          <TrainListCard train={train} selected={selected} onSelect={onSelect}>
            {mobileExpansion}
          </TrainListCard>
        )}
        getDetails={(train) => [
          {
            title: 'Kameras',
            component: <TrainCamerasView trainName={train.id} rollingStockName={train.firstRollingStockName} />,
          },
          ...(hasTransitLineInfo(train) ? [{ title: 'Linien', component: <TrainLineSection train={train} /> }] : []),
          { title: 'Information', component: <TrainInformationSection train={train} /> },
          { title: 'RollingStock', component: <RollingStockSection trainId={train.id} /> },
        ]}
        filterSlot={filterSlot}
        selectedElement={selectedElement}
        onSelectedElementChange={handleSelectedElementChange}
      />

      {/* <PageHeadline gutterTop>Hilfe</PageHeadline>
      <CardGridContainer>
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
      </CardGridContainer> */}
    </PageContainer>
  );
};

export default TrainsPage;
