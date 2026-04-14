import { Typography } from '@mui/material';
import ModuleSettingsButton from '../../../shared/components/ModuleSettingsButton';
import AppPage from '../../../shared/layouts/AppPage';
import AppPageHeadline from '../../../shared/layouts/AppPageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import useSelectedElementNavigation from '../../../shared/layouts/useSelectedElementNavigation';
import useStations from '../hooks/useStations';
import useTransitStation from '../hooks/useTransitStation';
import useTransitSettings from '../hooks/useTransitSettings';
import TransitStationCard from './TransitStationCard';
import TransitStationDepartures from './TransitStationDepartures';
import TransitStationListItem from './TransitStationListItem';

interface TransitStationsOverviewProps {
  selectedElement?: string;
}

function TransitStationsOverview({ selectedElement }: TransitStationsOverviewProps) {
  const stations = useStations();
  const selectedStation = useTransitStation(selectedElement);
  const settings = useTransitSettings();
  const handleSelectedElementChange = useSelectedElementNavigation(selectedElement);

  return (
    <AppPage>
      <AppPageHeadline
        {...(settings !== undefined ? { rightSettings: <ModuleSettingsButton settings={settings} /> } : {})}
      >
        Haltestellen
      </AppPageHeadline>
      <ListLayout
        items={stations}
        keyExtractor={(station) => station.id}
        getFilterText={(station) => `${station.id} ${station.name ?? ''}`}
        filterLabel="Haltestelle filtern"
        renderListItem={(station, selected, onSelect) => (
          <TransitStationListItem station={station} selected={selected} onSelect={onSelect} />
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
    </AppPage>
  );
}

export default TransitStationsOverview;
