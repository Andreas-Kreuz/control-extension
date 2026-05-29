import * as assert from 'node:assert/strict';
import EepDataStore, { DataTransferState } from './EepDataStore';
import EepDataEvent from './EepDataEvent';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function applyEvents(events: Array<Omit<EepDataEvent, 'payload'> & { payload: unknown }>): EepDataStore {
  const store = new EepDataStore();
  for (const event of events) {
    store.onNewEvent(event as EepDataEvent);
  }
  return store;
}

function dataTransferOf(store: EepDataStore): DataTransferState {
  const dataTransfer = store.currentState().dataTransfer;
  assert.ok(dataTransfer);
  return dataTransfer;
}

function testPartialUpdatesCountOnlyPayloadFields(): void {
  const store = applyEvents([
    {
      eventCounter: 1,
      type: 'DataChanged',
      payload: { ceType: 'ce.test', keyId: 'id', element: { id: 'entry-1', value: 'alpha' } },
    },
    {
      eventCounter: 2,
      type: 'DataChanged',
      payload: { ceType: 'ce.test', keyId: 'id', element: { id: 'entry-1', other: 'beta' } },
    },
  ]);

  const dataTransfer = dataTransferOf(store);

  assert.deepEqual(dataTransfer.totals['ce.test'], {
    updateCount: 2,
    initialUpdateCount: 1,
    fields: { id: 2, value: 1, other: 1 },
  });
  assert.deepEqual(dataTransfer.last?.ceTypes['ce.test'], {
    updateCount: 1,
    initialUpdateCount: 0,
    fields: { id: 1, other: 1 },
  });
}

function testListChangesCountFieldOccurrences(): void {
  const store = applyEvents([
    {
      eventCounter: 1,
      type: 'ListChanged',
      payload: {
        ceType: 'ce.test',
        keyId: 'id',
        list: {
          first: { id: 'first', value: 'alpha' },
          second: { id: 'second', value: 'beta', extra: true },
        },
      },
    },
  ]);

  const dataTransfer = dataTransferOf(store);

  assert.deepEqual(dataTransfer.totals['ce.test'], {
    updateCount: 1,
    initialUpdateCount: 1,
    fields: { id: 2, value: 2, extra: 1 },
  });
  assert.deepEqual(dataTransfer.last?.ceTypes['ce.test']?.fields, { id: 2, value: 2, extra: 1 });
}

function testLastTransferAggregatesAppendedEvents(): void {
  const store = new EepDataStore();
  store.onNewEvent({
    eventCounter: 1,
    type: 'DataChanged',
    payload: { ceType: 'ce.first', keyId: 'id', element: { id: 'entry-1', value: 'alpha' } },
  } as EepDataEvent);
  store.onNewEvent(
    {
      eventCounter: 2,
      type: 'DataChanged',
      payload: { ceType: 'ce.first', keyId: 'id', element: { id: 'entry-2', other: 'beta' } },
    } as EepDataEvent,
    { appendToLastTransfer: true },
  );
  store.onNewEvent(
    {
      eventCounter: 3,
      type: 'DataChanged',
      payload: { ceType: 'ce.second', keyId: 'id', element: { id: 'entry-3', value: 'gamma' } },
    } as EepDataEvent,
    { appendToLastTransfer: true },
  );

  const dataTransfer = dataTransferOf(store);

  assert.equal(dataTransfer.last?.eventCounter, 3);
  assert.deepEqual(dataTransfer.last?.ceTypes['ce.first'], {
    updateCount: 2,
    initialUpdateCount: 1,
    fields: { id: 2, value: 1, other: 1 },
  });
  assert.deepEqual(dataTransfer.last?.ceTypes['ce.second'], {
    updateCount: 1,
    initialUpdateCount: 1,
    fields: { id: 1, value: 1 },
  });
}

function testRemovedDataIsNotInitialData(): void {
  const store = applyEvents([
    {
      eventCounter: 1,
      type: 'DataRemoved',
      payload: { ceType: 'ce.test', keyId: 'id', element: { id: 'entry-1' } },
    },
  ]);

  const dataTransfer = dataTransferOf(store);

  assert.deepEqual(dataTransfer.seenCeTypes, {});
  assert.deepEqual(dataTransfer.totals['ce.test'], {
    updateCount: 1,
    initialUpdateCount: 0,
    fields: { id: 1 },
  });
}

function testCompleteResetClearsDataTransferCounters(): void {
  const store = applyEvents([
    {
      eventCounter: 1,
      type: 'DataChanged',
      payload: { ceType: 'ce.test', keyId: 'id', element: { id: 'entry-1', value: 'alpha' } },
    },
    { eventCounter: 2, type: 'CompleteReset', payload: undefined },
  ]);

  assert.deepEqual(dataTransferOf(store), {
    seenCeTypes: {},
    totals: {},
  });
}

function testOldCacheStateIsMigrated(): void {
  const store = new EepDataStore();

  store.init({ eventCounter: 0, ceTypes: { 'ce.test': { entry: { id: 'entry' } } } });

  assert.deepEqual(dataTransferOf(store), {
    seenCeTypes: {},
    totals: {},
  });
}

export async function run(): Promise<void> {
  await runTest('EepDataStore counts partial payload fields only', testPartialUpdatesCountOnlyPayloadFields);
  await runTest('EepDataStore counts list replacement field occurrences', testListChangesCountFieldOccurrences);
  await runTest(
    'EepDataStore aggregates appended events into the last transfer',
    testLastTransferAggregatesAppendedEvents,
  );
  await runTest('EepDataStore does not count removals as initial data', testRemovedDataIsNotInitialData);
  await runTest(
    'EepDataStore clears data transfer counters on CompleteReset',
    testCompleteResetClearsDataTransferCounters,
  );
  await runTest('EepDataStore migrates old cache state without counters', testOldCacheStateIsMigrated);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
