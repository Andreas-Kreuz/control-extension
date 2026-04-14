import * as assert from 'node:assert/strict';
import { CeTypes } from '@ce/web-shared';
import { RollingStockSelector } from './RollingStockSelector';
import { TrainSelector } from './TrainSelector';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function testRollingStockSelectorPreservesXmlModel(): void {
  const selector = new RollingStockSelector();
  selector.updateFromState({
    ceTypes: {
      [CeTypes.HubRollingStock]: {
        RS1: {
          id: 'RS1',
          name: 'Wagon 1',
          xmlModel: 'rollingstock/model.xml',
        },
      },
    },
  } as never);

  assert.deepEqual(selector.getRollingStock('RS1'), {
    id: 'RS1',
    name: 'Wagon 1',
    trainName: '',
    positionInTrain: 0,
    couplingFront: 0,
    couplingRear: 0,
    length: 0,
    propelled: false,
    modelType: 0,
    modelTypeText: '',
    tag: '',
    hookStatus: 0,
    hookGlueMode: 0,
    trackSystem: 0,
    trackId: 0,
    trackDistance: 0,
    trackDirection: 0,
    posX: 0,
    posY: 0,
    posZ: 0,
    mileage: 0,
    orientationForward: true,
    smoke: 0,
    active: false,
    surfaceTexts: {},
    rotX: 0,
    rotY: 0,
    rotZ: 0,
    xmlModel: 'rollingstock/model.xml',
  });
}

function testTrainSelectorPreservesStringTrainyardId(): void {
  const selector = new TrainSelector(new RollingStockSelector());
  selector.updateFromState({
    ceTypes: {
      [CeTypes.HubTrain]: {
        T1: {
          id: 'T1',
          name: 'Train 1',
          trainyardId: 'Depot-A',
        },
      },
    },
  } as never);

  assert.deepEqual(selector.getTrain('T1'), {
    id: 'T1',
    name: 'Train 1',
    route: '',
    rollingStockCount: 0,
    length: 0,
    speed: 0,
    targetSpeed: 0,
    couplingFront: 0,
    couplingRear: 0,
    active: false,
    inTrainyard: false,
    movesForward: true,
    trainyardId: 'Depot-A',
  });
}

export async function run(): Promise<void> {
  await runTest('rolling stock selector preserves xmlModel', testRollingStockSelectorPreservesXmlModel);
  await runTest('train selector preserves string trainyardId', testTrainSelectorPreservesStringTrainyardId);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
