import { Typography } from '@mui/material';
import ModuleSettingsButton from '../../../shared/components/ModuleSettingsButton';
import AppPage from '../../../shared/layouts/AppPage';
import AppPageHeadline from '../../../shared/layouts/AppPageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import useLines from '../hooks/useLines';
import useTransitSettings from '../hooks/useTransitSettings';
import TransitLineCard from './TransitLineCard';
import TransitLineListItem from './TransitLineListItem';
import TransitLineSegment from './TransitLineSegment';

function TransitOverview() {
  const lines = useLines();
  const settings = useTransitSettings();

  return (
    <AppPage>
      <AppPageHeadline
        {...(settings !== undefined ? { rightSettings: <ModuleSettingsButton settings={settings} /> } : {})}
      >
        ÖPNV
      </AppPageHeadline>
      <ListLayout
        items={lines}
        keyExtractor={(line) => String(line.id)}
        getFilterText={(line) => [line.nr, ...line.lineSegments.map((ls) => ls.destination)].join(' ')}
        filterLabel="Linie filtern"
        renderListItem={(line, selected, onSelect) => (
          <TransitLineListItem line={line} selected={selected} onSelect={onSelect} />
        )}
        emptyMessage={(ft) => <Typography variant="body2">{`Es wurden keine ÖPNV-Linien gefunden.`}</Typography>}
        renderCard={(line, selected, onSelect, mobileExpansion) => (
          <TransitLineCard line={line} selected={selected} onSelect={onSelect}>
            {mobileExpansion}
          </TransitLineCard>
        )}
        getDetails={(line) =>
          line.lineSegments.map((ls) => ({
            title: ls.destination,
            component: <TransitLineSegment segment={ls} />,
          }))
        }
      />
    </AppPage>
  );
}

export default TransitOverview;
