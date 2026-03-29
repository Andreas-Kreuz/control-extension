import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

const packageJson = JSON.parse(readFileSync(path.join(repoRoot, 'package.json'), 'utf8'));
const version = packageJson.version;

const targets = [
  { name: 'build', description: 'Run all checks, then build Windows .exe and create EEP release package' },
  { name: 'ce-help', description: 'Print this help message' },
  { name: 'check', description: 'Run all checks: check-lua + check-e2e + check-doc' },
  { name: 'check-doc', description: 'Build Jekyll docs to detect errors (no server started)' },
  { name: 'check-e2e', description: 'Run Cypress E2E tests headless' },
  { name: 'check-lua', description: 'Run luacheck linter + busted unit tests on Lua code' },
  { name: 'check-tools', description: 'Verify that all required external tools are available in PATH' },
  { name: 'dev-app', description: 'Start Vite dev server (port 5173) + Electron server with EEP data' },
  { name: 'dev-docs', description: 'Start Jekyll documentation server with live reload (port 4000)' },
  { name: 'format', description: 'Run Prettier for web/docs files, then LuaLS formatting for Lua files' },
  {
    name: 'format-lua',
    description: 'Format all Lua files with the VSCode Lua Language Server, excluding anlagen and demo-anlagen',
  },
  { name: 'format-prettier', description: 'Run Prettier on all non-Lua project files' },
  { name: 'install', description: 'Install all dependencies (yarn built-in: run "yarn")' },
  { name: 'play', description: 'Build and start Electron server for real-life testing with EEP' },
  { name: 'rebuild-server', description: 'Build the web app and copy it into the server (no Electron restart)' },
  {
    name: 'sync-control-extension-version',
    description: 'Sync the Control Extension version into related project files',
  },
  { name: 'test-app', description: 'Start E2E test environment with Cypress interactive UI' },
];

const nameWidth = Math.max(...targets.map((t) => t.name.length));

console.log(`\nControl Extension v${version} — available yarn targets:\n`);
for (const { name, description } of targets) {
  console.log(`  yarn ${name.padEnd(nameWidth)}  ${description}`);
}
console.log('');
