import { lazy, useMemo, useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TextField from '@mui/material/TextField';
import useApiEntries from '../hooks/useApiEntries';

const AppPage = lazy(() => import('../../../shared/ui/AppPage'));
const AppPageHeadline = lazy(() => import('../../../shared/ui/AppPageHeadline'));

function DataMod() {
  const entries = useApiEntries();
  const [filter, setFilter] = useState('');

  const filtered = useMemo(() => {
    const lower = filter.toLowerCase();
    return [...entries]
      .filter((e) => e.name.toLowerCase().includes(lower))
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [entries, filter]);

  return (
    <AppPage>
      <AppPageHeadline>CE-Typen</AppPageHeadline>
      <TextField
        size="small"
        label="Typ filtern"
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        sx={{ mb: 2 }}
      />
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Typ</TableCell>
            <TableCell align="right">Einträge</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {filtered.map((entry) => (
            <TableRow key={entry.name}>
              <TableCell>
                <RouterLink to={`/data/${encodeURIComponent(entry.name)}`}>{entry.name}</RouterLink>
              </TableCell>
              <TableCell align="right">{entry.count}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </AppPage>
  );
}

export default DataMod;
