import { copyFile, mkdir, readdir, readFile, rm } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const scriptDir = fileURLToPath(new URL('.', import.meta.url));
const repoRoot = path.resolve(scriptDir, '..');
const pagesRoot = path.join(repoRoot, 'pages');
const docsRoot = path.join(pagesRoot, 'docs');
const generatedAssetsRoot = path.join(pagesRoot, 'assets', 'generated');
const screenshotsRoot = path.join(repoRoot, 'apps', 'web-app', 'cypress', 'screenshots');
const generatedAssetUrlPattern = /\/assets\/generated\/([a-z0-9][a-z0-9.-]*\.png)/g;

async function collectFiles(directoryPath, predicate) {
  const entries = await readdir(directoryPath, { withFileTypes: true });
  const filePaths = [];

  for (const entry of entries) {
    const entryPath = path.join(directoryPath, entry.name);

    if (entry.isDirectory()) {
      filePaths.push(...(await collectFiles(entryPath, predicate)));
      continue;
    }

    if (entry.isFile() && (!predicate || predicate(entryPath))) {
      filePaths.push(entryPath);
    }
  }

  return filePaths;
}

function isGeneratedScreenshotSource(filePath) {
  const normalizedPath = filePath.split(path.sep).join('/');
  return normalizedPath.includes('/assets/generated/') && normalizedPath.endsWith('.png');
}

function isDocsFile(filePath) {
  return !filePath.split(path.sep).join('/').includes('/_site/');
}

function isPagesHtmlFile(filePath) {
  const relativePath = path.relative(pagesRoot, filePath).split(path.sep).join('/');
  return relativePath.endsWith('.html');
}

async function collectReferencedGeneratedAssets() {
  const filesToScan = new Set();
  filesToScan.add(path.join(pagesRoot, 'index.html'));

  const pageFiles = await collectFiles(pagesRoot, (filePath) => isPagesHtmlFile(filePath) && isDocsFile(filePath));
  pageFiles.forEach((filePath) => filesToScan.add(filePath));

  const docsFiles = await collectFiles(docsRoot, isDocsFile);
  docsFiles.forEach((filePath) => filesToScan.add(filePath));

  const referencedUrls = new Set();

  for (const filePath of filesToScan) {
    const content = await readFile(filePath, 'utf8');
    for (const match of content.matchAll(generatedAssetUrlPattern)) {
      referencedUrls.add(`/assets/generated/${match[1]}`);
    }
  }

  return Array.from(referencedUrls).sort();
}

async function collectGeneratedScreenshotSources() {
  if (!existsSync(screenshotsRoot)) {
    console.error(`Screenshot source directory does not exist: ${screenshotsRoot}`);
    process.exit(1);
  }

  const screenshotFiles = await collectFiles(screenshotsRoot, isGeneratedScreenshotSource);
  const filesByName = new Map();

  for (const filePath of screenshotFiles) {
    const fileName = path.basename(filePath);

    if (filesByName.has(fileName)) {
      const existingPath = filesByName.get(fileName);
      throw new Error(`Duplicate generated screenshot filename "${fileName}" in:\n- ${existingPath}\n- ${filePath}`);
    }

    filesByName.set(fileName, filePath);
  }

  return filesByName;
}

async function prepareGeneratedAssetsDirectory() {
  await rm(generatedAssetsRoot, { recursive: true, force: true });
  await mkdir(generatedAssetsRoot, { recursive: true });
}

async function main() {
  const referencedUrls = await collectReferencedGeneratedAssets();
  const generatedSources = await collectGeneratedScreenshotSources();

  await prepareGeneratedAssetsDirectory();

  const copiedFiles = [];

  for (const assetUrl of referencedUrls) {
    const fileName = path.basename(assetUrl);
    const sourceFile = generatedSources.get(fileName);

    if (!sourceFile) {
      throw new Error(`Missing generated screenshot for referenced asset: ${assetUrl}`);
    }

    await copyFile(sourceFile, path.join(generatedAssetsRoot, fileName));
    copiedFiles.push(fileName);
  }

  console.log(`Staged ${copiedFiles.length} generated Pages asset file(s).`);
  copiedFiles.forEach((fileName) => {
    console.log(`  staged: assets/generated/${fileName}`);
  });
}

await main();
