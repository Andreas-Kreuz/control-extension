# Entwicklung

Dieses Dokument ist der zentrale Einstieg für die Entwicklungsumgebung und die täglichen Yarn-Kommandos in diesem Repository.

## Projektbestandteile

- `lua` enthält den produktiven Lua-Code für EEP und die zugehörigen Specs.
- `apps/web-app` enthaelt das React-/Vite-Frontend.
- `apps/web-server` enthält den Electron- und Headless-Server in TypeScript.
- `apps/web-shared` enthält gemeinsam genutzte TypeScript-Typen und Events.
- `docs` enthält die statische Dokumentation.
- `scripts` enthält Hilfsskripte für Build, Tests und Werkzeugunterstützung. Die öffentlichen Einstiege liegen im Root-`package.json`.

## Voraussetzungen

### Erforderliche Werkzeuge

- [Node.js](https://nodejs.org/en/) mit Corepack/Yarn
- [Lua 5.3](http://luabinaries.sourceforge.net/download.html)
- Windows PowerShell mit eingebautem `Compress-Archive` für `yarn build:release`

### Erforderlich je nach Aufgabe

- [Ruby](https://rubyinstaller.org/) mit Bundler/Jekyll für `yarn dev:docs` und `yarn test:docs`
- [`luacheck`](https://github.com/mpeterv/luacheck) fuer `yarn lint:lua`
- [`busted`](https://github.com/lunarmodules/busted) für `yarn test:lua` und `yarn test:lua:coverage`

### Empfohlene Werkzeuge

- [VS Code](https://code.visualstudio.com/)
- [git Kommandozeile](https://git-scm.com/downloads) oder [GitHub Desktop](https://desktop.github.com/)

### Windows-Hinweis

Unter PowerShell kann `yarn` an der lokalen Execution Policy scheitern. In diesem Fall ist `yarn.cmd` der robuste Aufruf für die gleiche Aktion.

## Erste Schritte nach dem Klonen

```bash
corepack enable
yarn install
yarn ce-help
```

## Namensschema

- `dev:*` fuer Entwicklungs-Workflows mit laufenden Diensten
- `run:*` für lokale Laufzeit auf Basis eines Builds
- `build:*` für Artefakte und Release-Pakete
- `format:*` fuer automatische Formatierung
- `lint:*` fuer statische Checks
- `test:*` für Tests und Validierungen
- `check` als manuelle Vorabpruefung vor `build:release`

## Root-Yarn-Kommandos

| Target | Abhängigkeiten | Kurzbeschreibung |
| --- | --- | --- |
| `install` (builtin) | keine | Installiert alle Abhängigkeiten nach dem Klonen. |
| `ce-help` | keine | Diese Übersicht anzeigen. |
| `tools:check` | keine | Erforderliche externe Werkzeuge in `PATH` prüfen. |
| `dev:app` | keine | App und Server im Entwicklungsmodus starten (automatischer re-build). |
| `dev:docs` | keine | Jekyll-Doku-Server mit Live-Reload starten. |
| `dev:storybook` | keine | Storybook der Web-App für isolierte UI-Entwicklung starten. |
| `run:app` | `build` | App und Server mit `build` bauen und starten (ohne re-build). |
| `build` | keine | App und Server für den lokalen Einsatz bauen. |
| `build:win` | keine | App und Server als Windows-Artefakt bauen. |
| `build:release` | `check`, `build:win` | App und Server sowie Lua als Release für EEP bauen. |
| `format` | `format:apps`, `format:lua` | Gesamtes Repository formatieren. |
| `format:apps` | keine | App und Server sowie nicht-Lua-Dateien mit Prettier formatieren. |
| `format:lua` | keine | Lua-Dateien mit dem VSCode Lua Language Server formatieren. |
| `lint` | `lint:lua`, `lint:server`, `lint:app`, `lint:shared` | Alle statischen Checks für Lua, App, Server und Shared ausführen. |
| `lint:app` | keine | Führt ESLint für die Web-App aus. |
| `lint:lua` | keine | `luacheck` auf `lua/LUA` ausführen. |
| `lint:server` | keine | ESLint für den Web-Server ausführen. |
| `lint:shared` | keine | ESLint für `web-shared` ausführen. |
| `test` | `test:lua`, `test:server`, `test:app`, `test:docs` | Alle implementierten Tests und Validierungen ausführen. |
| `test:lua` | keine | Lua-Tests mit `busted` schnell ohne Coverage ausführen. |
| `test:lua:coverage` | keine | Lua-Tests mit `busted` und Coverage ausführen. |
| `test:server` | keine | Server-Tests nach TypeScript-Build ausführen. |
| `test:app` | keine | Web-App-E2E-Tests headless ausführen. |
| `test:app:ui` | keine | Interaktive Cypress-E2E-Umgebung starten. |
| `test:docs` | keine | Jekyll-Doku zur Validierung bauen. |
| `check` | `tools:check`, `lint`, `test` | Manuelle Vorabprüfung vor `build:release` (`tools:check` + `lint` + `test`). |

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

### Realistische lokale Laufzeit

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
yarn check
```

Einzelne Teilmengen:

```bash
yarn lint:lua
yarn lint:server
yarn lint:app
yarn lint:shared
yarn test:lua
yarn test:lua:coverage
yarn test:server
yarn test:app
yarn test:docs
```

Für den Alltag ist `yarn test:lua` der schnelle Standardlauf. `yarn test:lua:coverage` ist der langsamere Vollständigkeitslauf mit Coverage.

### Komplettes Release für EEP

```bash
yarn build:release
```

## Latin1-Hinweis fuer Lua-Dateien

Bestehende `.lua`-Dateien im Repository müssen als `ISO-8859-1` behandelt werden. Für sicheres Lesen und Schreiben steht `scripts/latin1_tool.ps1` bereit.

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
mklink /D C:\Trend\EEP15\LUA\ce C:\GitHub\control-extension\lua\LUA\ce
```
