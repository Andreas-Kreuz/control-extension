import { useMemo } from 'react';
import useLines from '../lines/hooks/useLines';
import useTrainDashboard from '../trains/hooks/useTrainDashboard';
import useSetRollingStockAxis from '../trains/hooks/useSetRollingStockAxis';
import CompanionPage from './components/CompanionPage';

function CompanionRoute() {
  const dashboard = useTrainDashboard();
  const lines = useLines();
  const setRollingStockAxis = useSetRollingStockAxis();
  const transitTrafficType = useMemo(() => {
    if (dashboard.status !== 'ready') {
      return undefined;
    }

    const currentLine = (dashboard.transit?.line ?? dashboard.train.line ?? '').trim();
    if (!currentLine || currentLine === '-') {
      return undefined;
    }

    return lines.find((line) => String(line.nr).trim().toLocaleLowerCase('de') === currentLine.toLocaleLowerCase('de'))
      ?.trafficType;
  }, [dashboard, lines]);

  return (
    <CompanionPage
      dashboard={dashboard}
      onRollingStockAxisCommit={setRollingStockAxis}
      transitTrafficType={transitTrafficType}
    />
  );
}

export default CompanionRoute;
