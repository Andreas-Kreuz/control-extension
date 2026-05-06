import { RollingStockAppDto } from '@ce/web-shared';

export type MergedAxisGroup = {
  name: string;
  value: number;
  targets: {
    rollingStockName: string;
    axisNumber: number;
    axisName: string;
    axisNamesKnown: boolean;
    value: number;
  }[];
};

export function isSelectedRollingStock(
  rollingStock: RollingStockAppDto,
  selectedRollingStockName: string,
): boolean {
  return rollingStock.id === selectedRollingStockName || rollingStock.name === selectedRollingStockName;
}

export function groupAxisByName(rollingStock: RollingStockAppDto[]): MergedAxisGroup[] {
  const groups = new Map<string, MergedAxisGroup>();

  rollingStock.forEach((item) => {
    sortedNumberKeys(item.axisNames, item.axisValues).forEach((axisNumber) => {
      const name = item.axisNames?.[String(axisNumber)] ?? `Achse ${axisNumber}`;
      const group = groups.get(name) ?? { name, targets: [], value: 0 };
      group.targets.push({
        rollingStockName: item.name,
        axisNumber,
        axisName: name,
        axisNamesKnown: item.axisNamesKnown,
        value: item.axisValues?.[String(axisNumber)] ?? 0,
      });
      groups.set(name, group);
    });
  });

  return Array.from(groups.values())
    .map((group) => {
      return {
        ...group,
        value: group.targets[0]?.value ?? 0,
      };
    })
    .sort((left, right) => left.name.localeCompare(right.name, 'de'));
}

export function mergeRollingStockModelInfo(
  staticRollingStock: RollingStockAppDto,
  dynamicRollingStock: RollingStockAppDto | undefined,
): RollingStockAppDto {
  if (!dynamicRollingStock) {
    return staticRollingStock;
  }

  const merged: RollingStockAppDto = {
    ...staticRollingStock,
    ...dynamicRollingStock,
    axisNamesKnown: dynamicRollingStock.axisNamesKnown === true || staticRollingStock.axisNamesKnown === true,
  };
  const axisNames = nonEmptyRecord(dynamicRollingStock.axisNames)
    ? dynamicRollingStock.axisNames
    : staticRollingStock.axisNames;
  const textureNames = nonEmptyRecord(dynamicRollingStock.textureNames)
    ? dynamicRollingStock.textureNames
    : staticRollingStock.textureNames;
  const xmlModel = dynamicRollingStock.xmlModel || staticRollingStock.xmlModel;

  if (axisNames !== undefined) {
    merged.axisNames = axisNames;
  }
  if (textureNames !== undefined) {
    merged.textureNames = textureNames;
  }
  if (xmlModel !== undefined) {
    merged.xmlModel = xmlModel;
  }

  return merged;
}

export function sortedNumberKeys(...records: Array<Record<string, unknown> | undefined>): number[] {
  const numbers = new Set<number>();
  records.forEach((record) => {
    Object.keys(record ?? {}).forEach((key) => {
      const numberKey = Number(key);
      if (Number.isFinite(numberKey)) {
        numbers.add(numberKey);
      }
    });
  });

  return Array.from(numbers).sort((left, right) => left - right);
}

export function sortedAxisKeysByName(
  axisNames: Record<string, string> | undefined,
  axisValues: Record<string, unknown> | undefined,
): number[] {
  return sortedNumberKeys(axisNames, axisValues).sort((left, right) => {
    const leftName = axisNames?.[String(left)] ?? `Achse ${left}`;
    const rightName = axisNames?.[String(right)] ?? `Achse ${right}`;
    const nameComparison = leftName.localeCompare(rightName, 'de');

    return nameComparison || left - right;
  });
}

function nonEmptyRecord(record: Record<string, unknown> | undefined): boolean {
  return Object.keys(record ?? {}).length > 0;
}
