import { spawn } from 'node:child_process';
import process from 'node:process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const scriptDir = fileURLToPath(new URL('.', import.meta.url));
const repoRoot = path.resolve(scriptDir, '..');
const webAppDir = path.join(repoRoot, 'apps', 'web-app');
const webServerDir = path.join(repoRoot, 'apps', 'web-server');
const isWindows = process.platform === 'win32';
const shellCommand = isWindows ? process.env.ComSpec || 'cmd.exe' : '/bin/sh';
const forwardedArgs = process.argv.slice(2);
if (forwardedArgs[0] === '--') {
  forwardedArgs.shift();
}
const cypressArgs = ['run', ...forwardedArgs];
const gracefulShutdownMs = 5000;
const forceShutdownMs = 5000;

let serverProcess;
let cypressProcess;
let exitSignal;
let cleanupStarted = false;

function spawnInherited(command, args, options) {
  return spawn(command, args, {
    cwd: options.cwd,
    env: options.env ?? process.env,
    stdio: 'inherit',
    windowsHide: true,
  });
}

function runCommand(label, command, args, options) {
  return new Promise((resolve, reject) => {
    const child = spawnInherited(command, args, options);

    child.on('error', reject);
    child.on('exit', (code, signal) => {
      if (signal) {
        reject(new Error(`${label} terminated by signal: ${signal}`));
        return;
      }

      if (code !== 0) {
        reject(new Error(`${label} failed with exit code ${code ?? 1}`));
        return;
      }

      resolve();
    });
  });
}

function runYarnCommand(label, args, options) {
  if (!isWindows) {
    return runCommand(label, 'yarn', args, options);
  }

  return runCommand(label, shellCommand, ['/d', '/s', '/c', ['yarn.cmd', ...args].join(' ')], options);
}

function waitForExit(child, timeoutMs) {
  if (!child || child.exitCode !== null || child.signalCode !== null) {
    return Promise.resolve(true);
  }

  return new Promise((resolve) => {
    const timer = setTimeout(() => {
      child.off('exit', onExit);
      resolve(false);
    }, timeoutMs);

    const onExit = () => {
      clearTimeout(timer);
      resolve(true);
    };

    child.once('exit', onExit);
  });
}

function taskkill(child, force) {
  if (!child?.pid) {
    return Promise.resolve();
  }

  return new Promise((resolve) => {
    const args = ['/T', ...(force ? ['/F'] : []), '/PID', String(child.pid)];
    const killer = spawn('taskkill', args, {
      stdio: 'ignore',
      windowsHide: true,
    });

    killer.on('error', resolve);
    killer.on('exit', resolve);
  });
}

async function stopChild(child, label) {
  if (!child || child.exitCode !== null || child.signalCode !== null) {
    return;
  }

  if (isWindows) {
    await taskkill(child, false);
  } else {
    child.kill('SIGTERM');
  }

  if (await waitForExit(child, gracefulShutdownMs)) {
    return;
  }

  console.error(`${label} did not exit after graceful shutdown; forcing termination.`);
  if (isWindows) {
    await taskkill(child, true);
  } else {
    child.kill('SIGKILL');
  }

  await waitForExit(child, forceShutdownMs);
}

async function cleanup() {
  if (cleanupStarted) {
    return;
  }

  cleanupStarted = true;
  await stopChild(cypressProcess, 'Cypress');
  await stopChild(serverProcess, 'Headless server');
}

function installSignalHandler(signal) {
  process.once(signal, () => {
    exitSignal = signal;
    void cleanup().finally(() => {
      process.kill(process.pid, signal);
    });
  });
}

async function runCypress() {
  return await new Promise((resolve) => {
    cypressProcess = spawnInherited(process.execPath, [path.join(repoRoot, 'scripts', 'run-cypress.mjs'), ...cypressArgs], {
      cwd: webAppDir,
    });

    cypressProcess.on('error', (error) => {
      console.error(error);
      resolve(1);
    });
    cypressProcess.on('exit', (code, signal) => {
      if (signal) {
        console.error(`Cypress terminated by signal: ${signal}`);
        resolve(1);
        return;
      }

      resolve(code ?? 1);
    });
  });
}

for (const signal of ['SIGINT', 'SIGTERM', 'SIGBREAK']) {
  installSignalHandler(signal);
}

try {
  await runCommand('prepare-cypress-io', process.execPath, [path.join(repoRoot, 'scripts', 'prepare-cypress-io.mjs')], {
    cwd: repoRoot,
  });
  await runYarnCommand('web-server TypeScript build', ['workspace', '@ce/web-server', 'exec', 'tsc'], {
    cwd: repoRoot,
  });

  serverProcess = spawnInherited(
    process.execPath,
    [
      path.join(webServerDir, 'build', 'server', 'app', 'HeadlessStart.js'),
      '--testmode',
      '--skip-server-state-persistence',
      '--port',
      '3001',
      '--exchange-dir',
      '../web-app/cypress/io',
      '--config-dir',
      '../web-app/cypress/server-config',
    ],
    {
      cwd: webServerDir,
    },
  );

  serverProcess.on('error', (error) => {
    console.error(error);
  });

  const cypressExitCode = await runCypress();
  await cleanup();

  process.exit(cypressExitCode);
} catch (error) {
  console.error(error);
  await cleanup();
  process.exit(exitSignal ? 1 : 1);
}
