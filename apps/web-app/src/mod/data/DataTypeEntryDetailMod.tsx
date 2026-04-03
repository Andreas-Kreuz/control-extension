import { lazy, useMemo } from 'react';
import { Link as RouterLink, useParams } from 'react-router-dom';
import Breadcrumbs from '@mui/material/Breadcrumbs';
import Link from '@mui/material/Link';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import {
  CeTypes,
  DynamicRoom,
  TrainDynamicRoom,
  RollingStockDynamicRoom,
} from '@ce/web-shared';
import useTypeEntries from './useTypeEntries';
import useDynamicEntry from './useDynamicEntry';

const AppPage = lazy(() => import('../../components/AppPage'));
const AppPageHeadline = lazy(() => import('../../components/AppPageHeadline'));

const companionRooms: Record<string, DynamicRoom> = {
  [CeTypes.HubTrainStatic]: TrainDynamicRoom,
  [CeTypes.HubRollingStockStatic]: RollingStockDynamicRoom,
};

function formatValue(value: unknown): string {
  if (value === undefined || value === null) return '';
  return typeof value === 'object' ? JSON.stringify(value) : String(value);
}

function DataTypeEntryDetailMod() {
  const { ceType = '', entryId = '' } = useParams<{ ceType: string; entryId: string }>();
  const companionRoom = companionRooms[ceType];
  const entriesMap = useTypeEntries(ceType);
  const companionEntry = useDynamicEntry(companionRoom, entryId);

  const entry = entriesMap[entryId];

  const fields = useMemo(() => {
    if (!entry) return [];
    const staticFields = Object.entries(entry).map(([field, value]) => ({
      field,
      value: formatValue(value),
    }));
    const dynamicFields = companionEntry
      ? Object.entries(companionEntry)
          .filter(([field]) => !(field in entry))
          .map(([field, value]) => ({ field, value: formatValue(value) }))
      : [];
    return [...staticFields, ...dynamicFields].sort((a, b) => a.field.localeCompare(b.field));
  }, [entry, companionEntry]);

  return (
    <AppPage>
      <Breadcrumbs sx={{ mb: 1 }}>
        <Link component={RouterLink} to="/data" underline="hover" color="inherit">
          CE-Typen
        </Link>
        <Link
          component={RouterLink}
          to={`/data/${encodeURIComponent(ceType)}`}
          underline="hover"
          color="inherit"
        >
          {ceType}
        </Link>
        <Typography color="text.primary">{entryId}</Typography>
      </Breadcrumbs>
      <AppPageHeadline>{entryId}</AppPageHeadline>
      {entry ? (
        <Table size="small">
          <TableBody>
            {fields.map(({ field, value }) => (
              <TableRow key={field}>
                <TableCell component="th" scope="row" sx={{ fontWeight: 'bold' }}>
                  {field}
                </TableCell>
                <TableCell>{value}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      ) : (
        <Typography color="text.secondary">Eintrag wird geladen …</Typography>
      )}
    </AppPage>
  );
}

export default DataTypeEntryDetailMod;
