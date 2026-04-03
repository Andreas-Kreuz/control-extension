import { appendFileSync, existsSync, readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');

const packageJson = JSON.parse(readFileSync(path.join(repoRoot, 'package.json'), 'utf8'));
const version = packageJson.version;

const exePath = path.join(repoRoot, 'apps', 'web-server', 'dist', 'control-extension-server.exe');
const packageDir = path.join(repoRoot, 'lua', 'modell-pakete');
const packageName = `control-extension-for-eep-${version}.zip`;
const packagePath = path.join(packageDir, packageName);

if (!existsSync(exePath)) {
  console.error(`[find-release-assets] Missing Windows executable: ${exePath}`);
  process.exit(1);
}

if (!existsSync(packageDir)) {
  console.error(`[find-release-assets] Missing package directory: ${packageDir}`);
  process.exit(1);
}

if (!existsSync(packagePath)) {
  const availablePackages = readdirSync(packageDir).filter((entry) => entry.endsWith('.zip'));
  console.error(`[find-release-assets] Missing EEP release package: ${packagePath}`);
  if (availablePackages.length > 0) {
    console.error(`[find-release-assets] Available zip packages: ${availablePackages.join(', ')}`);
  }
  process.exit(1);
}

const githubOutput = process.env.GITHUB_OUTPUT;
const outputs = {
  exe_path: exePath,
  exe_name: path.basename(exePath),
  eep_package_path: packagePath,
  eep_package_name: path.basename(packagePath),
};

for (const [key, value] of Object.entries(outputs)) {
  console.log(`${key}=${value}`);
}

if (githubOutput) {
  const lines = Object.entries(outputs).map(([key, value]) => `${key}=${value}\n`).join('');
  appendFileSync(githubOutput, lines, 'utf8');
}
