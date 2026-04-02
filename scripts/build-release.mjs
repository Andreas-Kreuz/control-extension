import { execSync } from 'node:child_process';
import { cpSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');

function run(command, cwd = repoRoot) {
  execSync(command, { stdio: 'inherit', cwd });
}

// Build the Windows application artifact using the public root command.
run('yarn run build:win');

// Copy exe to lua directory
cpSync(
  path.join(repoRoot, 'apps/web-server/dist/control-extension-server.exe'),
  path.join(repoRoot, 'lua/LUA/ce/control-extension-server.exe'),
  { force: true },
);

// Create EEP installation package
run('node ./scripts/create-installer.mjs');
