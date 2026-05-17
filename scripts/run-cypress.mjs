import { spawn } from 'node:child_process';
import { existsSync, rmSync } from 'node:fs';
import http from 'node:http';
import https from 'node:https';
import { resolve } from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const env = { ...process.env };
delete env.ELECTRON_RUN_AS_NODE;

const args = process.argv.slice(2);
const scriptDir = fileURLToPath(new URL('.', import.meta.url));
const cypressBin = resolve(scriptDir, '../node_modules/cypress/bin/cypress');
const defaultBaseUrl = 'http://localhost:3001';

function cleanCypressAssets() {
  const assetPaths = ['cypress/downloads', 'cypress/screenshots', 'cypress/videos'];

  for (const relativePath of assetPaths) {
    const absolutePath = resolve(process.cwd(), relativePath);
    if (!existsSync(absolutePath)) {
      continue;
    }

    rmSync(absolutePath, { force: true, recursive: true });
  }
}

if (args[0] === 'run') {
  cleanCypressAssets();
}

function requestBaseUrl(baseUrl) {
  return new Promise((resolveRequest, rejectRequest) => {
    const client = baseUrl.startsWith('https:') ? https : http;
    const request = client.get(baseUrl, (response) => {
      response.resume();
      resolveRequest();
    });
    request.on('error', rejectRequest);
    request.setTimeout(1000, () => {
      request.destroy(new Error(`Timed out waiting for ${baseUrl}`));
    });
  });
}

async function waitForBaseUrl(baseUrl, timeoutMs = 60000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      await requestBaseUrl(baseUrl);
      return;
    } catch (_error) {
      await new Promise((resolveWait) => setTimeout(resolveWait, 500));
    }
  }

  throw new Error(`Timed out waiting for Cypress baseUrl: ${baseUrl}`);
}

async function main() {
  if (args[0] === 'run') {
    await waitForBaseUrl(env.CYPRESS_BASE_URL ?? defaultBaseUrl);
  }

  const child = spawn(process.execPath, [cypressBin, ...args], {
    cwd: process.cwd(),
    stdio: 'inherit',
    env,
  });

  child.on('exit', (code, signal) => {
    if (signal) {
      process.kill(process.pid, signal);
      return;
    }
    process.exit(code ?? 1);
  });
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
