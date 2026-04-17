---
layout: page_with_toc
title: Aufbau des Projektes
type: Anleitung
subtitle: Hier erfährst du, wie das Projekt aufgebaut ist und wie du es selbst starten kannst.
img: '/assets/thumbnails/GitHub.png'
feature-img: '/assets/headers/SourceCode.png'
date: 2026-04-03
permalink: docs/anleitungen-entwickler/aufbau-des-projektes
tags: [Entwickler]
published: true
---

# Aufbau des Projektes

Dieses Dokument ist der zentrale Einstieg für die Entwicklungsumgebung.
Hier erfährst du alles über die wichtigsten Yarn-Kommandos des Projekts.

## Projektbestandteile

Der folgende Überblick zeigt dir, welche Bestandteile im Projekt enthalten sind:

- `lua` enthält den produktiven Lua-Code für EEP und die zugehörigen Specs.
- `apps/web-app` enthaelt das React-/Vite-Frontend.
- `apps/web-server` enthält den Electron- und Headless-Server in TypeScript.
- `apps/web-shared` enthält gemeinsam genutzte TypeScript-Typen und Events.
- `pages/docs` enthält die statische Dokumentation.
- `scripts` enthält Hilfsskripte für Build, Tests und Werkzeugunterstützung. Die öffentlichen Einstiege liegen im Root-`package.json`.

## Voraussetzungen

### Erforderliche Werkzeuge

- [Node.js](https://nodejs.org/en/) mit Corepack/Yarn
- [Lua 5.3](http://luabinaries.sourceforge.net/download.html)
- [Ruby](https://rubyinstaller.org/) `3.3.x` mit [Bundler](https://bundler.io/) `4.x` und Jekyll für `yarn dev:docs` und `yarn test:docs`
- [`luacheck`](https://github.com/mpeterv/luacheck) fuer `yarn lint:lua`
- [`busted`](https://github.com/lunarmodules/busted) für `yarn test:lua` und `yarn test:lua:coverage`

Alle Kommandos müssen im PATH liegen und aufrufbar sein: `lua`, `busted`, `luacheck`, `ruby`, `bundle`, `yarn`.

Unter PowerShell kann `yarn` an der lokalen Execution Policy scheitern. In diesem Fall ist `yarn.cmd` der robuste Aufruf für die gleiche Aktion.

### Empfohlene Werkzeuge

- [VS Code](https://code.visualstudio.com/)
- [git Kommandozeile](https://git-scm.com/downloads) oder [GitHub Desktop](https://desktop.github.com/)

## Klonen und vorbereiten

### 1. Control Extension mit GitHub Desktop klonen

- Lade Dir zuerst das Programm [GitHub Desktop](https://desktop.github.com/) herunter und installiere es.
- Öffne GitHub Desktop.
- Klicke oben auf _File_ → _Clone repository_.
- Wähle das Projekt [Andreas-Kreuz/control-extension](https://github.com/Andreas-Kreuz/control-extension) aus.
- Als lokales Verzeichnis verwendest Du am besten `C:\GitHub\control-extension`
- Du kannst das Projekt direkt herunterladen.

### 2. Start die Kommandozeile unter Windows

- Drücke die Taste `<WINDOWS>`
- Tippe `powershell`, und klicke dann auf Powershell

### 3. Wechsle in das Projektverzeichnis und initialisiere das Projekt

- Wechsle in das Projekt Verzeichnis:
  `C:\GitHub\control-extension`
- Führe dann folgende Befehle aus

  ```bash
  corepack enable
  yarn install
  yarn ce-help
  ```

  Wenn corepack enable nicht funktioniert, stelle sicher, dass Node installiert ist.

## Das Projekt mit Entwicklerwerkzeugen nutzen

Im Projektverzeichnis `C:\GitHub\control-extension` steht dir eine Reihe von yarn Befehlen zur Verfügung. Die wichtigsten sind:

- `yarn ce-help` -> zeigt alle Befehle an
- `yarn tools:check` -> prüfe installierte Werkzeuge
- `yarn dev:app` -> startet den Server und die App zum Entwickeln

### Namensschema der Yarn Kommandos

- `dev:*` fuer Entwicklungs-Workflows mit laufenden Diensten
- `run:*` für lokale Laufzeit auf Basis eines Builds
- `build:*` für Artefakte und Release-Pakete
- `format:*` fuer automatische Formatierung
- `lint:*` fuer statische Checks
- `test:*` für Tests und Validierungen
- `check:*` fuer bereichsspezifische Qualitätsgates und `check` als globale Vorabpruefung vor `build:release`

## Root-Yarn-Kommandos

| Target                    | Abhängigkeiten                                       | Kurzbeschreibung                                                                           |
| ------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `install` (builtin)       | keine                                                | Installiert alle Abhängigkeiten nach dem Klonen.                                           |
| `ce-help`                 | keine                                                | Diese Übersicht anzeigen.                                                                  |
| `tools:check`             | keine                                                | Erforderliche externe Werkzeuge in `PATH` prüfen und bei Bedarf Install-Hinweise anzeigen. |
| `dev:app`                 | keine                                                | App und Server im Entwicklungsmodus starten (automatischer re-build).                      |
| `dev:docs`                | keine                                                | Inkrementellen Jekyll-Doku-Server mit Live-Reload starten und fehlende Assets erzeugen.    |
| `dev:docs:manual`         | keine                                                | Jekyll-Doku-Server mit manueller Aktualisierung starten und fehlende Assets erzeugen.      |
| `dev:storybook`           | keine                                                | Storybook der Web-App für isolierte UI-Entwicklung starten.                                |
| `run:app`                 | `build`                                              | App und Server mit `build` bauen und starten (ohne re-build).                              |
| `build`                   | keine                                                | App und Server für den lokalen Einsatz bauen.                                              |
| `build:docs:assets`       | keine                                                | Fehlende generierte Doku-Assets erzeugen.                                                  |
| `build:docs:assets:force` | keine                                                | Generierte Doku-Assets vollständig neu erzeugen.                                           |
| `build:exe`               | keine                                                | Windows-EXE von App und Server bauen; auf macOS bewusst nicht unterstützt.                 |
| `build:release`           | `check`, `build:exe`                                 | App und Server sowie Lua als Release für EEP bauen; Windows-Paketierung nur unter Windows. |
| `clean`                   | keine                                                | Temporäre Artefakte von Web, Doku und Lua gemeinsam entfernen.                             |
| `clean:docs`              | keine                                                | Jekyll-Build- und Cache-Artefakte der Doku entfernen.                                      |
| `clean:lua`               | keine                                                | Temporäre Lua-Coverage- und Testartefakte entfernen.                                       |
| `clean:web`               | keine                                                | Temporäre Artefakte von Web-App, Web-Server und `web-shared` entfernen.                    |
| `format`                  | `format:apps`, `format:lua`                          | Gesamtes Repository formatieren.                                                           |
| `format:apps`             | keine                                                | App und Server sowie nicht-Lua-Dateien mit Prettier formatieren.                           |
| `format:lua`              | keine                                                | Lua-Dateien mit dem VSCode Lua Language Server formatieren.                                |
| `lint`                    | `lint:lua`, `lint:server`, `lint:app`, `lint:shared` | Alle statischen Checks für Lua, App, Server und Shared ausführen.                          |
| `lint:app`                | keine                                                | Führt ESLint für die Web-App aus.                                                          |
| `lint:lua`                | keine                                                | `luacheck` auf `lua/LUA` ausführen.                                                        |
| `lint:server`             | keine                                                | ESLint für den Web-Server ausführen.                                                       |
| `lint:shared`             | keine                                                | ESLint für `web-shared` ausführen.                                                         |
| `lint:web`                | keine                                                | Alle statischen Checks für Web-App, Web-Server und `web-shared` ausführen.                 |
| `test`                    | `test:lua`, `test:server`, `test:app`, `test:docs`   | Alle implementierten Tests und Validierungen ausführen.                                    |
| `test:lua`                | keine                                                | Lua-Tests mit `busted` schnell ohne Coverage ausführen.                                    |
| `test:lua:coverage`       | keine                                                | Lua-Tests mit `busted` und Coverage ausführen.                                             |
| `test:server`             | keine                                                | Server-Tests nach TypeScript-Build ausführen.                                              |
| `test:app`                | keine                                                | Web-App-E2E-Tests headless ausführen.                                                      |
| `test:app:ui`             | keine                                                | Interaktive Cypress-E2E-Umgebung starten.                                                  |
| `test:docs`               | keine                                                | Jekyll-Doku zur Validierung bauen.                                                         |
| `test:web`                | keine                                                | Server-Tests und Web-App-E2E-Tests ausführen.                                              |
| `check:lua`               | `lint:lua`, `test:lua`                               | Lua-Lint und Lua-Tests als Qualitätsgate ausführen.                                        |
| `check:web`               | `lint:web`, `test:web`                               | Web-Lints sowie Server- und App-Tests als Qualitätsgate ausführen.                         |
| `check`                   | `tools:check`, `lint`, `test`                        | Manuelle Vorabprüfung vor `build:release` (`tools:check` + `lint` + `test`).               |

## Typische Workflows

### Tägliche App-Entwicklung

```bash
yarn dev:app
```

Die Web-App laeuft dabei typischerweise unter <http://localhost:5173/>.

### Komponenten isoliert in Storybook entwickeln

```bash
yarn dev:storybook
```

### Startet den gebauten Server

```bash
yarn run:app
```

### Formatieren vor einem Commit

```bash
yarn format
```

Oder gezielt:

```bash
yarn format:apps
yarn format:lua
```

### Tests und Checks vor einem Release

```bash
yarn clean
yarn check
```

Einzelne Teilmengen:

```bash
yarn lint:lua
yarn lint:server
yarn lint:app
yarn lint:shared
yarn lint:web
yarn check:lua
yarn check:web
yarn test:lua
yarn test:lua:coverage
yarn test:server
yarn test:app
yarn test:docs
yarn test:web
```

Für den Alltag ist `yarn test:lua` der schnelle Standardlauf. `yarn test:lua:coverage` ist der langsamere Vollständigkeitslauf mit Coverage.

### Komplettes Release für EEP

```bash
yarn build:release
```

Für das native Windows-Release ohne Wine oder Rosetta gibt es zusätzlich einen manuellen GitHub-Actions-Workflow unter `.github/workflows/release-windows.yml`. Dieser baut auf einem Windows-Runner und lädt die `.exe` sowie das EEP-Paket als Draft Release hoch.

### Dokumentation prüfen / entwickeln

Für die Doku verwendet dieses Repo Ruby `3.3.x` und Bundler `4.x`, damit die lokale Umgebung möglichst nahe an GitHub Pages bleibt. Nach einem Ruby- oder Bundler-Wechsel sollte `pages/Gemfile.lock` mit dieser Bundler-Version neu erzeugt werden.

```bash
(
  cd pages
  bundle _4.0.9_ lock --bundler 4.0.9
  bundle install
)
```

## Latin1-Hinweis fuer Lua-Dateien

Bestehende `.lua`-Dateien im Repository müssen als `ISO-8859-1` behandelt werden. Für Lesen und Schreiben steht `scripts/latin1_tool.ps1` bereit.

Beispiele:

```powershell
powershell.exe -NoProfile -File .\scripts\latin1_tool.ps1 -Action read -Path lua/LUA/ce/MyModule.lua
powershell.exe -NoProfile -File .\scripts\latin1_tool.ps1 -Action write -Path lua/LUA/spec/SandboxLatin1Roundtrip.lua -Text "-- Test: äöü`r`nreturn {}"
powershell.exe -NoProfile -File .\scripts\latin1_tool.ps1 -Action replace -Path lua/LUA/ce/MyModule.lua -From "alter Text" -To "neuer Text"
powershell.exe -NoProfile -File .\scripts\latin1_tool.ps1 -Action check -Path lua/LUA/ce/MyModule.lua
```

Ein zusaetzlicher `ExecutionPolicy`-Schalter sollte dafuer normalerweise nicht noetig sein.

Wenn der Aufruf auf einem System mit restriktiver Execution Policy fehlschlaegt, sind diese Wege vorzuziehen:

- Skript direkt in einer bereits passenden PowerShell-Sitzung ausfuehren: `.\scripts\latin1_tool.ps1 ...`
- Fuer den einzelnen Prozess gezielt `RemoteSigned` verwenden:

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\latin1_tool.ps1 -Action check -Path lua/LUA/ce/MyModule.lua
```

## Optional: Lua direkt aus Git in EEP nutzen

Wenn Du das Lua-Verzeichnis direkt aus dem Git-Checkout in EEP nutzen willst, kannst Du einen Link anlegen:

```cmd
mklink /D C:\Trend\EEP18\LUA\ce C:\GitHub\control-extension\lua\LUA\ce
```
