import { lazy } from 'react';
import ModuleSettingsButton from '../../../shared/ui/ModuleSettingsButton';
import useLines from '../hooks/useLines';
import useTransitSettings from '../hooks/useTransitSettings';
import TransitLineCard from './TransitLineCard';
import TransitLineListItem from './TransitLineListItem';
import TransitLineSegment from './TransitLineSegment';

const AppPage = lazy(() => import('../../../shared/ui/AppPage'));
const AppPageHeadline = lazy(() => import('../../../shared/ui/AppPageHeadline'));
import ListLayout from '../../../shared/ui/ListLayout';

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
