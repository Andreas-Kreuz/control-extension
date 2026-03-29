import useRollingStocks from './useRollingStocks';
import { RollingStockDto } from '@ak/web-shared';

function useRollingStock(name: string): RollingStockDto | undefined {
  const rollingStockRecord = useRollingStocks();
  return rollingStockRecord[name];
}

export default useRollingStock;
