import TrainRollingStockView from './TrainRollingStockView';
import useTrainRollingStock from '../hooks/useTrainRollingStock';

function TrainRollingStockSection({ trainId }: { trainId: string }) {
  const rollingStock = useTrainRollingStock(trainId);
  return <TrainRollingStockView rollingStock={rollingStock} />;
}

export default TrainRollingStockSection;
