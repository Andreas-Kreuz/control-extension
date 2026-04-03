import { readdirSync, rmSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

const jekyllClean = spawnSync('bundle', ['exec', 'jekyll', 'clean'], {
  cwd: repoRoot,
  stdio: 'inherit',
});

if (jekyllClean.error || jekyllClean.status !== 0) {
  console.warn('[clean:docs] bundle exec jekyll clean was unavailable, continuing with explicit artifact cleanup');
}

const docsArtifacts = [
  '_site',
  '.sass-cache',
  ...readdirSync(repoRoot).filter((entry) => entry.startsWith('.jekyll')),
];

const uniqueArtifacts = [...new Set(docsArtifacts)];
let removedCount = 0;

for (const relativePath of uniqueArtifacts) {
  const absolutePath = path.join(repoRoot, relativePath);

  try {
    rmSync(absolutePath, { force: true, recursive: true });
    console.log(`[clean:docs] removed ${relativePath}`);
    removedCount += 1;
  } catch {
    // Ignore missing paths and keep the clean command idempotent.
  }
}

if (removedCount === 0) {
  console.log('[clean:docs] no Jekyll build artifacts found');
} else {
  console.log(`[clean:docs] removed ${removedCount} artifact path(s)`);
}
