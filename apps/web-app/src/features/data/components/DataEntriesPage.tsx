import { useMemo } from 'react';
import { useParams } from 'react-router-dom';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import BackgroundImageCard from '../../../shared/components/cards/BackgroundImageCard';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import useSelectedElementNavigation from '../../../shared/layouts/useSelectedElementNavigation';
import useTypeEntries from '../hooks/useTypeEntries';
import DataEntrySection from './DataEntrySection';

interface DataEntry {
  id: string;
}

interface DataEntriesPageProps {
  selectedElement?: string;
}

function DataEntriesPage({ selectedElement }: DataEntriesPageProps) {
  const { ceType = '' } = useParams<{ ceType: string }>();
  const entriesMap = useTypeEntries(ceType);
  const handleSelectedElementChange = useSelectedElementNavigation(selectedElement);

  const items = useMemo(
    () =>
      Object.keys(entriesMap)
        .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }))
        .map((id): DataEntry => ({ id })),
    [entriesMap],
  );

  return (
    <PageContainer>
      <PageHeadline>{ceType}</PageHeadline>
      <ListLayout
        items={items}
        keyExtractor={(item) => item.id}
        getFilterText={(item) => item.id}
        filterLabel="ID filtern"
        renderListItem={(item, selected, onSelect) => (
          <ListItem disablePadding>
            <ListItemButton selected={selected} onClick={onSelect}>
              <ListItemText primary={item.id} secondary={ceType} />
            </ListItemButton>
          </ListItem>
        )}
        renderCard={(item, selected, onSelect, mobileExpansion) => (
          <BackgroundImageCard title={item.id} image="" selected={selected} expanded={selected} setExpanded={() => onSelect()}>
            {mobileExpansion}
          </BackgroundImageCard>
        )}
        getDetails={(item) => [
          { title: 'Details', component: <DataEntrySection ceType={ceType} entryId={item.id} /> },
        ]}
        selectedElement={selectedElement}
        onSelectedElementChange={handleSelectedElementChange}
      />
    </PageContainer>
  );
}

export default DataEntriesPage;
