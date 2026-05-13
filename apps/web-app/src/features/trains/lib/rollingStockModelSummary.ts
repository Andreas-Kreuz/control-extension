import { type RollingStockAppDto, type TrainAppDto } from '@ce/web-shared';
import { sortedNumberKeys } from './trainDashboard';

export function createRollingStockModelSummary(train: TrainAppDto, rollingStock: RollingStockAppDto[]): string {
  const uniqueRollingStock = collectUniqueRollingStock(rollingStock);

  if (uniqueRollingStock.length === 0) {
    return 'No rolling stock is available for the active train yet.';
  }

  return [
    'Copy/paste prompt for a future Codex call',
    '',
    ...createPromptLines(train),
    '',
    'Active train RollingStockModel source data',
    `Train: ${train.name}`,
    '',
    ...uniqueRollingStock.flatMap((item, index) => createRollingStockBlock(item, index + 1)),
  ].join('\n');
}

function createPromptLines(train: TrainAppDto): string[] {
  return [
    'Goal: Create a Lua RollingStockModel class for the rolling stock blocks below.',
    '',
    'Use this repository context:',
    '- Follow AGENTS.md for repository and domain-specific instructions.',
    '- Use lua/LUA/ce/hub/data/rollingstock/ModelV15NMA10013.lua and MODELV15NJS20220.lua as examples.',
    '- Base class: require("ce.hub.data.rollingstock.RollingStockModel").',
    '- Put the new model file under lua/LUA/ce/hub/data/rollingstock/Model*.lua.',
    '- Register every visible rolling stock name and every listed .3dm path in the model module register(registry) function.',
    '',
    'Implementation rules:',
    '- Preserve axis names exactly as listed and put one axis name per line in axisNames.',
    '- Convert texture names to textureTexts with the same numeric indexes.',
    '- setLine should write to textures whose name indicates Linie or Liniennummer.',
    '- setDestination should write to textures whose name indicates Fahrziel or destination.',
    '- setLicencePlate should write to textures whose name indicates Nummernschild or licence plate.',
    '- setWagonNumber should write to textures whose name indicates Wagennummer or vehicle number.',
    '- Keep setWagonNr as a compatibility alias when needed.',
    '- openDoors should set all door axes from the block to 100; closeDoors should set those same axes to 0.',
    '- Door axes are axis names containing Tuer, Tur, or their German umlaut spelling.',
    '- Keep no-op methods for unsupported features rather than guessing unrelated behavior.',
    '- If multiple blocks share the same behavior, use a local factory function to avoid duplication.',
    '- Keep the Lua file Latin1-compatible and use project style from the existing model files.',
    '',
    'Verify after editing:',
    '- python scripts/latin1_check.py <new-lua-file>',
    '- luacheck --config lua/.luacheckrc <new-lua-file>',
    '- busted --config-file lua/.busted --verbose -- spec/ce/hub/data/rollingstock/RollingStockModels_spec.lua',
    '',
    `Source train: ${train.name}`,
    '',
    'Rolling stock blocks:',
  ];
}

function collectUniqueRollingStock(rollingStock: RollingStockAppDto[]): RollingStockAppDto[] {
  const seen = new Set<string>();

  return rollingStock.filter((item) => {
    const key = [
      item.xmlModel,
      item.modelTypeText,
      JSON.stringify(item.axisNames ?? {}),
      JSON.stringify(item.textureNames ?? {}),
    ].join('\n');

    if (seen.has(key)) {
      return false;
    }

    seen.add(key);
    return true;
  });
}

function createRollingStockBlock(rollingStock: RollingStockAppDto, blockNumber: number): string[] {
  return [
    `Rolling stock block ${blockNumber}`,
    `Rolling stock name: ${rollingStock.name}`,
    `Model type: ${rollingStock.modelTypeText || rollingStock.modelType}`,
    `3dm name: ${rollingStock.xmlModel || '(unknown)'}`,
    'Axis names:',
    ...createNamedLines(rollingStock.axisNames, 'axis'),
    'Texture names:',
    ...createNamedLines(rollingStock.textureNames, 'texture'),
    '',
  ];
}

function createNamedLines(names: Record<string, string> | undefined, fallbackLabel: string): string[] {
  const keys = sortedNumberKeys(names);

  if (keys.length === 0) {
    return [`- No ${fallbackLabel} names reported.`];
  }

  return keys.map((key) => `- ${key}: ${names?.[String(key)] ?? ''}`);
}
