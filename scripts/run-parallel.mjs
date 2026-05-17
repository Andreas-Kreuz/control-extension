import { spawn } from 'node:child_process';
import process from 'node:process';

const commands = process.argv.slice(2);

if (commands.length === 0) {
  console.error('Usage: node ./scripts/run-parallel.mjs <command> [...]');
  process.exit(1);
}

const isWindows = process.platform === 'win32';
const shellCommand = isWindows ? process.env.ComSpec || 'cmd.exe' : '/bin/sh';
const shellArgs = (command) => (isWindows ? ['/d', '/s', '/c', command] : ['-lc', command]);
const shutdownGraceMs = 5000;

const children = new Set();
let completedChildren = 0;
let shutdownState = null;
let forcedExitTimer = null;

const killChild = (child) => {
  if (isWindows && child.pid) {
    spawn('taskkill', ['/T', '/F', '/PID', String(child.pid)], { stdio: 'ignore' });
  } else {
    child.kill('SIGTERM');
  }
};

const killOthers = (currentChild) => {
  for (const child of children) {
    if (child !== currentChild && !child.killed) {
      killChild(child);
    }
  }
};

const maybeExit = () => {
  if (completedChildren === commands.length) {
    if (forcedExitTimer) {
      clearTimeout(forcedExitTimer);
      forcedExitTimer = null;
    }
    process.exit(shutdownState?.code ?? 0);
  }
};

const startShutdown = (currentChild, code) => {
  if (!shutdownState) {
    shutdownState = { code };
    if (code !== 0) {
      console.error(`Parallel command exited with code ${code}: ${currentChild.commandLabel}`);
    }
    killOthers(currentChild);

    forcedExitTimer = setTimeout(() => {
      const stillRunning = [...children].map((child) => child.commandLabel).filter(Boolean);
      if (stillRunning.length > 0) {
        console.error(`Timed out waiting for parallel command shutdown: ${stillRunning.join(', ')}`);
      }
      process.exit(shutdownState.code);
    }, shutdownGraceMs);

    forcedExitTimer.unref?.();
  }
};

for (const command of commands) {
  const child = spawn(shellCommand, shellArgs(command), {
    cwd: process.cwd(),
    env: process.env,
    stdio: 'inherit',
  });

  children.add(child);
  child.commandLabel = command;

  child.on('error', (error) => {
    console.error(`Failed to start command: ${command}`);
    console.error(error);
    startShutdown(child, 1);
  });

  child.on('exit', (code, signal) => {
    completedChildren += 1;
    children.delete(child);

    if (!shutdownState) {
      startShutdown(child, signal ? 1 : (code ?? 1));
    }

    maybeExit();
  });
}

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, () => {
    if (!shutdownState) {
      shutdownState = { code: 1 };
      for (const child of children) {
        killChild(child);
      }
    }
  });
}
