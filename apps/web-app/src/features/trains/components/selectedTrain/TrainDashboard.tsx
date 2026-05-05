import useTrainDashboard from '../../hooks/useTrainDashboard';
import TrainDashboardPanel from '../panels/TrainDashboardPanel';
import RollingStockDashboardGridSection from './RollingStockDashboardGridSection';

function TrainDashboard() {
  const dashboard = useTrainDashboard();

  return (
    <TrainDashboardPanel
      dashboard={dashboard}
      rollingStockContent={
        dashboard.status === 'ready' && dashboard.rollingStock.length > 0 ? (
          <RollingStockDashboardGridSection
            rollingStock={dashboard.rollingStock}
            selectedRollingStockName={dashboard.selectedRollingStockName}
          />
        ) : null
      }
    />
  );
}

export default TrainDashboard;
