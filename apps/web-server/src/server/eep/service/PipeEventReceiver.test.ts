import * as assert from 'node:assert/strict';
import * as net from 'node:net';
import { PipeEventReceiver } from './PipeEventReceiver';
import { ServerPipeNameFactory } from './ServerPipeNameFactory';
import { setTimeout as delay } from 'node:timers/promises';

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

async function testIngestsNdjsonLines(): Promise<void> {
  const pipeIdentity = ServerPipeNameFactory.create();
  const seenLines: string[] = [];
  const receiver = new PipeEventReceiver(pipeIdentity.pipeName, (line) => seenLines.push(line));

  try {
    receiver.start();
    await delay(25);

    await new Promise<void>((resolve, reject) => {
      const socket = net.createConnection(pipeIdentity.pipeName, () => {
        socket.write('{"eventCounter":1}\n{"eventCounter":2}\n');
        socket.end();
      });
      socket.on('close', () => resolve());
      socket.on('error', reject);
    });

    await waitFor(() => {
      assert.deepEqual(seenLines, ['{"eventCounter":1}', '{"eventCounter":2}']);
    });
  } finally {
    receiver.stop();
  }
}

async function testBuffersFragmentedJsonLine(): Promise<void> {
  const pipeIdentity = ServerPipeNameFactory.create();
  const seenLines: string[] = [];
  const receiver = new PipeEventReceiver(pipeIdentity.pipeName, (line) => seenLines.push(line));

  try {
    receiver.start();
    await delay(25);

    await new Promise<void>((resolve, reject) => {
      const socket = net.createConnection(pipeIdentity.pipeName, async () => {
        const line = JSON.stringify({
          eventCounter: 1,
          payload: 'x'.repeat(512),
        });
        socket.write(line.slice(0, 200));
        await delay(50);
        assert.deepEqual(seenLines, []);
        socket.write(line.slice(200) + '\n');
        socket.end();
      });
      socket.on('close', () => resolve());
      socket.on('error', reject);
    });

    await waitFor(() => {
      assert.equal(seenLines.length, 1);
      assert.equal(JSON.parse(seenLines[0]!).eventCounter, 1);
    });
  } finally {
    receiver.stop();
  }
}

export async function run(): Promise<void> {
  await runTest('PipeEventReceiver ingests newline-delimited events', testIngestsNdjsonLines);
  await runTest('PipeEventReceiver buffers fragmented JSON lines', testBuffersFragmentedJsonLine);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
