import { existsSync, readdirSync, rmSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

const luaArtifacts = new Set(['.luacov', 'luacov.report.html', 'luacov.report.out', 'luacov.stats.out']);

for (const entry of readdirSync(repoRoot)) {
  if (entry.startsWith('luacov.')) {
    luaArtifacts.add(entry);
  }
}

let removedCount = 0;

for (const relativePath of luaArtifacts) {
  const absolutePath = path.join(repoRoot, relativePath);
  if (!existsSync(absolutePath)) {
    continue;
  }

  rmSync(absolutePath, { force: true, recursive: true });
  console.log(`[clean:lua] removed ${relativePath}`);
  removedCount += 1;
}

if (removedCount === 0) {
  console.log('[clean:lua] no Lua temporary artifacts found');
} else {
  console.log(`[clean:lua] removed ${removedCount} artifact path(s)`);
}
