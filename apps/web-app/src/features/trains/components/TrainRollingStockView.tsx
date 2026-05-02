import { CommandEvent, RollingStockAppDto } from '@ce/web-shared';
import Box from '@mui/material/Box';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Typography from '@mui/material/Typography';
import { useSocket } from '../../../app/hooks/useSocket';
import { AxisList } from '../../../shared/components/axises';
import useRollingStockDynamic from '../hooks/useRollingStockDynamic';

function TrainRollingStockView(props: { rollingStock: RollingStockAppDto[] | undefined }) {
  const { rollingStock } = props;

  if (!rollingStock?.length) {
    return <Typography color="textSecondary">Keine RollingStocks gefunden.</Typography>;
  }

  return (
    <List disablePadding sx={{ px: 2, pb: 2, containerType: 'inline-size' }}>
      {rollingStock.map((item) => (
        <RollingStockRow key={item.id} rollingStock={item} />
      ))}
    </List>
  );
}

function RollingStockRow(props: { rollingStock: RollingStockAppDto }) {
  const dynamicRollingStock = useRollingStockDynamic(props.rollingStock.id);
  const rollingStock = dynamicRollingStock ?? props.rollingStock;
  const socket = useSocket();
  const textureEntries = sortedNumberKeys(rollingStock.textureNames, rollingStock.surfaceTexts);
  const axisEntries = sortedNumberKeys(rollingStock.axisNames, rollingStock.axisValues);

  const setAxis = (axisNumber: number, value: number) => {
    socket.emit(CommandEvent.SetRollingStockAxis, {
      rollingStockName: rollingStock.name,
      axisNumber,
      value,
    });
  };

  return (
    <ListItem
      sx={{
        px: 0,
        py: 0.5,
        alignItems: 'flex-start',
        borderBottom: '1px solid',
        borderColor: 'divider',
      }}
    >
      <Box
        sx={{
          width: 1,
          gap: 2,
        }}
      >
        <RowCell label="Name" value={rollingStock.name} />
        <RowCell label="TagText" value={rollingStock.tag || '-'} />
        <RowCell label="XML Model" value={rollingStock.xmlModel || '-'} />
        <TextureTextList entries={textureEntries} rollingStock={rollingStock} />
        <RollingStockAxisList entries={axisEntries} rollingStock={rollingStock} onSetAxis={setAxis} />
      </Box>
    </ListItem>
  );
}

function RowCell(props: { label: string; value: string; multiline?: boolean }) {
  return (
    <Box sx={{ minWidth: 0, textAlign: 'left', justifySelf: 'start' }}>
      <Typography variant="caption" color="textSecondary" align="left">
        {props.label}
      </Typography>
      <Typography
        variant="body2"
        align="left"
        sx={{
          whiteSpace: props.multiline ? 'pre-wrap' : 'nowrap',
          overflow: 'hidden',
          textOverflow: props.multiline ? 'unset' : 'ellipsis',
          wordBreak: 'break-word',
        }}
      >
        {props.value}
      </Typography>
    </Box>
  );
}

function TextureTextList(props: { entries: number[]; rollingStock: RollingStockAppDto }) {
  if (props.entries.length === 0) {
    return <RowCell label="TextureTexts" value="-" />;
  }

  return (
    <Box sx={{ minWidth: 0, textAlign: 'left', justifySelf: 'stretch' }}>
      <Typography variant="caption" color="textSecondary" align="left">
        TextureTexts
      </Typography>
      <Box sx={{ display: 'grid', gap: 0.5 }}>
        {props.entries.map((textureNumber) => (
          <Typography
            key={textureNumber}
            variant="body2"
            component="div"
            sx={{
              display: 'grid',
              gridTemplateColumns: '4ch minmax(100px, 1fr) minmax(80px, 1fr)',
              gap: 1,
              minWidth: 0,
            }}
          >
            <Box component="span" sx={{ fontVariantNumeric: 'tabular-nums', textAlign: 'right' }}>
              {textureNumber}:
            </Box>
            <Box component="span" sx={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {props.rollingStock.textureNames?.[String(textureNumber)] ?? `TextureText ${textureNumber}`}
            </Box>
            <Box component="span" sx={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {props.rollingStock.surfaceTexts?.[String(textureNumber)] ?? ''}
            </Box>
          </Typography>
        ))}
      </Box>
    </Box>
  );
}

function RollingStockAxisList(props: {
  entries: number[];
  rollingStock: RollingStockAppDto;
  onSetAxis: (axisNumber: number, value: number) => void;
}) {
  if (props.entries.length === 0) {
    return <RowCell label="Achsen" value="-" />;
  }

  return (
    <Box sx={{ minWidth: 0, textAlign: 'left', justifySelf: 'stretch' }}>
      <Typography variant="caption" color="textSecondary" align="left">
        Achsen
      </Typography>
      <AxisList
        entries={props.entries.map((axisNumber) => ({
          axisNumber,
          name: props.rollingStock.axisNames?.[String(axisNumber)] ?? `Achse ${axisNumber}`,
          value: props.rollingStock.axisValues?.[String(axisNumber)] ?? 0,
        }))}
        onCommit={props.onSetAxis}
      />
    </Box>
  );
}

function sortedNumberKeys(...records: Array<Record<string, unknown> | undefined>): number[] {
  const numbers = new Set<number>();
  records.forEach((record) => {
    Object.keys(record ?? {}).forEach((key) => {
      const numberKey = Number(key);
      if (Number.isFinite(numberKey)) {
        numbers.add(numberKey);
      }
    });
  });

  return Array.from(numbers).sort((left, right) => left - right);
}

export default TrainRollingStockView;
