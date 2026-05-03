import { Typography } from '@mui/material';
import ModuleSettingsButton from '../../../shared/components/ModuleSettingsButton';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import useSelectedElementNavigation from '../../../shared/layouts/useSelectedElementNavigation';
import useStations from '../hooks/useStations';
import useTransitStation from '../hooks/useTransitStation';
import useTransitSettings from '../hooks/useTransitSettings';
import TransitStationCard from './TransitStationCard';
import TransitStationDepartures from './TransitStationDepartures';
import TransitStationItem from './TransitStationItem';

interface TransitStationsOverviewProps {
  selectedElement?: string;
}

function TransitStationsOverview({ selectedElement }: TransitStationsOverviewProps) {
  const stations = useStations();
  const selectedStation = useTransitStation(selectedElement);
  const settings = useTransitSettings();
  const handleSelectedElementChange = useSelectedElementNavigation(selectedElement);

  return (
    <PageContainer>
      <PageHeadline
        {...(settings !== undefined ? { rightSettings: <ModuleSettingsButton settings={settings} /> } : {})}
      >
        Haltestellen
      </PageHeadline>
      <ListLayout
        items={stations}
        keyExtractor={(station) => station.id}
        getFilterText={(station) => `${station.id} ${station.name ?? ''}`}
        filterLabel="Haltestelle filtern"
        renderListItem={(station, selected, onSelect) => (
          <TransitStationItem station={station} selected={selected} onSelect={onSelect} />
        )}
        renderCard={(station, selected, onSelect, mobileExpansion) => (
          <TransitStationCard station={station} selected={selected} onSelect={onSelect}>
            {mobileExpansion}
          </TransitStationCard>
        )}
        emptyMessage={() => <Typography variant="body2">Es wurden keine Haltestellen gefunden.</Typography>}
        getDetails={(station) => [
          {
            title: 'Abfahrten',
            component: (
              <TransitStationDepartures
                station={selectedElement === station.id ? (selectedStation ?? station) : station}
              />
            ),
          },
        ]}
        selectedElement={selectedElement}
        onSelectedElementChange={handleSelectedElementChange}
      />
    </PageContainer>
  );
}

export default TransitStationsOverview;
