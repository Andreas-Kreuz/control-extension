import { mkdtemp, mkdir, rm, writeFile } from 'node:fs/promises';
import * as net from 'node:net';
import * as os from 'node:os';
import * as path from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { ServerMain } from './ServerMain';
import { FileNames } from '../eep/service/FileNames';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

async function waitFor(check: () => Promise<void> | void, timeoutMs = 2000): Promise<void> {
  const end = Date.now() + timeoutMs;
  let lastError: unknown;

  while (Date.now() < end) {
    try {
      await check();
      return;
    } catch (error) {
      lastError = error;
      await delay(25);
    }
  }

  throw lastError instanceof Error ? lastError : new Error('Condition was not met in time.');
}

async function findFreePort(): Promise<number> {
  return await new Promise<number>((resolve, reject) => {
    const server = net.createServer();
    server.once('error', reject);
    server.listen(0, () => {
      const address = server.address();
      if (!address || typeof address === 'string') {
        server.close(() => reject(new Error('Could not resolve free port.')));
        return;
      }
      const port = address.port;
      server.close(() => resolve(port));
    });
  });
}

async function assertCanConnect(port: number): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    const socket = net.createConnection({ host: '127.0.0.1', port });
    socket.once('connect', () => {
      socket.end();
      resolve();
    });
    socket.once('error', reject);
    socket.setTimeout(500, () => {
      socket.destroy(new Error('Timed out waiting for server connection.'));
    });
  });
}

async function assertCanListen(port: number): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    const server = net.createServer();
    server.once('error', reject);
    server.listen(port, '127.0.0.1', () => {
      server.close(() => resolve());
    });
  });
}

async function testStopClosesHttpListener(): Promise<void> {
  const tempDir = await mkdtemp(path.join(os.tmpdir(), 'server-main-'));
  const exchangeRoot = path.join(tempDir, 'eep');
  const exchangeDir = path.join(exchangeRoot, 'LUA', 'ce', 'databridge', 'exchange');
  const configDir = path.join(tempDir, 'config');
  const port = await findFreePort();
  const originalArgv = process.argv;
  let server: ServerMain | undefined;

  try {
    await mkdir(exchangeDir, { recursive: true });
    await mkdir(configDir, { recursive: true });
    await writeFile(path.join(exchangeDir, FileNames.serverCache), JSON.stringify({ eventCounter: 0, ceTypes: {} }));
    process.argv = [
      'node',
      'server',
      '--testmode',
      '--exchange-dir',
      exchangeRoot,
      '--config-dir',
      configDir,
      '--port',
      String(port),
    ];

    server = new ServerMain(configDir, port, { allowOpenServerRoute: true, debug: false });
    server.start();
    await waitFor(() => assertCanConnect(port));

    await server.stop();
    await assertCanListen(port);
    await server.stop();
  } finally {
    process.argv = originalArgv;
    if (server) {
      await server.stop();
    }
    await rm(tempDir, { recursive: true, force: true });
  }
}

export async function run(): Promise<void> {
  await runTest('ServerMain stop closes the HTTP listener and frees the port', testStopClosesHttpListener);
}

if (require.main === module) {
  run()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}
