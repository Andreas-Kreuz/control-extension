import { RollingStockAppDto } from '@ce/web-shared';
import List from '@mui/material/List';
import Typography from '@mui/material/Typography';
import useRollingStockPanel from '../hooks/useRollingStockPanel';
import useTrainRollingStock from '../hooks/useTrainRollingStock';
import { RollingStockPanelRow } from './panels/RollingStockPanel';

function RollingStockSection({ trainId }: { trainId: string }) {
  const rollingStock = useTrainRollingStock(trainId);

  if (!rollingStock?.length) {
    return <Typography color="textSecondary">Keine RollingStocks gefunden.</Typography>;
  }

  return (
    <List disablePadding sx={{ containerType: 'inline-size' }}>
      {rollingStock.map((item) => (
        <RollingStockRowSection key={item.id} rollingStock={item} />
      ))}
    </List>
  );
}

function RollingStockRowSection(props: { rollingStock: RollingStockAppDto }) {
  const rollingStockPanel = useRollingStockPanel(props.rollingStock);

  return <RollingStockPanelRow item={rollingStockPanel.item} onAxisCommit={rollingStockPanel.onAxisCommit} />;
}

export default RollingStockSection;
