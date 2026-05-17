import * as assert from 'node:assert/strict';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import EepService from './EepService';
import { FileNames } from './FileNames';

async function waitFor(check: () => void, timeoutMs = 2000): Promise<void> {
  const end = Date.now() + timeoutMs;
  let lastError: unknown;

  while (Date.now() < end) {
    try {
      check();
      return;
    } catch (error) {
      lastError = error;
      await delay(25);
    }
  }

  throw lastError instanceof Error ? lastError : new Error('Condition was not met in time.');
}

async function runTest(name: string, fn: () => Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

async function withService(
  runCase: (ctx: { service: EepService; tempDir: string; seenEvents: string[] }) => Promise<void>,
  beforeInit?: (ctx: { tempDir: string }) => Promise<void>,
  options?: ConstructorParameters<typeof EepService>[1],
): Promise<void> {
  const tempDir = await mkdtemp(path.join(os.tmpdir(), 'eep-service-'));
  const service = new EepService(false, options);
  const seenEvents: string[] = [];

  try {
    await writeFile(path.join(tempDir, FileNames.logFromCe), '', { encoding: 'latin1' });
    if (beforeInit) {
      await beforeInit({ tempDir });
    }

    await new Promise<void>((resolve, reject) => {
      service.reInit(tempDir, (err) => {
        if (err) {
          reject(new Error(err));
          return;
        }
        service.setOnNewEventLine((line) => seenEvents.push(line));
        resolve();
      });
    });

    await runCase({ service, tempDir, seenEvents });
  } finally {
    service.disconnect();
    await rm(tempDir, { recursive: true, force: true });
  }
}

async function testStartupIgnoresEventsFileWithoutPending(): Promise<void> {
  await withService(
    async ({ tempDir, seenEvents }) => {
      await delay(100);

      assert.deepEqual(seenEvents, []);
      assert.equal(
        await readFile(path.join(tempDir, FileNames.eventsFromCe), { encoding: 'latin1' }),
        staleEvent + '\n',
      );
      assert.equal(fs.existsSync(path.join(tempDir, FileNames.eventsFromCePending)), false);
    },
    async ({ tempDir }) => {
      await writeFile(path.join(tempDir, FileNames.eventsFromCe), staleEvent + '\n', { encoding: 'latin1' });
    },
  );
}

async function testStartupReadsPendingEventsFile(): Promise<void> {
  await withService(
    async ({ tempDir, seenEvents }) => {
      await waitFor(() => {
        assert.deepEqual(seenEvents, [pendingEvent]);
      });
      assert.equal(fs.existsSync(path.join(tempDir, FileNames.eventsFromCePending)), false);
    },
    async ({ tempDir }) => {
      await writeFile(path.join(tempDir, FileNames.eventsFromCe), pendingEvent + '\n', { encoding: 'latin1' });
      await writeFile(path.join(tempDir, FileNames.eventsFromCePending), '', { encoding: 'latin1' });
    },
  );
}

async function testWatcherReadsFuturePendingEventsFile(): Promise<void> {
  await withService(async ({ tempDir, seenEvents }) => {
    await writeFile(path.join(tempDir, FileNames.eventsFromCe), futureEvent + '\n', { encoding: 'latin1' });
    await writeFile(path.join(tempDir, FileNames.eventsFromCePending), '', { encoding: 'latin1' });

    await waitFor(() => {
      assert.deepEqual(seenEvents, [futureEvent]);
    });
    assert.equal(fs.existsSync(path.join(tempDir, FileNames.eventsFromCePending)), false);
  });
}

async function testCreatesAndReplacesPipeDescriptor(): Promise<void> {
  const tempDir = await mkdtemp(path.join(os.tmpdir(), 'eep-service-'));
  const service = new EepService(false);

  try {
    await writeFile(path.join(tempDir, FileNames.logFromCe), '', { encoding: 'latin1' });
    await new Promise<void>((resolve, reject) => {
      service.reInit(tempDir, (err) => {
        if (err) {
          reject(new Error(err));
          return;
        }
        resolve();
      });
    });

    const firstDescriptor = JSON.parse(
      await readFile(path.join(tempDir, FileNames.serverTransport), { encoding: 'latin1' }),
    ) as { eventTransport: string; pipeName: string; sessionId: string };

    assert.equal(firstDescriptor.eventTransport, 'pipe');
    assert.match(firstDescriptor.pipeName, /^\\\\\.\\pipe\\control-extension-/);
    assert.equal(typeof firstDescriptor.sessionId, 'string');

    await new Promise<void>((resolve, reject) => {
      service.reInit(tempDir, (err) => {
        if (err) {
          reject(new Error(err));
          return;
        }
        resolve();
      });
    });

    const secondDescriptor = JSON.parse(
      await readFile(path.join(tempDir, FileNames.serverTransport), { encoding: 'latin1' }),
    ) as { sessionId: string };

    assert.notEqual(secondDescriptor.sessionId, firstDescriptor.sessionId);
  } finally {
    service.disconnect();
    await rm(tempDir, { recursive: true, force: true });
  }
}

async function testDisconnectRemovesPipeDescriptor(): Promise<void> {
  const tempDir = await mkdtemp(path.join(os.tmpdir(), 'eep-service-'));
  const service = new EepService(false);

  try {
    await writeFile(path.join(tempDir, FileNames.logFromCe), '', { encoding: 'latin1' });
    await new Promise<void>((resolve, reject) => {
      service.reInit(tempDir, (err) => {
        if (err) {
          reject(new Error(err));
          return;
        }
        resolve();
      });
    });

    assert.equal(fs.existsSync(path.join(tempDir, FileNames.serverTransport)), true);
    service.disconnect();
    assert.equal(fs.existsSync(path.join(tempDir, FileNames.serverTransport)), false);
  } finally {
    service.disconnect();
    await rm(tempDir, { recursive: true, force: true });
  }
}

async function testWriteCacheCanSkipServerStatePersistence(): Promise<void> {
  await withService(
    async ({ service, tempDir }) => {
      service.writeCache({ eventCounter: 7, ceTypes: { 'ce.test': { id: { id: 'id' } } } });

      assert.equal(fs.existsSync(path.join(tempDir, FileNames.serverCache)), false);
      assert.equal(await readFile(path.join(tempDir, FileNames.serverEventCounter), { encoding: 'utf8' }), '7');
    },
    undefined,
    { persistServerState: false },
  );
}

const staleEvent = JSON.stringify({
  eventCounter: 1,
  type: 'DataChanged',
  payload: { ceType: 'ce.test', keyId: 'id', element: { id: 'stale' } },
});
const pendingEvent = JSON.stringify({
  eventCounter: 2,
  type: 'DataChanged',
  payload: { ceType: 'ce.test', keyId: 'id', element: { id: 'pending' } },
});
const futureEvent = JSON.stringify({
  eventCounter: 3,
  type: 'DataChanged',
  payload: { ceType: 'ce.test', keyId: 'id', element: { id: 'future' } },
});

export async function run(): Promise<void> {
  await runTest(
    'EepService startup ignores events-from-ce without pending marker',
    testStartupIgnoresEventsFileWithoutPending,
  );
  await runTest('EepService startup reads events-from-ce with pending marker', testStartupReadsPendingEventsFile);
  await runTest('EepService watcher reads future pending events', testWatcherReadsFuturePendingEventsFile);
  await runTest('EepService creates and replaces the pipe descriptor', testCreatesAndReplacesPipeDescriptor);
  await runTest('EepService disconnect removes the pipe descriptor', testDisconnectRemovesPipeDescriptor);
  await runTest(
    'EepService can skip server-state.json persistence while writing the counter',
    testWriteCacheCanSkipServerStatePersistence,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
