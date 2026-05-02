import { Typography } from '@mui/material';
import ModuleSettingsButton from '../../../shared/components/ModuleSettingsButton';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import useSelectedElementNavigation from '../../../shared/layouts/useSelectedElementNavigation';
import useLines from '../hooks/useLines';
import useTransitSettings from '../hooks/useTransitSettings';
import TransitLineListCard from './TransitLineListCard';
import TransitLineItem from './TransitLineItem';
import TransitLineSegment from './TransitLineSegment';

interface TransitOverviewProps {
  selectedElement?: string;
}

function TransitOverview({ selectedElement }: TransitOverviewProps) {
  const lines = useLines();
  const settings = useTransitSettings();
  const handleSelectedElementChange = useSelectedElementNavigation(selectedElement);

  return (
    <PageContainer>
      <PageHeadline
        {...(settings !== undefined ? { rightSettings: <ModuleSettingsButton settings={settings} /> } : {})}
      >
        ÖPNV
      </PageHeadline>
      <ListLayout
        items={lines}
        keyExtractor={(line) => String(line.id)}
        getFilterText={(line) => [line.nr, ...line.lineSegments.map((ls) => ls.destination)].join(' ')}
        filterLabel="Linie filtern"
        renderListItem={(line, selected, onSelect) => (
          <TransitLineItem line={line} selected={selected} onSelect={onSelect} />
        )}
        emptyMessage={() => <Typography variant="body2">{`Es wurden keine ÖPNV-Linien gefunden.`}</Typography>}
        renderCard={(line, selected, onSelect, mobileExpansion) => (
          <TransitLineListCard line={line} selected={selected} onSelect={onSelect}>
            {mobileExpansion}
          </TransitLineListCard>
        )}
        getDetails={(line) =>
          line.lineSegments.map((ls) => ({
            title: ls.destination,
            component: <TransitLineSegment segment={ls} />,
          }))
        }
        selectedElement={selectedElement}
        onSelectedElementChange={handleSelectedElementChange}
      />
    </PageContainer>
  );
}

export default TransitOverview;
