import * as assert from 'node:assert/strict';
import { inferTrafficLightModelConstantFromItemName } from './IntersectionWizardService';
import type { TrafficLightModelAppDto } from '@ce/web-shared';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function model(id: string, modelNamePatterns: string[], modelNameMatchOrder: number): TrafficLightModelAppDto {
  return {
    id,
    name: id,
    type: 'road',
    luaConstant: id,
    modelNamePatterns,
    modelNameMatchOrder,
    positionRed: 1,
    positionGreen: 2,
    positionYellow: 1,
    positionRedYellow: 1,
    positionPedestrians: 1,
    positionOff: 1,
    positionOffBlinking: 1,
  };
}

function testInfersTrafficLightModelConstantsFromDtoPatterns(): void {
  const models = {
    JS2_2er_nur_FG: model('JS2_2er_nur_FG', ['^2erfg.*_js2$', '^3erfg.*_js2$'], 1),
    JS2_3er_mit_FG: model('JS2_3er_mit_FG', ['^3er.*fg.*_js2$'], 2),
    JS2_3er_ohne_FG: model('JS2_3er_ohne_FG', ['^3er.*_js2$'], 3),
    JS2_2er_gelb_gruen_aus: model('JS2_2er_gelb_gruen_aus', ['^2ergruengelb.*_js2$'], 4),
    JS2_2er_rot_gelb_aus: model('JS2_2er_rot_gelb_aus', ['^2errotgelbausleger_js2$', '^2errotgelbmast_js2$'], 5),
    JS2_2er_rot_gelb_gruen_aus: model('JS2_2er_rot_gelb_gruen_aus', ['^2errotgelbnormal.*_js2$'], 6),
    JS2_2er_rot_gruen: model('JS2_2er_rot_gruen', ['^2errotgruen.*_js2$'], 7),
    JS2_1er_gruen: model('JS2_1er_gruen', ['^1erlinks.*_js2$'], 8),
    NP1_2er_nur_FG: model('NP1_2er_nur_FG', ['^ampel_nurfussg.*_np1$'], 9),
    NP1_3er_mit_FG: model('NP1_3er_mit_FG', ['^ampel_.*_fd_np1$', '^ampel_.*_fe_np1$'], 10),
    NP1_3er_ohne_FG: model('NP1_3er_ohne_FG', ['^ampel_.*_of.*_np1$'], 11),
    Unsichtbar_2er: model('Unsichtbar_2er', ['^signal_unsichtbar$'], 12),
  };
  const cases: Array<[string, string]> = [
    ['Signale\\Signale\\3erNormalMastLiFG_JS2.3dm', 'JS2_3er_mit_FG'],
    ['Signale\\Signale\\3erNormalMitte_JS2.3dm', 'JS2_3er_ohne_FG'],
    ['Signale\\Signale\\3erFGwestMast_JS2.3dm', 'JS2_2er_nur_FG'],
    ['Signale\\Signale\\2erFGostMast_JS2.3dm', 'JS2_2er_nur_FG'],
    ['Signale\\Signale\\2erGruenGelbMast_JS2.3dm', 'JS2_2er_gelb_gruen_aus'],
    ['Signale\\Signale\\2erRotGelbMast_JS2.3dm', 'JS2_2er_rot_gelb_aus'],
    ['Signale\\Signale\\2erRotGelbNormalMast_JS2.3dm', 'JS2_2er_rot_gelb_gruen_aus'],
    ['Signale\\Signale\\2erRotGruenMast_JS2.3dm', 'JS2_2er_rot_gruen'],
    ['Signale\\Signale\\1erLinksMast_JS2.3dm', 'JS2_1er_gruen'],
    ['Signale\\Signale\\Ampel_Einzel_FD_NP1.3dm', 'NP1_3er_mit_FG'],
    ['Signale\\Signale\\Ampel_Einzel_FE_NP1.3dm', 'NP1_3er_mit_FG'],
    ['Signale\\Signale\\Ampel_Einzel_oF_NP1.3dm', 'NP1_3er_ohne_FG'],
    ['Signale\\Signale\\Ampel_NurFussg_FD_NP1.3dm', 'NP1_2er_nur_FG'],
    ['Signale\\Signale\\Signal_unsichtbar.3dm', 'Unsichtbar_2er'],
  ];

  cases.forEach(([itemName, expected]) => {
    assert.equal(inferTrafficLightModelConstantFromItemName(itemName, models), expected, itemName);
  });
}

export async function run(): Promise<void> {
  await runTest(
    'infers traffic light model constants from DTO model name patterns',
    testInfersTrafficLightModelConstantsFromDtoPatterns,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
