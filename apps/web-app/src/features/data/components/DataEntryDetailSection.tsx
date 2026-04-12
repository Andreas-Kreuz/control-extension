import { useMemo } from 'react';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import { detailRoomForCeType } from '@ce/web-shared';
import useDomainEntry from '../hooks/useDynamicEntry';
import useTypeEntries from '../hooks/useTypeEntries';

function formatValue(value: unknown): string {
  if (value === undefined || value === null) return '';
  return typeof value === 'object' ? JSON.stringify(value) : String(value);
}

interface DataEntryDetailSectionProps {
  ceType: string;
  entryId: string;
}

function DataEntryDetailSection({ ceType, entryId }: DataEntryDetailSectionProps) {
  const entriesMap = useTypeEntries(ceType);
  const dynamicEntry = useDomainEntry(detailRoomForCeType(ceType), entryId);

  const entry = dynamicEntry ?? entriesMap[entryId];

  const fields = useMemo(() => {
    if (!entry) return [];
    return Object.entries(entry)
      .map(([field, value]) => ({ field, value: formatValue(value) }))
      .sort((a, b) => a.field.localeCompare(b.field));
  }, [entry]);

  if (!entry) {
    return (
      <Typography color="text.secondary" sx={{ p: 2 }}>
        Eintrag wird geladen …
      </Typography>
    );
  }

  return (
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
  );
}

export default DataEntryDetailSection;
