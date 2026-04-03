import { existsSync, rmSync } from 'node:fs';
import path from 'node:path';

const pathsToClean = process.argv.slice(2);

if (pathsToClean.length === 0) {
  console.error('Usage: node ./scripts/clean-paths.mjs <path> [...]');
  process.exit(1);
}

let removedCount = 0;
const workspaceLabel = path.basename(process.cwd());

for (const relativePath of pathsToClean) {
  const absolutePath = path.resolve(process.cwd(), relativePath);
  if (!existsSync(absolutePath)) {
    continue;
  }

  rmSync(absolutePath, { force: true, recursive: true });
  console.log(`[clean:${workspaceLabel}] removed ${relativePath}`);
  removedCount += 1;
}

if (removedCount === 0) {
  console.log(`[clean:${workspaceLabel}] no temporary artifacts found`);
} else {
  console.log(`[clean:${workspaceLabel}] removed ${removedCount} artifact path(s)`);
}
