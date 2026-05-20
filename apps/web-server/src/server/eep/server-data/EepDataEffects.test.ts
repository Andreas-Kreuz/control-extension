import * as assert from 'node:assert/strict';
import EepDataEffects from './EepDataEffects';
import { CacheService } from './CacheService';

type CachedState = {
  eventCounter: number;
  ceTypes: Record<string, Record<string, unknown>>;
};

class TestCacheService implements CacheService {
  public writes: unknown[] = [];

  constructor(private initialState: unknown = null) {}

  writeCache(cachedData: unknown): void {
    this.writes.push(cachedData);
  }

  readCache(): unknown {
    return this.initialState;
  }
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

function createEffects(initialState: unknown = null): { effects: EepDataEffects; cache: TestCacheService } {
  const cache = new TestCacheService(initialState);
  const router = { get: () => undefined };
  const io = { to: () => ({ emit: () => undefined }) };
  const socketService = {
    addOnSocketConnectedCallback: () => undefined,
    ensureApprovedSocket: () => true,
  };

  const effects = new EepDataEffects(router as never, io as never, socketService as never, cache);
  effects.refreshStateIfRequired();
  cache.writes = [];

  return { effects, cache };
}

function lastWrittenState(cache: TestCacheService): CachedState {
  const lastWrite = cache.writes[cache.writes.length - 1] as CachedState | undefined;
  assert.ok(lastWrite);
  return lastWrite;
}

async function testExpectedCounterApplies(): Promise<void> {
  const { effects, cache } = createEffects();

  effects.onNewEventLine(
    JSON.stringify({
      eventCounter: 1,
      type: 'DataChanged',
      payload: { ceType: 'ce.test', keyId: 'id', element: { id: 'entry-1', value: 'alpha' } },
    }),
  );
  effects.refreshStateIfRequired();

  assert.equal(lastWrittenState(cache).eventCounter, 1);
  assert.deepEqual(lastWrittenState(cache).ceTypes['ce.test']?.['entry-1'], {
    id: 'entry-1',
    value: 'alpha',
  });
}

async function testCompleteResetApplies(): Promise<void> {
  const initialState: CachedState = {
    eventCounter: 5,
    ceTypes: { 'ce.test': { old: { id: 'old' } } },
  };
  const { effects, cache } = createEffects(initialState);

  effects.onNewEventLine(JSON.stringify({ eventCounter: 1, type: 'CompleteReset', payload: { info: 'lua restart' } }));
  effects.refreshStateIfRequired();

  assert.deepEqual(lastWrittenState(cache), { eventCounter: 1, ceTypes: {} });
}

async function testStaleCounterOneIsIgnored(): Promise<void> {
  const initialState: CachedState = {
    eventCounter: 5,
    ceTypes: { 'ce.test': { existing: { id: 'existing', value: 'current' } } },
  };
  const { effects, cache } = createEffects(initialState);

  effects.onNewEventLine(
    JSON.stringify({
      eventCounter: 1,
      type: 'DataChanged',
      payload: { ceType: 'ce.test', keyId: 'id', element: { id: 'stale', value: 'old' } },
    }),
  );
  effects.refreshStateIfRequired();

  assert.deepEqual(cache.writes, []);
}

async function testStopClearsRefreshTimer(): Promise<void> {
  const { effects } = createEffects();
  const timer = (effects as unknown as { refreshTimer: NodeJS.Timeout }).refreshTimer;

  effects.stop();

  assert.equal((timer as unknown as { _destroyed?: boolean })._destroyed, true);
}

export async function run(): Promise<void> {
  await runTest('EepDataEffects applies expected next event counter', testExpectedCounterApplies);
  await runTest('EepDataEffects applies CompleteReset even with reset counter', testCompleteResetApplies);
  await runTest('EepDataEffects ignores stale counter one events', testStaleCounterOneIsIgnored);
  await runTest('EepDataEffects stop clears the refresh timer', testStopClearsRefreshTimer);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
