import * as assert from 'node:assert/strict';
import { inferTrafficLightModelConstantFromItemName } from './IntersectionWizardService';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function testInfersTrafficLightModelConstantsFromSignalItemNames(): void {
  const cases: Array<[string, string]> = [
    ['Signale\\Signale\\3erNormalMastLiFG_JS2.3dm', 'JS2_3er_mit_FG'],
    ['Signale\\Signale\\3erNormalMitte_JS2.3dm', 'JS2_3er_ohne_FG'],
    ['Signale\\Signale\\2erFGostMast_JS2.3dm', 'JS2_2er_nur_FG'],
    ['Signale\\Signale\\2erGruenGelbMast_JS2.3dm', 'JS2_2er_gelb_gruen_aus'],
    ['Signale\\Signale\\2erRotGelbMast_JS2.3dm', 'JS2_2er_rot_gelb_aus'],
    ['Signale\\Signale\\2erRotGruenMast_JS2.3dm', 'JS2_2er_rot_gruen'],
    ['Signale\\Signale\\1erLinksMast_JS2.3dm', 'JS2_1er_gruen'],
    ['Signale\\Signale\\AmpelFD_NP1.3dm', 'NP1_3er_mit_FG'],
    ['Signale\\Signale\\AmpelFE_NP1.3dm', 'NP1_3er_mit_FG'],
    ['Signale\\Signale\\AmpeloF_NP1.3dm', 'NP1_3er_ohne_FG'],
    ['Signale\\Signale\\Signal_unsichtbar.3dm', 'Unsichtbar_2er'],
  ];

  cases.forEach(([itemName, expected]) => {
    assert.equal(inferTrafficLightModelConstantFromItemName(itemName), expected, itemName);
  });
}

export async function run(): Promise<void> {
  await runTest(
    'infers traffic light model constants from signal item names',
    testInfersTrafficLightModelConstantsFromSignalItemNames,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
