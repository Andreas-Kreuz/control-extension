import { RollingStockDto } from '@ce/web-shared';
import Box from '@mui/material/Box';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Typography from '@mui/material/Typography';

function TrainRollingStockView(props: { rollingStock: RollingStockDto[] | undefined }) {
  const { rollingStock } = props;

  if (!rollingStock?.length) {
    return <Typography color="text.secondary">Keine RollingStocks gefunden.</Typography>;
  }

  return (
    <List disablePadding sx={{ px: 2, pb: 2, containerType: 'inline-size' }}>
      {rollingStock.map((item) => (
        <RollingStockRow key={item.id} rollingStock={item} />
      ))}
    </List>
  );
}

function RollingStockRow(props: { rollingStock: RollingStockDto }) {
  const { rollingStock } = props;
  const textureText = formatTextureTexts(rollingStock.surfaceTexts);

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
          display: 'grid',
          gridTemplateColumns: '1fr',
          '@container (min-width: 560px)': {
            gridTemplateColumns: 'minmax(160px, 1fr) minmax(180px, 1fr) minmax(260px, 2fr)',
          },
          gap: 2,
        }}
      >
        <RowCell label="Name" value={rollingStock.name} />
        <RowCell label="TagText" value={rollingStock.tag || '-'} />
        <RowCell label="TextureTexts" value={textureText} multiline={textureText.includes('\n')} />
      </Box>
    </ListItem>
  );
}

function RowCell(props: { label: string; value: string; multiline?: boolean }) {
  return (
    <Box sx={{ minWidth: 0, textAlign: 'left', justifySelf: 'start' }}>
      <Typography variant="caption" color="text.secondary" align="left">
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

function formatTextureTexts(surfaceTexts: RollingStockDto['surfaceTexts']): string {
  const entries = Object.entries(surfaceTexts ?? {});
  if (entries.length === 0) {
    return '-';
  }

  return entries.map(([key, value]) => `${key}: ${value}`).join('\n');
}

export default TrainRollingStockView;
