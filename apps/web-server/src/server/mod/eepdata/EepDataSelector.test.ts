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
      'StatePublisher.ce.hub.ModulesStatePublisher.syncState': makeRuntimeEntry(
        'StatePublisher.ce.hub.ModulesStatePublisher.syncState',
        1,
      ),
      'CeModule.ce.hub.CeHubModule.run': makeRuntimeEntry('CeModule.ce.hub.CeHubModule.run', 2),
      'MainLoopRunner.runCycle-5-commands': makeRuntimeEntry('MainLoopRunner.runCycle-5-commands', 3),
    }),
  );
  selector.updateFromState(
    makeState(2, {
      'StatePublisher.ce.hub.ModulesStatePublisher.syncState': makeRuntimeEntry(
        'StatePublisher.ce.hub.ModulesStatePublisher.syncState',
        1,
      ),
      'CeModule.ce.hub.CeHubModule.run': makeRuntimeEntry('CeModule.ce.hub.CeHubModule.run', 2),
      'MainLoopRunner.runCycle-5-commands': makeRuntimeEntry('MainLoopRunner.runCycle-5-commands', 3),
    }),
  );

  for (let eventCounter = 3; eventCounter <= 14; eventCounter += 1) {
    selector.updateFromState(
      makeState(eventCounter, {
        'StatePublisher.ce.hub.ModulesStatePublisher.syncState': makeRuntimeEntry(
          'StatePublisher.ce.hub.ModulesStatePublisher.syncState',
          eventCounter,
        ),
        'CeModule.ce.hub.CeHubModule.run': makeRuntimeEntry('CeModule.ce.hub.CeHubModule.run', eventCounter),
        'MainLoopRunner.runCycle-5-commands': makeRuntimeEntry('MainLoopRunner.runCycle-5-commands', eventCounter),
      }),
    );
  }

  const runtimeStatistics = selector.getRuntimeStatistics();
  const firstPublisherSyncTimes = runtimeStatistics.history.publisherSyncTimes[0];
  const lastModuleRunTimes = runtimeStatistics.history.moduleRunTimes[9];
  const lastControllerUpdateTimes = runtimeStatistics.history.controllerUpdateTimes[9];
  assert.ok(firstPublisherSyncTimes);
  assert.ok(lastModuleRunTimes);
  assert.ok(lastControllerUpdateTimes);
  assert.equal(runtimeStatistics.history.publisherSyncTimes.length, 10);
  assert.deepEqual(runtimeStatistics.history.sampleEventCounters, [5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
  assert.equal(firstPublisherSyncTimes[0]?.ms, 5);
  assert.equal(lastModuleRunTimes[0]?.ms, 14);
  assert.equal(lastControllerUpdateTimes[1]?.ms, 14);
}

function testRuntimeStatisticsKeepsInitializationSeparateAndResetsOnMissingRuntime(): void {
  const selector = new EepDataSelector();

  selector.updateFromState(
    makeState(1, {
      'StatePublisher.ce.hub.ModulesStatePublisher.initialize': makeRuntimeEntry(
        'StatePublisher.ce.hub.ModulesStatePublisher.initialize',
        11,
      ),
      'CeModule.ce.hub.CeHubModule.init': makeRuntimeEntry('CeModule.ce.hub.CeHubModule.init', 12),
      'StatePublisher.ce.hub.ModulesStatePublisher.syncState': makeRuntimeEntry(
        'StatePublisher.ce.hub.ModulesStatePublisher.syncState',
        13,
      ),
      'CeModule.ce.hub.CeHubModule.run': makeRuntimeEntry('CeModule.ce.hub.CeHubModule.run', 14),
      'MainLoopRunner.runCycle-5-commands': makeRuntimeEntry('MainLoopRunner.runCycle-5-commands', 15),
    }),
  );

  const runtimeStatistics = selector.getRuntimeStatistics();
  assert.equal(runtimeStatistics.initialization.publisherInitTimes[0]?.ms, 11);
  assert.equal(runtimeStatistics.initialization.moduleInitTimes[0]?.ms, 12);
  assert.equal(runtimeStatistics.history.publisherSyncTimes.length, 1);

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
