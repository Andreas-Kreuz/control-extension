import { spawn } from 'node:child_process';
import process from 'node:process';

const commands = [
  'yarn workspace @ce/web-shared run build',
  'yarn workspace @ce/web-app run build',
  'yarn workspace @ce/web-server run build:app-assets',
];

const isWindows = process.platform === 'win32';
const shellCommand = isWindows ? process.env.ComSpec || 'cmd.exe' : '/bin/sh';
const shellArgs = (command) => (isWindows ? ['/d', '/s', '/c', command] : ['-lc', command]);

async function runCommand(command) {
  await new Promise((resolve, reject) => {
    const child = spawn(shellCommand, shellArgs(command), {
      cwd: process.cwd(),
      env: process.env,
      stdio: 'inherit',
    });

    child.on('error', reject);
    child.on('exit', (code, signal) => {
      if (signal) {
        reject(new Error(`Command terminated by signal: ${signal}`));
        return;
      }

      if (code !== 0) {
        reject(new Error(`Command failed with exit code ${code}: ${command}`));
        return;
      }

      resolve();
    });
  });
}

async function runParallelForDocAssets() {
  await new Promise((resolve, reject) => {
    const child = spawn(
      process.execPath,
      [
        './scripts/run-parallel.mjs',
        'yarn workspace @ce/web-server run run:test',
        'yarn workspace @ce/web-app exec node ../../scripts/run-cypress.mjs run --spec cypress/e2e/screenshots/*.cy.ts && node ./scripts/update-doc-assets.mjs',
      ],
      {
        cwd: process.cwd(),
        env: process.env,
        stdio: 'inherit',
      },
    );

    child.on('error', reject);
    child.on('exit', (code, signal) => {
      if (signal) {
        reject(new Error(`Parallel run terminated by signal: ${signal}`));
        return;
      }

      if (code !== 0) {
        reject(new Error(`Parallel run failed with exit code ${code}`));
        return;
      }

      resolve();
    });
  });
}

for (const command of commands) {
  await runCommand(command);
}

await runParallelForDocAssets();
