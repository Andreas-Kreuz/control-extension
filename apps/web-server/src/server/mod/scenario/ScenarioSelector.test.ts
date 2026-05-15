import * as assert from 'node:assert/strict';
import { CeTypes } from '@ce/web-shared';
import ScenarioSelector from './ScenarioSelector';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function testScenarioSelectorClearsWhenScenarioStateIsMissing(): void {
  const selector = new ScenarioSelector();

  selector.updateFromState({
    eventCounter: 1,
    ceTypes: {
      [CeTypes.HubScenario]: {
        scenario: {
          id: 'scenario',
          name: 'scenario',
          activeTrain: 'Train-A',
        },
      },
    },
  });

  assert.equal(selector.getScenarios().scenario?.activeTrain, 'Train-A');

  selector.updateFromState({
    eventCounter: 2,
    ceTypes: {},
  });

  assert.deepEqual(selector.getScenarios(), {});
}

export async function run(): Promise<void> {
  await runTest(
    'scenario selector clears when scenario state is missing',
    testScenarioSelectorClearsWhenScenarioStateIsMissing,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
