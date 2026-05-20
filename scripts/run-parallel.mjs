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
const shutdownGraceMs = 10000;
const forceShutdownGraceMs = 5000;

const children = new Set();
let completedChildren = 0;
let shutdownState = null;
let forcedExitTimer = null;
let finalExitTimer = null;
const shutdownErrors = [];

const taskkillChild = (child, force) => {
  const args = ['/T', ...(force ? ['/F'] : []), '/PID', String(child.pid)];
  const taskkill = spawn('taskkill', args, { stdio: 'ignore' });
  taskkill.on('error', (error) => {
    shutdownErrors.push(`taskkill ${args.join(' ')} failed for ${child.commandLabel}: ${error.message}`);
  });
  taskkill.on('exit', (code) => {
    if (code && code !== 128) {
      shutdownErrors.push(`taskkill ${args.join(' ')} exited with code ${code} for ${child.commandLabel}`);
    }
  });
};

const requestChildShutdown = (child) => {
  if (isWindows && child.pid) {
    taskkillChild(child, false);
    child.kill();
  } else {
    child.kill('SIGTERM');
  }
};

const forceChildShutdown = (child) => {
  if (isWindows && child.pid) {
    taskkillChild(child, true);
    child.kill();
  } else {
    child.kill('SIGKILL');
  }
};

const requestOthersToStop = (currentChild) => {
  for (const child of children) {
    if (child !== currentChild && !child.killed) {
      requestChildShutdown(child);
    }
  }
};

const maybeExit = () => {
  if (completedChildren === commands.length) {
    if (forcedExitTimer) {
      clearTimeout(forcedExitTimer);
      forcedExitTimer = null;
    }
    if (finalExitTimer) {
      clearTimeout(finalExitTimer);
      finalExitTimer = null;
    }
    process.exit(shutdownState?.code ?? 0);
  }
};

const reportShutdownTimeout = (label) => {
  const stillRunning = [...children].map((child) => child.commandLabel).filter(Boolean);
  if (stillRunning.length > 0) {
    console.error(`${label}: ${stillRunning.join(', ')}`);
  }
  for (const error of shutdownErrors) {
    console.error(error);
  }
  return stillRunning;
};

const startShutdown = (currentChild, code) => {
  if (!shutdownState) {
    shutdownState = { code };
    if (code !== 0) {
      console.error(`Parallel command exited with code ${code}: ${currentChild.commandLabel}`);
    }
    requestOthersToStop(currentChild);

    forcedExitTimer = setTimeout(() => {
      const stillRunning = reportShutdownTimeout('Timed out waiting for graceful parallel command shutdown');
      for (const child of children) {
        forceChildShutdown(child);
      }

      finalExitTimer = setTimeout(() => {
        reportShutdownTimeout('Timed out waiting for forced parallel command shutdown');
        process.exit(shutdownState.code);
      }, forceShutdownGraceMs);
      finalExitTimer.unref?.();

      if (stillRunning.length === 0) {
        maybeExit();
      }
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
        requestChildShutdown(child);
      }
    }
  });
}
