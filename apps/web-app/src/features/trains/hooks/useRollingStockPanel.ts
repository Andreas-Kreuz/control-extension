import { RollingStockAppDto } from '@ce/web-shared';
import type { RollingStockPanelItem } from '../components/panels/RollingStockPanel';
import { sortedNumberKeys } from '../lib/trainDashboard';
import useRollingStockDynamic from './useRollingStockDynamic';
import useSetRollingStockAxis from './useSetRollingStockAxis';

export function createRollingStockPanelItem(rollingStock: RollingStockAppDto): RollingStockPanelItem {
  return {
    rollingStock,
    textureEntries: sortedNumberKeys(rollingStock.textureNames, rollingStock.surfaceTexts).map((textureNumber) => ({
      textureNumber,
      name: rollingStock.textureNames?.[String(textureNumber)] ?? `TextureText ${textureNumber}`,
      value: rollingStock.surfaceTexts?.[String(textureNumber)] ?? '',
    })),
    axisEntries: sortedNumberKeys(rollingStock.axisNames, rollingStock.axisValues).map((axisNumber) => ({
      axisNumber,
      name: rollingStock.axisNames?.[String(axisNumber)] ?? `Achse ${axisNumber}`,
      value: rollingStock.axisValues?.[String(axisNumber)] ?? 0,
    })),
  };
}

function useRollingStockPanel(rollingStock: RollingStockAppDto) {
  const dynamicRollingStock = useRollingStockDynamic(rollingStock.id);
  const setAxis = useSetRollingStockAxis();
  const resolvedRollingStock = dynamicRollingStock ?? rollingStock;

  return {
    item: createRollingStockPanelItem(resolvedRollingStock),
    onAxisCommit: (axisNumber: number, value: number) => setAxis(resolvedRollingStock, axisNumber, value),
  };
}

export default useRollingStockPanel;
