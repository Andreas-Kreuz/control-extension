import { Box } from '@mui/material';
import useTrainDashboard from '../../hooks/useTrainDashboard';
import { createRollingStockModelSummary } from '../../lib/rollingStockModelSummary';

function TrainRollingStockModelSummaryRoute() {
  const dashboard = useTrainDashboard();
  const summary =
    dashboard.status === 'ready'
      ? createRollingStockModelSummary(dashboard.train, dashboard.rollingStock)
      : dashboard.status === 'loading'
        ? 'Loading active train rolling stock model data...'
        : 'No active train or rolling stock selected.';

  return (
    <Box
      component="main"
      sx={{
        bgcolor: 'background.default',
        color: 'text.primary',
        minHeight: '100vh',
        p: 2,
      }}
    >
      <Box
        component="pre"
        sx={{
          fontFamily: 'monospace',
          fontSize: 14,
          lineHeight: 1.5,
          m: 0,
          whiteSpace: 'pre-wrap',
          wordBreak: 'break-word',
        }}
      >
        {summary}
      </Box>
    </Box>
  );
}

export default TrainRollingStockModelSummaryRoute;
