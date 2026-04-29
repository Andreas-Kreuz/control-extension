import * as assert from 'node:assert/strict';
import { CeTypes } from '@ce/web-shared';
import EepDataStore from '../../eep/server-data/EepDataStore';
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
          axisNames: { '2': 'Fahrer' },
          axisValues: { '2': 75 },
          textureNames: { '1': 'Fahrziel' },
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
    axisNames: { '2': 'Fahrer' },
    axisValues: { '2': 75 },
    surfaceTexts: {},
    textureNames: { '1': 'Fahrziel' },
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
    lights: { '0': false, '1': false, '2': false, '3': false },
    active: false,
    inTrainyard: false,
    movesForward: true,
    trainyardId: 'Depot-A',
  });
}

function testTrainSelectorMapsLights(): void {
  const selector = new TrainSelector(new RollingStockSelector());
  selector.updateFromState({
    ceTypes: {
      [CeTypes.HubTrain]: {
        T1: {
          id: 'T1',
          name: 'Train 1',
          lights: { '0': true, '1': false, '2': true, '3': false },
        },
      },
    },
  } as never);

  assert.deepEqual(selector.getTrain('T1')?.lights, { '0': true, '1': false, '2': true, '3': false });
}

function testRollingStockSelectorNormalizesLuaArraysToOneBasedRecords(): void {
  const selector = new RollingStockSelector();
  selector.updateFromState({
    ceTypes: {
      [CeTypes.HubRollingStock]: {
        RS1: {
          id: 'RS1',
          name: 'Wagon 1',
          textureNames: ['Front', 'Side'],
          surfaceTexts: ['A', 'B'],
          axisNames: ['Driver'],
          axisValues: [50],
        },
      },
    },
  } as never);

  assert.deepEqual(selector.getRollingStock('RS1')?.textureNames, { '1': 'Front', '2': 'Side' });
  assert.deepEqual(selector.getRollingStock('RS1')?.surfaceTexts, { '1': 'A', '2': 'B' });
  assert.deepEqual(selector.getRollingStock('RS1')?.axisNames, { '1': 'Driver' });
  assert.deepEqual(selector.getRollingStock('RS1')?.axisValues, { '1': 50 });
}

function testRollingStockSelectorMapsMergedLuaPatchAxisValues(): void {
  const store = new EepDataStore();
  const selector = new RollingStockSelector();

  store.onNewEvent({
    type: 'DataChanged',
    eventCounter: 1,
    payload: {
      ceType: CeTypes.HubRollingStock,
      keyId: 'id',
      element: {
        id: 'RS1',
        name: 'Wagon 1',
        trainName: 'Train 1',
        positionInTrain: 0,
        axisNames: { '2': 'Fahrer' },
        axisValues: { '2': 25 },
      },
    },
  } as never);
  selector.updateFromState(store.currentState());
  assert.deepEqual(selector.getRollingStock('RS1')?.axisValues, { '2': 25 });

  store.onNewEvent({
    type: 'DataChanged',
    eventCounter: 2,
    payload: {
      ceType: CeTypes.HubRollingStock,
      keyId: 'id',
      element: {
        id: 'RS1',
        axisValues: { '2': 80 },
      },
    },
  } as never);
  selector.updateFromState(store.currentState());

  const rollingStock = selector.getRollingStock('RS1');
  assert.equal(rollingStock?.trainName, 'Train 1');
  assert.deepEqual(rollingStock?.axisNames, { '2': 'Fahrer' });
  assert.deepEqual(rollingStock?.axisValues, { '2': 80 });
}

function testTrainSelectorMapsTransitNextStations(): void {
  const selector = new TrainSelector(new RollingStockSelector());
  selector.updateFromState({
    ceTypes: {
      [CeTypes.HubTrain]: {
        T1: {
          id: 'T1',
          name: 'Train 1',
        },
      },
      [CeTypes.TransitTrain]: {
        T1: {
          id: 'T1',
          line: '10',
          destination: 'Central',
          nextStations: [{ station: { name: 'Station A', platform: '2' }, departureInMinutes: 3 }],
        },
      },
    },
  } as never);

  assert.deepEqual(selector.getTrain('T1')?.nextStations, [
    { station: { name: 'Station A', platform: '2' }, departureInMinutes: 3 },
  ]);
}

export async function run(): Promise<void> {
  await runTest('rolling stock selector preserves xmlModel', testRollingStockSelectorPreservesXmlModel);
  await runTest(
    'rolling stock selector normalizes Lua arrays to one-based records',
    testRollingStockSelectorNormalizesLuaArraysToOneBasedRecords,
  );
  await runTest(
    'rolling stock selector maps merged Lua patch axis values',
    testRollingStockSelectorMapsMergedLuaPatchAxisValues,
  );
  await runTest('train selector preserves string trainyardId', testTrainSelectorPreservesStringTrainyardId);
  await runTest('train selector maps lights', testTrainSelectorMapsLights);
  await runTest('train selector maps transit next stations', testTrainSelectorMapsTransitNextStations);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
