import useRollingStocks from './useRollingStocks';
import { RollingStockDto } from '@ak/web-shared';

function useRollingStock(name: string): RollingStockDto {
  const rollingStockRecord = useRollingStocks();
  return rollingStockRecord[name] || undefined;
}

export default useRollingStock;
