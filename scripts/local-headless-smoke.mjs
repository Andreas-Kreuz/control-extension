import { spawn } from 'node:child_process';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const baseUrl = 'http://127.0.0.1:3001';
const probeUrls = [
  `${baseUrl}/server`,
  `${baseUrl}/api/v1/ce.server.ServerStats`,
  `${baseUrl}/api/v1/ce.server.ApiEntries`,
];

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function waitForHttp(url, timeoutMs = 30000) {
  const started = Date.now();
  while (Date.now() - started < timeoutMs) {
    try {
      const response = await fetch(url);
      if (response.ok) {
        return;
      }
    } catch {
      // Server not ready yet.
    }
    await wait(500);
  }

  throw new Error(`Timed out waiting for ${url}`);
}

function terminate(child) {
  if (!child.killed) {
    child.kill('SIGTERM');
  }
}

const server = spawn('yarn', ['workspace', '@ce/web-server', 'run', 'run:test'], {
  cwd: repoRoot,
  stdio: 'inherit',
  shell: process.platform === 'win32',
});

try {
  for (const url of probeUrls) {
    await waitForHttp(url);
  }
  console.log('Headless smoke test passed for app and server.');
} catch (error) {
  terminate(server);
  throw error;
}

terminate(server);
