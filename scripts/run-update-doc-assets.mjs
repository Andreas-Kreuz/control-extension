import { spawn } from 'node:child_process';
import { existsSync } from 'node:fs';
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const scriptDir = fileURLToPath(new URL('.', import.meta.url));
const repoRoot = path.resolve(scriptDir, '..');
const pagesRoot = path.join(repoRoot, 'pages');
const docsRoot = path.join(pagesRoot, 'docs');
const generatedAssetsRoot = path.join(pagesRoot, 'assets', 'generated');
const generatedAssetUrlPattern = /\/assets\/generated\/([a-z0-9][a-z0-9.-]*\.png)/g;
const force = process.argv.includes('--force');

const commands = [
  'yarn workspace @ce/web-shared run build',
  'yarn workspace @ce/web-app run build',
  'yarn workspace @ce/web-server run build:app-assets',
];

const isWindows = process.platform === 'win32';
const shellCommand = isWindows ? process.env.ComSpec || 'cmd.exe' : '/bin/sh';
const shellArgs = (command) => (isWindows ? ['/d', '/s', '/c', command] : ['-lc', command]);

async function collectFiles(directoryPath, predicate) {
  if (!existsSync(directoryPath)) {
    return [];
  }

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
    if (!existsSync(filePath)) {
      continue;
    }

    const content = await readFile(filePath, 'utf8');
    for (const match of content.matchAll(generatedAssetUrlPattern)) {
      referencedUrls.add(`/assets/generated/${match[1]}`);
    }
  }

  return Array.from(referencedUrls).sort();
}

async function collectMissingGeneratedAssets() {
  const referencedUrls = await collectReferencedGeneratedAssets();
  return referencedUrls.filter((assetUrl) => !existsSync(path.join(generatedAssetsRoot, path.basename(assetUrl))));
}

async function runCommand(command) {
  await new Promise((resolve, reject) => {
    const child = spawn(shellCommand, shellArgs(command), {
      cwd: process.cwd(),
      env: process.env,
      stdio: 'inherit',
    });

    child.on('error', reject);
    child.on('exit', (code, signal) => {
      if (signal) {
        reject(new Error(`Command terminated by signal: ${signal}`));
        return;
      }

      if (code !== 0) {
        reject(new Error(`Command failed with exit code ${code}: ${command}`));
        return;
      }

      resolve();
    });
  });
}

async function runParallelForDocAssets() {
  const updateDocAssetsCommand = force
    ? 'node ./scripts/update-doc-assets.mjs --force'
    : 'node ./scripts/update-doc-assets.mjs';

  await new Promise((resolve, reject) => {
    const child = spawn(
      process.execPath,
      [
        './scripts/run-parallel.mjs',
        'yarn workspace @ce/web-server run run:test',
        `yarn workspace @ce/web-app exec node ../../scripts/run-cypress.mjs run --spec cypress/e2e/screenshots/*.cy.ts && ${updateDocAssetsCommand}`,
      ],
      {
        cwd: process.cwd(),
        env: process.env,
        stdio: 'inherit',
      },
    );

    child.on('error', reject);
    child.on('exit', (code, signal) => {
      if (signal) {
        reject(new Error(`Parallel run terminated by signal: ${signal}`));
        return;
      }

      if (code !== 0) {
        reject(new Error(`Parallel run failed with exit code ${code}`));
        return;
      }

      resolve();
    });
  });
}

if (!force) {
  const missingAssets = await collectMissingGeneratedAssets();

  if (missingAssets.length === 0) {
    console.log('[docs:assets] all referenced generated asset files already exist; skipping screenshot generation');
    process.exit(0);
  }

  console.log(`[docs:assets] ${missingAssets.length} referenced generated asset file(s) missing; generating screenshots`);
  missingAssets.forEach((assetUrl) => console.log(`  missing: ${assetUrl}`));
} else {
  console.log('[docs:assets] force mode enabled; rebuilding generated screenshot assets');
}

for (const command of commands) {
  await runCommand(command);
}

await runParallelForDocAssets();
