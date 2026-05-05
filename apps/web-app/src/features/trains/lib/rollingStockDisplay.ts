import { RollingStockAppDto } from '@ce/web-shared';

export function formatHookStatus(value: number): string {
  if (value === 0) {
    return 'Haken deaktiviert';
  }
  if (value === 1) {
    return 'Haken bereit';
  }
  if (value === 3) {
    return 'Ladegut am Haken';
  }
  return `Hakenstatus ${value}`;
}

export function formatRollingStockModel(rollingStock: RollingStockAppDto): string {
  return (
    rollingStock.xmlModel ||
    rollingStock.modelTypeText ||
    (rollingStock.modelType ? String(rollingStock.modelType) : '-')
  );
}

export function formatLength(value: number): string {
  return value ? `${value} m` : '-';
}
