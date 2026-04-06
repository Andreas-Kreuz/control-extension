import { lazy, useMemo } from 'react';
import { Link as RouterLink, useParams } from 'react-router-dom';
import Breadcrumbs from '@mui/material/Breadcrumbs';
import Link from '@mui/material/Link';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import useTypeEntries from './useTypeEntries';

const AppPage = lazy(() => import('../../components/AppPage'));
const AppPageHeadline = lazy(() => import('../../components/AppPageHeadline'));

function formatValue(value: unknown): string {
  if (value === undefined || value === null) return '';
  return typeof value === 'object' ? JSON.stringify(value) : String(value);
}

function DataTypeEntryDetailMod() {
  const { ceType = '', entryId = '' } = useParams<{ ceType: string; entryId: string }>();
  const entriesMap = useTypeEntries(ceType);

  const entry = entriesMap[entryId];

  const fields = useMemo(() => {
    if (!entry) return [];
    return Object.entries(entry)
      .map(([field, value]) => ({
        field,
        value: formatValue(value),
      }))
      .sort((a, b) => a.field.localeCompare(b.field));
  }, [entry]);

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
