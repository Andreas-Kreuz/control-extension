import { cpSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { execSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const luaDir = path.join(repoRoot, 'lua');
const rootPackageJson = JSON.parse(readFileSync(path.join(repoRoot, 'package.json'), 'utf8'));
const version = rootPackageJson.version;

// ---------------------------------------------------------------------------
// File scanning
// ---------------------------------------------------------------------------

/**
 * Recursively collect all files under baseDir/subdirectory.
 * Returns array of { installKey, fileName, absolutePath } where:
 *   installKey   = "subdirectory\relative\path\file.ext"  (Windows separators, for install.ini)
 *   fileName     = bare filename                          (for install.ini left-hand side)
 *   absolutePath = full OS path                           (for cpSync)
 *
 * Exclusion: plain substring match on installKey — mirrors Lua string.find plain mode.
 */
function searchFiles(baseDir, subdirectory, excludePatterns) {
  const absSubdir = path.join(baseDir, subdirectory);
  const entries = readdirSync(absSubdir, { recursive: true, withFileTypes: true });

  const results = [];
  for (const entry of entries) {
    if (!entry.isFile()) continue;

    const entryDir = entry.parentPath ?? entry.path;
    const absolutePath = path.join(entryDir, entry.name);
    const relFromSubdir = path.relative(absSubdir, absolutePath);
    const installKey = subdirectory + '\\' + relFromSubdir.split(path.sep).join('\\');

    if (excludePatterns.some((p) => installKey.includes(p))) {
      console.log(`[create-installer] skip: ${installKey}`);
      continue;
    }

    console.log(`[create-installer] add:  ${installKey}`);
    results.push({ installKey, fileName: entry.name, absolutePath });
  }
  return results;
}

// ---------------------------------------------------------------------------
// Package definitions
// ---------------------------------------------------------------------------

const INSTALLER_NAME = `control-extension-for-eep-${version}-installer`;
const COMPAT_INSTALLER_NAME = `ak-compat-layer-for-control-extension-${version}-installer`;

const packages = [
  {
    eepVersion: '13,2',
    germanName: 'Control Extension für EEP',
    germanDescription: 'Control Extension mit Verkehrssteuerung, Aufgabenplanung und Modell-Installation',
    sources: [
      {
        subdirectory: 'LUA\\ce',
        exclude: [
          'README.md',
          'commands-to-ce',
          'events-from-ce',
          'events-from-ce.pending',
          'log-from-ce',
          'ce-version.txt',
          'server-is-running',
          'server-state.json',
          'server-state.counter',
          'anlagen',
          'desktop.ini',
        ],
      },
    ],
  },
  {
    eepVersion: '13,2',
    germanName: 'Demo-Anlage (Ampel, ÖPNV)',
    germanDescription: 'Die Demo-Anlagen für Ampeln und ÖPNV',
    sources: [
      { subdirectory: 'LUA\\ce\\demo-anlagen\\ampel', exclude: ['README.md', 'desktop.ini'] },
      {
        subdirectory: 'Resourcen\\Anlagen\\ce\\Control_Extension-Demo-Ampel',
        exclude: ['.dds', 'README.md', 'desktop.ini'],
      },
      { subdirectory: 'LUA\\ce\\demo-anlagen\\demo-linien', exclude: ['.dds', 'README.md', 'desktop.ini'] },
      {
        subdirectory: 'Resourcen\\Anlagen\\ce\\Control_Extension-Demo-Linien',
        exclude: ['.dds', 'README.md', 'desktop.ini'],
      },
    ],
  },
  {
    eepVersion: '13,2',
    germanName: 'Demo-Anlage Testen mit EEP (Erweiterte Modelle)',
    germanDescription: 'Eine Anlage mit Shop-Modellen - mit zwei komplexen Kreuzungen und Ampel-Skripten',
    sources: [
      { subdirectory: 'LUA\\ce\\demo-anlagen\\testen', exclude: ['README.md', 'desktop.ini'] },
      {
        subdirectory: 'Resourcen\\Anlagen\\ce\\Control_Extension-Demo-Testen',
        exclude: ['.dds', 'README.md', 'desktop.ini'],
      },
    ],
  },
  {
    eepVersion: '13,2',
    germanName: 'Tutorial - Aufbau einer Ampelkreuzung',
    germanDescription: 'Eine Anlage mit einer Kreuzung, die die Verwendung der Lua-Bibliothek erklärt',
    sources: [
      { subdirectory: 'LUA\\ce\\demo-anlagen\\tutorial-ampel', exclude: ['README.md', 'desktop.ini'] },
      {
        subdirectory: 'Resourcen\\Anlagen\\ce\\Control_Extension-Tutorial-Ampelkreuzung',
        exclude: ['.dds', 'README.md', 'desktop.ini'],
      },
    ],
  },
];

const compatPackages = [
  {
    eepVersion: '13,2',
    germanName: 'AK Compat-Layer für Control Extension',
    germanDescription: 'Kompatibilitäts-Bibliotheken: ak.road und ak.public-transport als dünne Schicht über ce.mods',
    sources: [{ subdirectory: 'LUA\\ak', exclude: [] }],
  },
];

// ---------------------------------------------------------------------------
// Content generators
// ---------------------------------------------------------------------------

function generateInstallationEep(pkgs) {
  return pkgs
    .map((pkg, index) => {
      const label = String(index).padStart(2, '0');
      const n = pkg.germanName;
      const d = pkg.germanDescription;
      return (
        `[Install_${label}]\n` +
        `Name_GER\t = "${n}"\n` +
        `Name_ENG\t = "${n}"\n` +
        `Name_FRA\t = "${n}"\n` +
        `Name_POL\t = "${n}"\n` +
        `Desc_GER\t = "${d}"\n` +
        `Desc_ENG\t = "${d}"\n` +
        `Desc_FRA\t = "${d}"\n` +
        `Desc_POL\t = "${d}"\n` +
        `Script\t = "Install_${label}\\Install.ini"\n`
      );
    })
    .join('');
}

function generateInstallIni(files, eepVersion) {
  let content = '[EEPInstall]\n';
  content += `EEPVersion = ${eepVersion}\n\n`;
  for (const [i, { installKey, fileName }] of files.entries()) {
    const num = String(i + 1).padStart(3, '0');
    content += `File${num} = "${fileName}", "${installKey}"\n`;
  }
  return content;
}

// ---------------------------------------------------------------------------
// ZIP creation
// ---------------------------------------------------------------------------

function createZip(sourceDir, zipPath) {
  rmSync(zipPath, { force: true });

  // Use the built-in PowerShell archive command on supported Windows systems.
  execSync(
    `powershell -NoProfile -Command "Compress-Archive -Path '${sourceDir}\\*' -DestinationPath '${zipPath}' -CompressionLevel Optimal -Force"`,
    { stdio: 'inherit' },
  );
  console.log(`[create-installer] ZIP created with PowerShell: ${zipPath}`);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

const outputDir = path.join(luaDir, 'modell-pakete');

function buildInstaller(installerName, pkgs) {
  const installationDir = path.join(outputDir, installerName);
  rmSync(installationDir, { recursive: true, force: true });
  mkdirSync(installationDir, { recursive: true });

  for (const [index, pkg] of pkgs.entries()) {
    const label = String(index).padStart(2, '0');
    const pkgDir = path.join(installationDir, `Install_${label}`);
    mkdirSync(pkgDir, { recursive: true });

    const allFiles = [];
    for (const source of pkg.sources) {
      allFiles.push(...searchFiles(luaDir, source.subdirectory, source.exclude));
    }

    if (allFiles.length === 0) {
      console.error(`[create-installer] ERROR: no files found for package "${pkg.germanName}"`);
      process.exit(1);
    }

    for (const { absolutePath, fileName } of allFiles) {
      cpSync(absolutePath, path.join(pkgDir, fileName));
    }

    writeFileSync(path.join(pkgDir, 'install.ini'), generateInstallIni(allFiles, pkg.eepVersion), 'latin1');
    console.log(`[create-installer] Package ${label}: ${pkg.germanName} (${allFiles.length} files)`);
  }

  writeFileSync(path.join(installationDir, 'Installation.eep'), generateInstallationEep(pkgs), 'latin1');

  const zipPath = path.join(outputDir, `${installerName}.zip`);
  createZip(installationDir, zipPath);
  return zipPath;
}

buildInstaller(INSTALLER_NAME, packages);
buildInstaller(COMPAT_INSTALLER_NAME, compatPackages);

console.log('[create-installer] Done.');
