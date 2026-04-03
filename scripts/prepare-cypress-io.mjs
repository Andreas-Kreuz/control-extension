import { mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

const cypressDir = path.join(repoRoot, 'apps', 'web-app', 'cypress');
const ioExchangeDir = path.join(cypressDir, 'io', 'LUA', 'ce', 'databridge', 'exchange');
mkdirSync(ioExchangeDir, { recursive: true });

const seededFiles = [
  ['commands-to-ce', ''],
  ['events-from-ce', ''],
  ['log-from-ce', ''],
  ['server-state.json', '{}'],
];

for (const [fileName, content] of seededFiles) {
  writeFileSync(path.join(ioExchangeDir, fileName), content, 'latin1');
}

console.log(`[prepare:cypress-io] ensured ${path.relative(repoRoot, ioExchangeDir)}`);
