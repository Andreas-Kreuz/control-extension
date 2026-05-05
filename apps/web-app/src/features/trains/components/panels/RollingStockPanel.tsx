import { RollingStockAppDto } from '@ce/web-shared';
import Box from '@mui/material/Box';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Typography from '@mui/material/Typography';
import { AxisList } from '../../../../shared/components/controls';
import { ModelEntry, NameEntry, TagEntry } from '../../../../shared/components/iconlist';
import BreakableModelValue from './BreakableModelValue';

export interface RollingStockAxisPanelEntry {
  axisNumber: number;
  name: string;
  value: number;
}

export interface RollingStockTexturePanelEntry {
  textureNumber: number;
  name: string;
  value: string;
}

export interface RollingStockPanelItem {
  rollingStock: RollingStockAppDto;
  axisEntries: RollingStockAxisPanelEntry[];
  textureEntries: RollingStockTexturePanelEntry[];
}

function RollingStockPanel(props: {
  items: RollingStockPanelItem[] | undefined;
  onAxisCommit: (rollingStock: RollingStockAppDto, axisNumber: number, value: number) => void;
}) {
  if (!props.items?.length) {
    return <Typography color="textSecondary">Keine RollingStocks gefunden.</Typography>;
  }

  return (
    <List disablePadding sx={{ containerType: 'inline-size' }}>
      {props.items.map((item) => (
        <RollingStockPanelRow
          key={item.rollingStock.id}
          item={item}
          onAxisCommit={(axisNumber: number, value: number) => props.onAxisCommit(item.rollingStock, axisNumber, value)}
        />
      ))}
    </List>
  );
}

export function RollingStockPanelRow(props: {
  item: RollingStockPanelItem;
  onAxisCommit: (axisNumber: number, value: number) => void;
}) {
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
      <Box sx={{ width: 1, gap: 2 }}>
        <NameEntry value={props.item.rollingStock.name} />
        <TagEntry value={props.item.rollingStock.tag || '-'} />
        <ModelEntry value={<BreakableModelValue value={props.item.rollingStock.xmlModel || '-'} />} />
        <TextureTextList entries={props.item.textureEntries} />
        <RollingStockAxisList entries={props.item.axisEntries} onCommit={props.onAxisCommit} />
      </Box>
    </ListItem>
  );
}

function RowCell(props: { label: string; value: string }) {
  return (
    <Box sx={{ minWidth: 0, textAlign: 'left', justifySelf: 'start' }}>
      <Typography variant="caption" color="textSecondary" align="left">
        {props.label}
      </Typography>
      <Typography
        variant="body2"
        align="left"
        sx={{
          whiteSpace: 'nowrap',
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          wordBreak: 'break-word',
        }}
      >
        {props.value}
      </Typography>
    </Box>
  );
}

function TextureTextList(props: { entries: RollingStockTexturePanelEntry[] }) {
  if (props.entries.length === 0) {
    return <RowCell label="TextureTexts" value="-" />;
  }

  return (
    <Box sx={{ minWidth: 0, textAlign: 'left', justifySelf: 'stretch' }}>
      <Typography variant="caption" color="textSecondary" align="left">
        TextureTexts
      </Typography>
      <Box sx={{ display: 'grid', gap: 0.5 }}>
        {props.entries.map((entry) => (
          <Typography
            key={entry.textureNumber}
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
              {entry.textureNumber}:
            </Box>
            <Box component="span" sx={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {entry.name}
            </Box>
            <Box component="span" sx={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {entry.value}
            </Box>
          </Typography>
        ))}
      </Box>
    </Box>
  );
}

function RollingStockAxisList(props: {
  entries: RollingStockAxisPanelEntry[];
  onCommit: (axisNumber: number, value: number) => void;
}) {
  if (props.entries.length === 0) {
    return <RowCell label="Achsen" value="-" />;
  }

  return (
    <Box sx={{ minWidth: 0, textAlign: 'left', justifySelf: 'stretch' }}>
      <Typography variant="caption" color="textSecondary" align="left">
        Achsen
      </Typography>
      <AxisList entries={props.entries} onCommit={props.onCommit} />
    </Box>
  );
}

export default RollingStockPanel;
