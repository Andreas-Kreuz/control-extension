import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { AxisSlider } from '../../../../shared/components/controls';
import { MergedAxisGroup } from '../../lib/trainDashboard';

function MergedAxisPanel(props: {
  canShowTrainAxes: boolean;
  groups: MergedAxisGroup[];
  rollingStockCount: number;
  onCommit: (group: MergedAxisGroup, value: number) => void;
}) {
  if (!props.canShowTrainAxes && props.rollingStockCount > 0) {
    return (
      <Stack spacing={1}>
        <Typography variant="body2" color="textSecondary">
          Achsen im Zug sind erst verfügbar, wenn Achsnamen für alle RollingStocks bekannt sind.
        </Typography>
        <Typography color="textSecondary" variant="caption">
          Hinweis: Setze in den Control-Extension-Optionen den anl3path zur aktuellen Anlage, damit Achsnamen aus den
          Modellressourcen gelesen werden können.
        </Typography>
        <Box
          component="pre"
          sx={{
            bgcolor: 'action.hover',
            borderRadius: 1,
            color: 'text.secondary',
            fontFamily: 'monospace',
            fontSize: '0.75rem',
            m: 0,
            overflowWrap: 'anywhere',
            p: 1,
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-word',
          }}
        >{`local ControlExtension =
require("ce.ControlExtension").setOptions({
  anl3path = "C:\\\\Spiele\\\\Trend\\\\EEP18\\\\Resourcen\\\\Anlagen\\\\meine-anlage.anl3"
})`}</Box>
      </Stack>
    );
  }

  if (props.groups.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        Kein Fahrzeug in diesem Zug hat Achsen.
      </Typography>
    );
  }

  return (
    <Stack spacing={2}>
      {props.groups.map((group) => (
        <AxisSlider
          key={group.name}
          name={group.name}
          value={group.value}
          trailingLabel={`${group.targets.length}x`}
          onCommit={(value) => props.onCommit(group, value)}
        />
      ))}
    </Stack>
  );
}

export default MergedAxisPanel;
