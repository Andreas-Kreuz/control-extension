import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

const packageJson = JSON.parse(readFileSync(path.join(repoRoot, 'package.json'), 'utf8'));
const version = packageJson.version;

const groups = [
  {
    title: 'dev',
    targets: [
      { name: 'dev:app', description: 'App und Server im Entwicklungsmodus starten (automatischer re-build)' },
      { name: 'dev:docs', description: 'Jekyll-Doku-Server mit Live-Reload starten' },
      { name: 'dev:storybook', description: 'Storybook der Web-App für isolierte UI-Entwicklung starten' },
    ],
  },
  {
    title: 'run',
    targets: [{ name: 'run:app', description: 'App und Server mit build bauen und starten (ohne re-build)' }],
  },
  {
    title: 'build',
    targets: [
      { name: 'build', description: 'App und Server für den lokalen Einsatz bauen' },
      { name: 'build:win', description: 'App und Server als Windows-Artefakt bauen' },
      { name: 'build:release', description: 'App und Server sowie Lua als Release für EEP bauen' },
    ],
  },
  {
    title: 'format',
    targets: [
      { name: 'format', description: 'Gesamtes Repository formatieren' },
      { name: 'format:apps', description: 'App und Server sowie nicht-Lua-Dateien mit Prettier formatieren.' },
      {
        name: 'format:lua',
        description: 'Lua-Dateien mit dem VSCode Lua Language Server formatieren',
      },
    ],
  },
  {
    title: 'lint',
    targets: [
      { name: 'lint', description: 'Alle statischen Checks für Lua, App, Server und Shared ausführen' },
      { name: 'lint:app', description: 'ESLint für die Web-App ausführen' },
      { name: 'lint:lua', description: 'luacheck auf lua/LUA ausführen' },
      { name: 'lint:server', description: 'ESLint für den Web-Server ausführen' },
      { name: 'lint:shared', description: 'ESLint für web-shared ausführen' },
      { name: 'lint:web', description: 'Alle statischen Checks für App, Server und Shared ausführen' },
    ],
  },
  {
    title: 'test',
    targets: [
      { name: 'test', description: 'Alle implementierten Tests und Validierungen ausführen' },
      { name: 'test:lua', description: 'Lua-Tests mit busted schnell ohne Coverage ausführen' },
      { name: 'test:lua:coverage', description: 'Lua-Tests mit busted und Coverage ausführen' },
      { name: 'test:server', description: 'Server-Tests nach TypeScript-Build ausführen' },
      { name: 'test:app', description: 'Web-App-E2E-Tests headless ausführen' },
      { name: 'test:app:ui', description: 'Interaktive Cypress-E2E-Umgebung starten' },
      { name: 'test:docs', description: 'Jekyll-Doku zur Validierung bauen' },
      { name: 'test:web', description: 'Server-Tests und Web-App-E2E-Tests ausführen' },
    ],
  },
  {
    title: 'tools',
    targets: [
      { name: 'ce-help', description: 'Diese Übersicht anzeigen' },
      { name: 'tools:check', description: 'Erforderliche externe Werkzeuge in PATH prüfen' },
    ],
  },
  {
    title: 'other',
    targets: [
      { name: 'check', description: 'Manuelle Vorabprüfung vor build:release (tools:check + lint + test)' },
      { name: 'check:lua', description: 'Lua-Lint und Lua-Tests als Qualitätsgate ausführen' },
      { name: 'check:web', description: 'Web-Lints sowie Server- und App-Tests als Qualitätsgate ausführen' },
    ],
  },
];
const nameWidth = Math.max(...groups.flatMap((group) => group.targets.map((target) => target.name.length)));

console.log(`\nControl Extension v${version} — Root-Yarn-Kommandos\n`);
console.log('Bootstrap nach dem Klonen: yarn install');

for (const { title, targets } of groups) {
  console.log(`\n${title}`);
  for (const { name, description } of targets) {
    console.log(`  yarn ${name.padEnd(nameWidth)}  ${description}`);
  }
}
console.log('');
