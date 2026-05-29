import ChevronRightRoundedIcon from '@mui/icons-material/ChevronRightRounded';
import ExpandMoreRoundedIcon from '@mui/icons-material/ExpandMoreRounded';
import Box from '@mui/material/Box';
import Collapse from '@mui/material/Collapse';
import Grid from '@mui/material/Grid';
import IconButton from '@mui/material/IconButton';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import { useMemo, useState } from 'react';
import OutlinedCard from '../../../shared/components/cards/OutlinedCard';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import useDataTransferFields from '../hooks/useDataTransferFields';
import useDataTransferSummary from '../hooks/useDataTransferSummary';
import { DataTransferCeTypeSummaryAppDto } from '@ce/web-shared';

type CountMode = 'total' | 'last';

const numberFormatter = new Intl.NumberFormat('de-DE');

function formatCount(count: number): string {
  return numberFormatter.format(count);
}

function FieldRows(props: { ceType: string; mode: CountMode }) {
  const data = useDataTransferFields(props.ceType);
  const fields = useMemo(
    () =>
      data.fields
        .filter((field) => (props.mode === 'total' ? field.totalUpdateCount > 0 : field.lastUpdateCount > 0))
        .sort((left, right) => {
          const leftCount = props.mode === 'total' ? left.totalUpdateCount : left.lastUpdateCount;
          const rightCount = props.mode === 'total' ? right.totalUpdateCount : right.lastUpdateCount;
          return rightCount - leftCount || left.field.localeCompare(right.field);
        }),
    [data.fields, props.mode],
  );

  if (fields.length === 0) {
    return (
      <TableRow>
        <TableCell />
        <TableCell colSpan={3}>
          <Typography color="text.secondary" variant="body2">
            Keine Feldaktualisierungen
          </Typography>
        </TableCell>
      </TableRow>
    );
  }

  return (
    <>
      {fields.map((field) => (
        <TableRow key={field.field}>
          <TableCell />
          <TableCell sx={{ color: 'text.secondary', pl: 5 }}>{field.field}</TableCell>
          <TableCell align="right">
            {formatCount(props.mode === 'total' ? field.totalUpdateCount : field.lastUpdateCount)}
          </TableCell>
          <TableCell />
        </TableRow>
      ))}
    </>
  );
}

function DataTransferRow(props: { entry: DataTransferCeTypeSummaryAppDto; mode: CountMode }) {
  const [expanded, setExpanded] = useState(false);
  const fieldCount = props.mode === 'total' ? props.entry.totalFieldUpdateCount : props.entry.lastFieldUpdateCount;
  const updateCount = props.mode === 'total' ? props.entry.totalUpdateCount : props.entry.lastUpdateCount;

  return (
    <>
      <TableRow hover>
        <TableCell padding="checkbox">
          <IconButton
            aria-label={expanded ? 'Felder einklappen' : 'Felder ausklappen'}
            disabled={fieldCount === 0}
            onClick={() => setExpanded((current) => !current)}
            size="small"
          >
            {expanded ? <ExpandMoreRoundedIcon /> : <ChevronRightRoundedIcon />}
          </IconButton>
        </TableCell>
        <TableCell sx={{ overflowWrap: 'anywhere' }}>{props.entry.ceType}</TableCell>
        <TableCell align="right">{formatCount(updateCount)}</TableCell>
        <TableCell align="right">
          {props.mode === 'total' ? formatCount(props.entry.initialUpdateCount) : formatCount(fieldCount)}
        </TableCell>
      </TableRow>
      <TableRow>
        <TableCell colSpan={4} sx={{ borderBottom: 0, p: 0 }}>
          <Collapse in={expanded} mountOnEnter unmountOnExit>
            <Box sx={{ py: 1 }}>
              <Table size="small" aria-label={`${props.entry.ceType} Felder`}>
                <TableBody>
                  <FieldRows ceType={props.entry.ceType} mode={props.mode} />
                </TableBody>
              </Table>
            </Box>
          </Collapse>
        </TableCell>
      </TableRow>
    </>
  );
}

function DataTransferTable(props: {
  title: string;
  description: string;
  entries: DataTransferCeTypeSummaryAppDto[];
  mode: CountMode;
}) {
  return (
    <OutlinedCard title={props.title} description={props.description}>
      {props.entries.length === 0 ? (
        <Typography color="text.secondary" variant="body2">
          Noch keine Datenaktualisierungen empfangen.
        </Typography>
      ) : (
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell padding="checkbox" />
              <TableCell>CE-Typ</TableCell>
              <TableCell align="right">Updates</TableCell>
              <TableCell align="right">{props.mode === 'total' ? 'Initial' : 'Felder'}</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {props.entries.map((entry) => (
              <DataTransferRow key={entry.ceType} entry={entry} mode={props.mode} />
            ))}
          </TableBody>
        </Table>
      )}
    </OutlinedCard>
  );
}

function DataTransferPage() {
  const summary = useDataTransferSummary();
  const totalEntries = useMemo(
    () =>
      [...summary.ceTypes].sort(
        (left, right) => right.totalUpdateCount - left.totalUpdateCount || left.ceType.localeCompare(right.ceType),
      ),
    [summary.ceTypes],
  );
  const lastEntries = useMemo(
    () =>
      summary.ceTypes
        .filter((entry) => entry.lastUpdateCount > 0)
        .sort((left, right) => right.lastUpdateCount - left.lastUpdateCount || left.ceType.localeCompare(right.ceType)),
    [summary.ceTypes],
  );

  return (
    <PageContainer>
      <PageHeadline>Datenfluss</PageHeadline>
      <Typography color="text.secondary" sx={{ mb: 3 }} variant="body1">
        Gezählt werden akzeptierte Server-Updates nach CE-Typ und Feld. Felder werden erst beim Ausklappen geladen.
      </Typography>
      <Grid container spacing={3}>
        <Grid size={{ xs: 12, lg: 6 }}>
          <DataTransferTable
            title="Gesamt"
            description={`Bis Event ${formatCount(summary.eventCounter)}`}
            entries={totalEntries}
            mode="total"
          />
        </Grid>
        <Grid size={{ xs: 12, lg: 6 }}>
          <DataTransferTable
            title="Letzte Aktualisierung"
            description={
              summary.lastEventCounter !== undefined
                ? `Transfer bis Event ${formatCount(summary.lastEventCounter)}`
                : 'Noch kein Daten-Event'
            }
            entries={lastEntries}
            mode="last"
          />
        </Grid>
      </Grid>
    </PageContainer>
  );
}

export default DataTransferPage;
