import RollingStockView from './RollingStockView';
import useTrainRollingStock from '../hooks/useTrainRollingStock';

function RollingStockSection({ trainId }: { trainId: string }) {
  const rollingStock = useTrainRollingStock(trainId);
  return <RollingStockView rollingStock={rollingStock} />;
}

export default RollingStockSection;
