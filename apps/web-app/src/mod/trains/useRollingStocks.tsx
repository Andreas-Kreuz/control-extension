import { useTrain } from './TrainProvider';
import { RollingStockDto } from '@ak/web-shared';

function useRollingStockDtos(): Record<string, RollingStockDto> {
  const trainStore = useTrain();
  return trainStore?.rollingStock || {};
}

export default useRollingStockDtos;
