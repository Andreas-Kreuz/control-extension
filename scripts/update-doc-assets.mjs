import { copyFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const scriptDir = fileURLToPath(new URL('.', import.meta.url));
const repoRoot = path.resolve(scriptDir, '..');
const screenshotsRoot = path.join(repoRoot, 'apps', 'web-app', 'cypress', 'screenshots');
const docsAssetsRoot = path.join(repoRoot, 'pages', 'assets');

async function collectFiles(directoryPath) {
  const { readdir } = await import('node:fs/promises');
  const entries = await readdir(directoryPath, { withFileTypes: true });
  const filePaths = [];

  for (const entry of entries) {
    const entryPath = path.join(directoryPath, entry.name);

    if (entry.isDirectory()) {
      filePaths.push(...(await collectFiles(entryPath)));
      continue;
    }

    if (entry.isFile()) {
      filePaths.push(entryPath);
    }
  }

  return filePaths;
}

async function collectAssetDirectories(directoryPath) {
  const { readdir } = await import('node:fs/promises');
  const entries = await readdir(directoryPath, { withFileTypes: true });
  const assetDirectories = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) {
      continue;
    }

    const entryPath = path.join(directoryPath, entry.name);

    if (entry.name === 'assets') {
      assetDirectories.push(entryPath);
      continue;
    }

    assetDirectories.push(...(await collectAssetDirectories(entryPath)));
  }

  return assetDirectories;
}

async function main() {
  if (!existsSync(screenshotsRoot)) {
    console.error(`Screenshot source directory does not exist: ${screenshotsRoot}`);
    process.exit(1);
  }

  const assetDirectories = await collectAssetDirectories(screenshotsRoot);
  const copiedFiles = [];
  const skippedFiles = [];

  for (const assetDirectory of assetDirectories) {
    const sourceFiles = await collectFiles(assetDirectory);

    for (const sourceFile of sourceFiles) {
      const relativeAssetPath = path.relative(assetDirectory, sourceFile);
      const destinationFile = path.join(docsAssetsRoot, relativeAssetPath);

      if (!existsSync(destinationFile)) {
        skippedFiles.push(relativeAssetPath.replaceAll('\\', '/'));
        continue;
      }

      await copyFile(sourceFile, destinationFile);
      copiedFiles.push(relativeAssetPath.replaceAll('\\', '/'));
    }
  }

  console.log(`Updated ${copiedFiles.length} doc asset file(s).`);

  if (copiedFiles.length > 0) {
    copiedFiles.forEach((filePath) => {
      console.log(`  updated: ${filePath}`);
    });
  }

  if (skippedFiles.length > 0) {
    console.log(`Skipped ${skippedFiles.length} generated file(s) with no existing doc asset target.`);
    skippedFiles.forEach((filePath) => {
      console.log(`  skipped: ${filePath}`);
    });
  }
}

await main();
