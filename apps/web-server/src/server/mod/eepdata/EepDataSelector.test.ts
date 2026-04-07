import * as assert from 'node:assert/strict';
import { CeTypes } from '@ce/web-shared';
import type { State } from '../../eep/server-data/EepDataStore';
import EepDataSelector from './EepDataSelector';

function makeRuntimeEntry(id: string, time: number) {
  return { id, count: 1, time, lastTime: time };
}

function makeState(eventCounter: number, runtimeEntries: Record<string, unknown>): State {
  return {
    eventCounter,
    ceTypes: {
      [CeTypes.HubRuntime]: runtimeEntries,
    },
  };
}

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function testRuntimeStatisticsHistoryCachesOnlyChangedSamplesAndKeepsLastTen(): void {
  const selector = new EepDataSelector();

  selector.updateFromState(
    makeState(1, {
      'Update/ce.hub.Module': makeRuntimeEntry(
        'Update/ce.hub.Module',
        1,
      ),
      'Discovery/ce.hub.Signal': makeRuntimeEntry('Discovery/ce.hub.Signal', 2),
      'MainLoopRunner.runCycle-5-commands': makeRuntimeEntry('MainLoopRunner.runCycle-5-commands', 3),
    }),
  );
  selector.updateFromState(
    makeState(2, {
      'Update/ce.hub.Module': makeRuntimeEntry(
        'Update/ce.hub.Module',
        1,
      ),
      'Discovery/ce.hub.Signal': makeRuntimeEntry('Discovery/ce.hub.Signal', 2),
      'MainLoopRunner.runCycle-5-commands': makeRuntimeEntry('MainLoopRunner.runCycle-5-commands', 3),
    }),
  );

  for (let eventCounter = 3; eventCounter <= 14; eventCounter += 1) {
    selector.updateFromState(
      makeState(eventCounter, {
        'Update/ce.hub.Module': makeRuntimeEntry(
          'Update/ce.hub.Module',
          eventCounter,
        ),
        'Discovery/ce.hub.Signal': makeRuntimeEntry('Discovery/ce.hub.Signal', eventCounter),
        'MainLoopRunner.runCycle-5-commands': makeRuntimeEntry('MainLoopRunner.runCycle-5-commands', eventCounter),
      }),
    );
  }

  const runtimeStatistics = selector.getRuntimeStatistics();
  const firstPublisherSyncTimes = runtimeStatistics.history.publisherSyncTimes[0];
  const lastModuleRunTimes = runtimeStatistics.history.moduleRunTimes[9];
  const firstUpdateTimes = runtimeStatistics.history.updateTimes[0];
  const lastControllerUpdateTimes = runtimeStatistics.history.controllerUpdateTimes[9];
  const modulesPublisherTime = firstPublisherSyncTimes?.find((entry) => entry.id === 'ce.hub.ModulesStatePublisher');
  const moduleUpdateTime = firstUpdateTimes?.find((entry) => entry.id === 'Update/ce.hub.Module');
  const signalDiscoveryTime = lastModuleRunTimes?.find((entry) => entry.id === 'Discovery/ce.hub.Signal');
  assert.ok(firstPublisherSyncTimes);
  assert.ok(lastModuleRunTimes);
  assert.ok(firstUpdateTimes);
  assert.ok(lastControllerUpdateTimes);
  assert.ok(modulesPublisherTime);
  assert.ok(moduleUpdateTime);
  assert.ok(signalDiscoveryTime);
  assert.equal(runtimeStatistics.history.publisherSyncTimes.length, 10);
  assert.equal(runtimeStatistics.history.updateTimes.length, 10);
  assert.deepEqual(runtimeStatistics.history.sampleEventCounters, [5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
  assert.equal(modulesPublisherTime.ms, 0);
  assert.equal(moduleUpdateTime.ms, 5);
  assert.equal(signalDiscoveryTime.ms, 14);
  assert.equal(lastControllerUpdateTimes[1]?.ms, 14);
}

function testRuntimeStatisticsKeepsInitializationSeparateAndResetsOnMissingRuntime(): void {
  const selector = new EepDataSelector();

  selector.updateFromState(
    makeState(1, {
      'Update/ce.hub.Module': makeRuntimeEntry(
        'Update/ce.hub.Module',
        11,
      ),
      'Update-init/ce.hub.Module': makeRuntimeEntry(
        'Update-init/ce.hub.Module',
        11,
      ),
      'StatePublisher.ce.hub.ModulesStatePublisher.syncState': makeRuntimeEntry(
        'StatePublisher.ce.hub.ModulesStatePublisher.syncState',
        7,
      ),
      'Discovery/ce.hub.Signal': makeRuntimeEntry('Discovery/ce.hub.Signal', 12),
      'Discovery-init/ce.hub.Signal': makeRuntimeEntry('Discovery-init/ce.hub.Signal', 12),
      'Update/ce.hub.Time': makeRuntimeEntry(
        'Update/ce.hub.Time',
        13,
      ),
      'MainLoopRunner.runCycle-5-commands': makeRuntimeEntry('MainLoopRunner.runCycle-5-commands', 15),
    }),
  );

  const runtimeStatistics = selector.getRuntimeStatistics();
  const modulesPublisherTime = runtimeStatistics.history.publisherSyncTimes[0]?.find(
    (entry) => entry.id === 'ce.hub.ModulesStatePublisher',
  );
  const moduleUpdateTime = runtimeStatistics.history.updateTimes[0]?.find(
    (entry) => entry.id === 'Update/ce.hub.Module',
  );
  const signalDiscoveryTime = runtimeStatistics.history.moduleRunTimes[0]?.find(
    (entry) => entry.id === 'Discovery/ce.hub.Signal',
  );
  const moduleUpdateInitTime = runtimeStatistics.initialization.publisherInitTimes.find(
    (entry) => entry.id === 'Update-init/ce.hub.Module',
  );
  const signalDiscoveryInitTime = runtimeStatistics.initialization.moduleInitTimes.find(
    (entry) => entry.id === 'Discovery-init/ce.hub.Signal',
  );
  assert.ok(moduleUpdateInitTime);
  assert.ok(signalDiscoveryInitTime);
  assert.equal(runtimeStatistics.history.publisherSyncTimes.length, 1);
  assert.equal(runtimeStatistics.history.updateTimes.length, 1);
  assert.equal(moduleUpdateInitTime?.ms, 11);
  assert.equal(signalDiscoveryInitTime?.ms, 12);
  assert.equal(modulesPublisherTime?.ms, 7);
  assert.equal(moduleUpdateTime?.ms, 11);
  assert.equal(signalDiscoveryTime?.ms, 12);

  selector.updateFromState({ eventCounter: 2, ceTypes: {} });

  const resetStatistics = selector.getRuntimeStatistics();
  assert.deepEqual(resetStatistics.history.sampleEventCounters, []);
  assert.deepEqual(resetStatistics.initialization.publisherInitTimes, []);
  assert.deepEqual(resetStatistics.initialization.moduleInitTimes, []);
}

function testStructureDtosFromUnifiedCeType(): void {
  const selector = new EepDataSelector();

  selector.updateFromState({
    eventCounter: 1,
    ceTypes: {
      [CeTypes.HubStructure]: {
        '#7': {
          id: '#7',
          name: '#7',
          pos_x: 1,
          pos_y: 2,
          pos_z: 3,
          rot_x: 4,
          rot_y: 5,
          rot_z: 6,
          modelType: 22,
          modelTypeText: 'Immobilie',
          tag: 'Depot',
          light: true,
          smoke: false,
          fire: true,
        },
      },
    },
  });

  assert.deepEqual(selector.getStructures(), {
    '#7': {
      id: '#7',
      name: '#7',
      pos_x: 1,
      pos_y: 2,
      pos_z: 3,
      rot_x: 4,
      rot_y: 5,
      rot_z: 6,
      modelType: 22,
      modelTypeText: 'Immobilie',
      tag: 'Depot',
      light: true,
      smoke: false,
      fire: true,
    },
  });
}

function testStructureDtosWithPartialFields(): void {
  const selector = new EepDataSelector();

  selector.updateFromState({
    eventCounter: 1,
    ceTypes: {
      [CeTypes.HubStructure]: {
        '#8': {
          id: '#8',
          light: false,
          smoke: true,
          fire: false,
        },
      },
    },
  });

  assert.deepEqual(selector.getStructures(), {
    '#8': {
      id: '#8',
      name: undefined,
      pos_x: undefined,
      pos_y: undefined,
      pos_z: undefined,
      rot_x: undefined,
      rot_y: undefined,
      rot_z: undefined,
      modelType: undefined,
      modelTypeText: undefined,
      tag: undefined,
      light: false,
      smoke: true,
      fire: false,
    },
  });
}

export async function run(): Promise<void> {
  await runTest(
    'EepDataSelector caches only changed runtime statistics samples and keeps the last ten',
    testRuntimeStatisticsHistoryCachesOnlyChangedSamplesAndKeepsLastTen,
  );
  await runTest(
    'EepDataSelector keeps initialization statistics separate and resets them without runtime data',
    testRuntimeStatisticsKeepsInitializationSeparateAndResetsOnMissingRuntime,
  );
  await runTest('EepDataSelector maps unified structure ceType', testStructureDtosFromUnifiedCeType);
  await runTest(
    'EepDataSelector handles structures with partial fields',
    testStructureDtosWithPartialFields,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
