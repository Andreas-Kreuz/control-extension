import { lazy, useMemo, useState } from 'react';
import { Link as RouterLink, useParams } from 'react-router-dom';
import Breadcrumbs from '@mui/material/Breadcrumbs';
import Link from '@mui/material/Link';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import useTypeEntries from '../hooks/useTypeEntries';

const AppPage = lazy(() => import('../../../shared/ui/AppPage'));
const AppPageHeadline = lazy(() => import('../../../shared/ui/AppPageHeadline'));

function DataTypeEntriesMod() {
  const { ceType = '' } = useParams<{ ceType: string }>();
  const entriesMap = useTypeEntries(ceType);
  const [filter, setFilter] = useState('');

  const allKeys = useMemo(
    () =>
      Array.from(new Set(Object.values(entriesMap).flatMap((entry) => Object.keys(entry))))
        .filter((key) => key !== 'id')
        .sort((a, b) => a.localeCompare(b, undefined, { numeric: true })),
    [entriesMap],
  );

  const rows = useMemo(() => {
    const lower = filter.toLowerCase();
    return Object.entries(entriesMap)
      .filter(([entryId]) => entryId.toLowerCase().includes(lower))
      .sort(([a], [b]) => a.localeCompare(b, undefined, { numeric: true }));
  }, [entriesMap, filter]);

  return (
    <AppPage>
      <Breadcrumbs sx={{ mb: 1 }}>
        <Link component={RouterLink} to="/data" underline="hover" color="inherit">
          CE-Typen
        </Link>
        <Typography color="text.primary">{ceType}</Typography>
      </Breadcrumbs>
      <AppPageHeadline>{ceType}</AppPageHeadline>
      <TextField
        size="small"
        label="ID filtern"
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        sx={{ mb: 2 }}
      />
      {rows.length === 0 ? (
        <Typography color="text.secondary">Keine Einträge vorhanden.</Typography>
      ) : (
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              {allKeys.map((key) => (
                <TableCell key={key}>{key}</TableCell>
              ))}
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.map(([entryId, entryData]) => (
              <TableRow key={entryId}>
                <TableCell>
                  <RouterLink to={`/data/${encodeURIComponent(ceType)}/${encodeURIComponent(entryId)}`}>
                    {entryId}
                  </RouterLink>
                </TableCell>
                {allKeys.map((key) => (
                  <TableCell key={key}>
                    {entryData[key] !== undefined
                      ? typeof entryData[key] === 'object'
                        ? JSON.stringify(entryData[key])
                        : String(entryData[key])
                      : ''}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </AppPage>
  );
}

export default DataTypeEntriesMod;

