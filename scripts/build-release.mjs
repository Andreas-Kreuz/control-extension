import { execSync } from 'node:child_process';
import { cpSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

if (process.platform === 'darwin') {
  console.error('Windows release packaging is not supported on macOS in this repository.');
  console.error('This project does not use Wine or Rosetta for Windows release builds.');
  console.error('Run `yarn build:release` on Windows instead.');
  process.exit(1);
}

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');

function run(command, cwd = repoRoot) {
  execSync(command, { stdio: 'inherit', cwd });
}

// Build the Windows executable artifact using the public root command.
run('yarn run build:exe');

// Copy exe to lua directory
cpSync(
  path.join(repoRoot, 'apps/web-server/dist/control-extension-server.exe'),
  path.join(repoRoot, 'lua/LUA/ce/control-extension-server.exe'),
  { force: true },
);

// Create EEP installation package
run('node ./scripts/create-installer.mjs');
