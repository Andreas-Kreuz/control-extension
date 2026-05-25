import { useState } from 'react';
import { TrackType } from '@ce/web-shared';
import TrainIcon from '@mui/icons-material/Train';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardActions from '@mui/material/CardActions';
import FormControlLabel from '@mui/material/FormControlLabel';
import Grid from '@mui/material/Grid';
import Switch from '@mui/material/Switch';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import { Link as RouterLink } from 'react-router-dom';
import CardGridContainer from '../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import useSelectedElementNavigation from '../../../shared/layouts/useSelectedElementNavigation';
import setTrackType from '../hooks/useSetTrackType';
import useSelectedScenario from '../hooks/useSelectedScenario';
import useTrackType from '../hooks/useTrackType';
import useTrains from '../hooks/useTrains';
import TrainCamerasSection from './TrainCamerasSection';
import TrainInformationSection from './TrainInformationSection';
import RollingStockSection from './RollingStockSection';
import TrainLineSection from './TrainLineSection';
import TrainListCard from './TrainListCard';
import TrainListItem from './TrainListItem';
import { trainSections } from './trainSectionPresentation';

interface ChipData {
  key: TrackType;
  label: string;
}

function hasTransitLineInfo(train: { line?: string }) {
  const line = (train.line ?? '').trim();
  return line.length > 0 && line !== '-';
}

interface TrainsPageProps {
  selectedElement?: string;
}

const TrainsPage = ({ selectedElement }: TrainsPageProps) => {
  const trains = useTrains();
  const scenario = useSelectedScenario();
  const activeTrainName = scenario?.activeTrain;
  const trackType = useTrackType();
  const setType = setTrackType();
  const handleSelectedElementChange = useSelectedElementNavigation(selectedElement);
  const [lineInfoOnly, setLineInfoOnly] = useState(false);

  const [chipData] = useState<readonly ChipData[]>([
    { key: TrackType.Rail, label: 'Gleis' },
    { key: TrackType.Tram, label: 'Tram' },
    { key: TrackType.Road, label: 'Straße' },
    { key: TrackType.Auxiliary, label: 'Sonstige' },
    { key: TrackType.Control, label: 'Steuern' },
  ]);
  const selectedTrackLabel = chipData.find((entry) => entry.key === trackType)?.label;
  const filteredTrains = lineInfoOnly ? trains.filter(hasTransitLineInfo) : trains;

  const filterSlot = (
    <>
      <Grid container spacing={2} alignItems="center">
        <Grid size={{ xs: 12, md: 'auto' }}>
          <ToggleButtonGroup
            exclusive
            size="small"
            value={trackType}
            onChange={(_event, value: TrackType | null) => {
              if (value !== null) {
                setType(value);
              }
            }}
            sx={{
              bgcolor: 'background.paper',
              display: 'inline-flex',
              flexWrap: 'wrap',
              maxWidth: '100%',
              width: 'fit-content',
            }}
          >
            {chipData.map((data) => (
              <ToggleButton key={data.key} value={data.key}>
                {data.label}
              </ToggleButton>
            ))}
          </ToggleButtonGroup>
        </Grid>
        <Grid size={{ xs: 12, md: 'auto' }}>
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
        </Grid>
      </Grid>
      <PageHeadline gutterTop>Fahrzeuge {selectedTrackLabel}</PageHeadline>
    </>
  );

  return (
    <PageContainer>
      <PageHeadline
        rightSettings={
          <Button variant="contained" startIcon={<TrainIcon />} component={RouterLink} to="/train/selected">
            Aktiver Zug
          </Button>
        }
      >
        Gleissystem
      </PageHeadline>
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
          <TrainListItem
            train={train}
            selected={selected}
            onSelect={onSelect}
            isActive={!!activeTrainName && (activeTrainName === train.id || activeTrainName === train.name)}
          />
        )}
        renderCard={(train, selected, onSelect, mobileExpansion) => (
          <TrainListCard train={train} selected={selected} onSelect={onSelect}>
            {mobileExpansion}
          </TrainListCard>
        )}
        getDetails={(train) => [
          {
            title: trainSections.trainControls.sideSheetTitle,
            icon: trainSections.trainControls.icon,
            component: <TrainCamerasSection trainName={train.id} rollingStockName={train.firstRollingStockName} />,
          },
          ...(hasTransitLineInfo(train)
            ? [
                {
                  title: trainSections.trainLine.sideSheetTitle,
                  icon: trainSections.trainLine.icon,
                  component: <TrainLineSection train={train} />,
                },
              ]
            : []),
          {
            title: trainSections.trainInfo.sideSheetTitle,
            icon: trainSections.trainInfo.icon,
            component: <TrainInformationSection train={train} />,
          },
          {
            title: trainSections.rollingStockInfo.sideSheetTitle,
            icon: trainSections.rollingStockInfo.icon,
            component: <RollingStockSection trainId={train.id} />,
          },
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
