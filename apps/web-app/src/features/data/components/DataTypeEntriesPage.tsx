import { lazy, useMemo } from 'react';
import { useParams } from 'react-router-dom';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import ListLayout from '../../../shared/layouts/ListLayout';
import useTypeEntries from '../hooks/useTypeEntries';
import DataEntryDetailSection from './DataEntryDetailSection';

const AppCardBg = lazy(() => import('../../../shared/components/AppCardBg'));
const AppPage = lazy(() => import('../../../shared/layouts/AppPage'));
const AppPageHeadline = lazy(() => import('../../../shared/layouts/AppPageHeadline'));

interface DataEntry {
  id: string;
}

function DataTypeEntriesMod() {
  const { ceType = '' } = useParams<{ ceType: string }>();
  const entriesMap = useTypeEntries(ceType);

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
      />
    </AppPage>
  );
}

export default DataTypeEntriesMod;
