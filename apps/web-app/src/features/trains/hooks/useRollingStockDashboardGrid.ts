import { RollingStockAppDto } from '@ce/web-shared';
import type { RollingStockDashboardCard } from '../components/panels/RollingStockDashboardGrid';
import {
  mergeRollingStockModelInfo,
  sortedAxisKeysByName,
  sortedNumberKeys,
} from '../lib/trainDashboard';
import useRollingStockDynamic from './useRollingStockDynamic';
import useSetRollingStockAxis from './useSetRollingStockAxis';

function useRollingStockDashboardGrid(
  rollingStock: RollingStockAppDto,
  position: number,
  selected: boolean,
  total: number,
): RollingStockDashboardCard {
  const dynamicRollingStock = useRollingStockDynamic(rollingStock.id);
  const mergedRollingStock = mergeRollingStockModelInfo(rollingStock, dynamicRollingStock);
  const setAxis = useSetRollingStockAxis();

  return {
    axisEntries: sortedAxisKeysByName(mergedRollingStock.axisNames, mergedRollingStock.axisValues),
    onAxisCommit: (axisNumber, value) => setAxis(mergedRollingStock, axisNumber, value),
    position,
    rollingStock: mergedRollingStock,
    selected: selected || mergedRollingStock.active,
    textureEntries: sortedNumberKeys(mergedRollingStock.textureNames, mergedRollingStock.surfaceTexts),
    total,
  };
}

export default useRollingStockDashboardGrid;
