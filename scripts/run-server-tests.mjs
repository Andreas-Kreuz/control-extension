import { execFileSync } from 'node:child_process';
import { readdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const buildDir = path.join(repoRoot, 'apps', 'web-server', 'build');

const testFiles = readdirSync(buildDir, { recursive: true, withFileTypes: true })
  .filter((entry) => entry.isFile() && entry.name.endsWith('.test.js'))
  .map((entry) => path.join(entry.parentPath ?? entry.path, entry.name))
  .sort();

if (testFiles.length === 0) {
  console.error('No compiled server tests found below apps/web-server/build.');
  process.exit(1);
}

for (const testFile of testFiles) {
  const relativePath = path.relative(repoRoot, testFile);
  console.log(`[test:server] ${relativePath}`);
  execFileSync(process.execPath, [testFile], { stdio: 'inherit', cwd: repoRoot });
}

console.log(`[test:server] Ran ${testFiles.length} test files.`);
