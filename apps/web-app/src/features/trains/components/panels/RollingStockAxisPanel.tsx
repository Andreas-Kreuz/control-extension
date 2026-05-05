import { RollingStockAppDto } from '@ce/web-shared';
import Typography from '@mui/material/Typography';
import { AxisList } from '../../../../shared/components/controls';

function RollingStockAxisPanel(props: {
  axisEntries: number[];
  rollingStock: RollingStockAppDto;
  onCommit: (axisNumber: number, value: number) => void;
}) {
  if (props.axisEntries.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        Dieses Fahrzeug hat keine Achsen.
      </Typography>
    );
  }

  return (
    <AxisList
      entries={props.axisEntries.map((axisNumber) => ({
        axisNumber,
        name: props.rollingStock.axisNames?.[String(axisNumber)] ?? `Achse ${axisNumber}`,
        value: props.rollingStock.axisValues?.[String(axisNumber)] ?? 0,
      }))}
      onCommit={props.onCommit}
    />
  );
}

export default RollingStockAxisPanel;
