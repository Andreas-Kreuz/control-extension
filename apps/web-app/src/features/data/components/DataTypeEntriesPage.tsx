import { useMemo } from 'react';
import { useParams } from 'react-router-dom';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import AppCardBg from '../../../shared/components/AppCardBg';
import AppPage from '../../../shared/layouts/AppPage';
import AppPageHeadline from '../../../shared/layouts/AppPageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import useSelectedElementNavigation from '../../../shared/layouts/useSelectedElementNavigation';
import useTypeEntries from '../hooks/useTypeEntries';
import DataEntryDetailSection from './DataEntryDetailSection';

interface DataEntry {
  id: string;
}

interface DataTypeEntriesPageProps {
  selectedElement?: string;
}

function DataTypeEntriesMod({ selectedElement }: DataTypeEntriesPageProps) {
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
    <AppPage>
      <AppPageHeadline>{ceType}</AppPageHeadline>
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
          <AppCardBg title={item.id} image="" selected={selected} expanded={selected} setExpanded={() => onSelect()}>
            {mobileExpansion}
          </AppCardBg>
        )}
        getDetails={(item) => [
          { title: 'Details', component: <DataEntryDetailSection ceType={ceType} entryId={item.id} /> },
        ]}
        selectedElement={selectedElement}
        onSelectedElementChange={handleSelectedElementChange}
      />
    </AppPage>
  );
}

export default DataTypeEntriesMod;
