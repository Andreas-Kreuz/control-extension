# AGENTS.md

## Projektkontext

- Dieses Repository enthält eine Lua-Bibliothek für EEP (`lua/LUA/ce`) sowie eine optionale Web-Oberfläche mit Server.
- Die Lua-Module sind der Kern des Projekts. Web-Server und Web-App sind Zusatzwerkzeuge für Anzeige, Steuerung und Tests.
- Wichtige Bereiche:
  - `lua/LUA/ce`: produktiver Lua-Code für EEP
  - `lua/LUA/spec`: Lua-Tests
  - `apps/web-app`: React/Vite-Frontend
  - `apps/web-server`: Electron- und Headless-Server
  - `apps/web-shared`: gemeinsam genutzte TypeScript-Typen und Events
  - `docs`: statische Dokumentation / Website

## Arbeitsregeln

- Änderungen möglichst lokal und minimal halten. In diesem Repo sind viele Module zustandsbehaftet; kleine gezielte Patches sind besser als breite Refactorings.
- Dateikodierung gemäß Abschnitt `Dateikodierung` und `.editorconfig` behandeln; insbesondere Latin1-Ausnahmen für Lua- und bestimmte von Lua gelesene/geschriebene Dateien beachten.
- Markdown-Dateien sollen korrekte deutsche Umlaute verwenden. ASCII-Ersatzschreibungen wie `ae`, `oe` oder `ue` nur beibehalten, wenn sie sich auf Lua-Code oder Lua-Bezeichner beziehen.
- `yarn` ist die führende Paketverwaltung dieses Repos. Bei Doku- oder Script-Änderungen alte `npm`-Verweise aktiv prüfen und nur stehen lassen, wenn sie bewusst noch benötigt werden.
- Generierte Build-Artefakte wie `*.tsbuildinfo` nicht einchecken; bei neu auftauchenden Cache-Dateien zuerst prüfen, ob sie in `.gitignore` gehören.
- Unter Windows/PowerShell kann `yarn` an der lokalen Execution Policy scheitern; für Verifikation im Agent-Kontext ist dann `yarn.cmd` oft der robustere Aufruf.
- Markdown-Dateien mit geplantem, aber noch nicht implementiertem Zielzustand klar als `TODO`, `Roadmap` oder `Zielbild` kennzeichnen, damit sie nicht mit der aktuellen Architektur verwechselt werden.

## Dateikodierung

**Grundregel:** `.lua`-Dateien = `latin1` / `ISO-8859-1`, alle anderen Dateien = `UTF-8`.

Zusätzliche latin1-Ausnahmen:

- Dateien unter `lua/LUA/ce/databridge/exchange/` werden von Lua gelesen und geschrieben und sind deshalb als `latin1` zu behandeln.
- Fixtures unter `apps/web-app/cypress/fixtures/*/*.json` stammen aus von Lua geschriebenen `latin1`-Dateien und müssen deshalb ebenfalls als `latin1` behandelt werden.

### Edit- und Write-Tool: NIEMALS für Latin1-Dateien mit Umlauten verwenden

Die Edit- und Write-Tools schreiben Dateien als UTF-8 zurück. Das korrumpiert alle latin1-Bytes in der gesamten Datei — auch in Zeilen, die gar nicht geändert wurden. Aus `ü` (0xFC) wird das UTF-8-Ersatzzeichen U+FFFD (0xEF 0xBF 0xBD), das nicht mehr reparierbar ist.

**Für Latin1-Dateien bevorzugt `scripts/latin1_tool.ps1` verwenden; Byte-Level-Python nur als Fallback:**

```python
with open('datei.lua', 'rb') as f:
    data = f.read()
data = data.replace(b'alter ascii text', b'neuer ascii text')
with open('datei.lua', 'wb') as f:
    f.write(data)
```

- Alle Ersetzungen müssen reines ASCII bleiben (0x00–0x7F) — niemals Umlaute in den Ersetzungsstrings
- Neue `.lua`-Dateien ohne Umlaute (reines ASCII) dürfen mit Write erstellt werden
- Prüfen ob keine Ersatzzeichen enthalten: `python -c "d=open('datei.lua','rb').read(); assert b'\xef\xbf\xbd' not in d, 'ENCODING BROKEN'"`

### Shell-Kommandos mit latin1

- In diesem Repository für Shell-Kommandos nach Möglichkeit `Windows PowerShell 5.1` verwenden.
- Bei Shell-Kommandos zum Lesen oder Schreiben von `.lua`-Dateien immer die Kodierung explizit auf `latin1` setzen.
- In Windows PowerShell (Version 5.1 und früher) ist die Standardkodierung für Skripte und Ausgaben typischerweise `Windows-1252`, eine Erweiterung von `ISO-8859-1` (`Latin-1`).
- `Windows PowerShell 5.1` unterstützt bei `Get-Content`/`Set-Content` weder `-Encoding ISO88591` noch `-Encoding Latin1`:
  - lesen: `[System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding('iso-8859-1'))`
  - schreiben: `[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::GetEncoding('iso-8859-1'))`
- Im Repo liegt dafür `scripts/latin1_tool.ps1` mit den Aktionen `read`, `write`, `replace` und `check`; für Latin1-Dateien diesen Helper bevorzugen.
- Andere Dateien: `Get-Content -Encoding UTF8` / `Set-Content -Encoding UTF8`

## Lua-Hinweise

- Im Repository liegt der produktive Lua-Code unter `lua/LUA/`; im installierten EEP-System liegen diese Lua-Dateien standardmäßig unter `C:\Trend\EEP18\LUA` (je nach EEP-Version entsprechend z.B. `EEP17`, `EEP18`).
- Bestehende deutsche Bezeichner, Kommentare und Logmeldungen beibehalten, wenn du vorhandenen Lua-Code änderst.
- Beschreibungen für Funktionen, Parameter und Return-Werte gerne aus dem Lua-Manual übernehmen.
- `Lua_manual.pdf` wird für `EepOriginalApi.d.lua` in diesem Projekt mit `pdftotext -table` ausgewertet. Der Parser arbeitet blockweise als Tabellenparser und nicht mehr als freier Fließtext-Parser.
- `lua/LUA/ce/hub/eep/EepOriginalApi.d.lua` ist die typsichere Soll-Schnittstelle des originalen Programms EEP. Sie wird aus `Lua_manual.pdf` abgeleitet und nicht aus `EepSimulator.lua`.
- Der einzig gültige Generator für diese Datei ist `python scripts/generate_eep_original_api.py`. Ältere Generatorvarianten und Vergleichsausgaben werden nicht mehr verwendet.
- Für `EepOriginalApi.d.lua` gilt bei der Auswertung des Handbuchs:
  - Es gibt zwei Blocktypen:
    - Variablenblock
    - Funktions- oder Callback-Block
  - Variablenblock:
    - Kopfzeile mit Variablennamen links und wiederholtem Variablennamen bzw. Beispiel rechts
    - `Voraussetzung`
    - `Zweck`
  - Funktions- oder Callback-Block:
    - Kopfzeile mit `EEPFunktion()` links und Signatur-/Aufrufbeispiel rechts
    - `Parameter`
    - `Rückgabewerte`
    - `Voraussetzung`
    - `Zweck`
    - `Bemerkungen`
  - Die rechte Spalte enthält Beispielaufrufe bzw. Beispielcode.
  - `Zweck` und `Bemerkungen` werden aus der linken und mittleren Tabellenhälfte abgeleitet, nicht aus der Beispielspalte.
  - Mindestversionen werden aus `Voraussetzung` übernommen
  - Parameter- und Rückgabesemantik wird vorrangig aus `Bemerkungen` abgeleitet
- `EepOriginalApi.d.lua` enthält nur Definitionen: globale Variablen als `---@type` mit Platzhalterwert, Callbacks und Funktionen als leere Funktionsrümpfe. Keine Simulatorlogik in diese Datei schreiben.
- Wertebereiche aus den Bemerkungen nach Möglichkeit als `---@alias` modellieren. Aliase möglichst direkt über der ersten Funktion platzieren, die sie verwendet. Wenn ein Alias die Details enthält, bleiben Parametertexte kurz.
- Nach jeder Funktion und jedem Callback die Handbuchbeispiele als Kommentarblock im Format `-- Beispielaufrufe:` übernehmen.
- Wenn `Lua_manual.pdf` erweitert wird, `python scripts/generate_eep_original_api.py` erneut ausführen und anschließend nur `lua/LUA/ce/hub/eep/EepOriginalApi.d.lua` verifizieren mit:
  - `lua -e "assert(loadfile('lua/LUA/ce/hub/eep/EepOriginalApi.d.lua')); print('OK')"`
  - einem Konsistenzabgleich zwischen extrahierten Blöcken und der erzeugten Datei:
    - jede Funktion und jeder Callback muss eine Versionszeile und einen Block `-- Beispielaufrufe:` haben
    - die Anzahl der Parameter und Rückgabewerte muss innerhalb des im Handbuch angegebenen Bereichs liegen
    - es dürfen keine Platzhalternamen wie `paramN`, `valueN` oder numerische Parameternamen im Ergebnis verbleiben
- Bei Änderungen an Zustandslogik in Lua immer auf Persistenz achten `StorageUtility.loadTable()` und `StorageUtility.saveTable()` akzeptieren nur String-Werte
  - Optionale Felder beim Speichern lieber weglassen als `"nil"` oder andere Platzhalter-Strings zu schreiben.
- EEP-nahe Fehlerpfade sind oft absichtlich `fail-loud`: bestehende `print(... debug.traceback())`-Muster nicht ohne klaren Grund in stilles Fehlerhandling umwandeln.
- Module unter `lua/LUA/ce` laufen in einer Lua 5.3 Umgebung des Programmes EEP. Das Programm EEP stellt die globalen EEP-Funktionen wie in LUA_Manual.pdf beschrieben zur Verfügung wie `EEPSetSignal`, `EEPLoadData` oder `EEPTime`. Was das Programm kann ist in EEP18_Manual_GER.pdf beschrieben.
- EEPSimulator.lua soll die Funktionen des Programms EEP abbilden, so dass der Lua Code auch mit dem Simulatur getestet werden kann.
- Die fachliche Beschreibung der exportierten Lua-Daten liegt in `lua/LUA/ce/hub/data/README.md`, `lua/LUA/ce/hub/data/DTO.md` sowie in den jeweiligen `*DtoTypes.d.md` unter `lua/LUA/ce/hub/data/**` und `lua/LUA/ce/mods/**/data/`.
- `AGENTS.md` hält dazu nur Arbeitsregeln und Prüfpunkte fest; fachliche Details zu CeTypes, DTO-Feldern und DtoFactories sollen in den Fachdokumenten gepflegt werden.
- In Lua und zwischen Lua und Server ist `ceType` der fachliche Vertragsbegriff. `room` wird nur noch im Server-/Web-Teil als Subscription- bzw. Transportbegriff verwendet.
- Wenn sich ein exportierter `ceType`, sein `keyId` oder seine DTO-Felder ändern, müssen mindestens die passende `*DtoTypes.d.lua`, `*DtoTypes.d.md`, die verantwortliche DtoFactory und die betroffene Server-Dokumentation gemeinsam geprüft und synchron gehalten werden.
- Bei Änderungen an exportierten `ceType`-Namen zusätzlich Server-Selektoren, Web-App-Subscriptions, Cypress-Fixtures und E2E-Assertions mitprüfen.
- Viele Module registrieren globale Callbacks über `_G[...]`. Bei Änderungen an Registrierungslogik auf bestehende Namenskonventionen achten.
- Persistenter Zustand liegt typischerweise in EEP-Datenslots; dafür werden kurze Schlüssel wie `b`, `z`, `r`, `t` verwendet.
- Hard-Resets und Recovery-Pfade sind wichtig. Wenn neue zustandsbehaftete Objekte eingeführt werden, muss auch deren Reset-Verhalten bedacht werden.

## Web-Hinweise

- Die Web-App ist React 19 mit Vite und MUI, nicht Angular.
- Der Web-Server ist eine Electron-/Node-Anwendung in TypeScript.
- Gemeinsame Typen und Events liegen in `apps/web-shared` und sollten bei API-Änderungen konsistent mit angepasst werden.
- Die serverseitig erzeugten Meta-Daten `ce.server.ApiEntries` und `ce.server.ServerStats` kommen nicht aus Lua, sondern werden im Web-Server aus dem aktuellen Datenbestand abgeleitet; fachliche Details dazu stehen in `apps/web-server/src/server/eep/server-data/README.md`.
- In Cypress-Specs keine lokalen Hilfsfunktionen wie `chooseDirectory()` einführen, wenn dadurch der Test nicht mehr von oben nach unten lesbar ist.
- In Cypress-Specs verkettete Aufrufe an `.` umbrechen, statt lange Chains in einer Zeile zu lassen.

## Nützliche Kommandos

- Root-Kommandos:
  - Abhängigkeiten installieren: `yarn`
  - Verfügbare Root-Skripte anzeigen: `yarn ce-help`
  - Gesamtbuild: `yarn build`
  - Repo formatieren: `yarn format`
  - Nur Web-/TS-/JSON-/Markdown-Dateien formatieren: `yarn format-prettier`
  - Lua formatieren: `yarn format-lua`
  - Web-App + Server im Spielmodus: `yarn dev-app`
  - Electron-Server mit eingebauter App starten: `yarn play`
- Wichtige Workspace-Kommandos:
  - Web-App Storybook: `yarn workspace @ak/web-app run storybook`
  - Web-App E2E interaktiv: `yarn test-app`
  - Web-App E2E headless: `yarn workspace @ak/web-app run cy-tests-run-headless`
  - Web-Server linten: `yarn workspace @ak/web-server run lint`
  - Headless-Server starten: `yarn workspace @ak/web-server run start-headless`
- Lua prüfen, falls lokal installiert:
  - `luacheck --config .luacheckrc lua/LUA`
  - `busted --config-file .busted --verbose --coverage --`
- Lua formatieren:
  - Standardweg im Repo ist `yarn format-lua`
  - `scripts/format-lua-with-sumneko.mjs` nutzt den lokal installierten VSCode Lua Language Server (`sumneko.lua`) und formatiert dadurch möglichst wie VSCode
  - das Skript schließt Verzeichnisse mit dem Segmentnamen `anlagen` oder `demo-anlagen` bewusst aus
  - wenn der VSCode-Extensions-Ordner nicht am Standardpfad liegt, kann `VSCODE_EXTENSIONS` gesetzt werden
- Bei Änderungen an `package.json`-Skripten immer prüfen, ob die Hilfe aktualisiert werden muss:
  - Root-Skripte aus dem Root-`package.json` müssen in `yarn ce-help` bzw. `scripts/ce-help.mjs` beschrieben sein.
  - Wichtige Workspace-Skripte wie Entwicklerwerkzeuge müssen in der passenden Paket-README oder Kontextdoku beschrieben werden, auch wenn sie nicht in `ce-help` auftauchen.

## Testing und Verifikation

- Für Lua-Änderungen zuerst betroffene Specs unter `lua/LUA/spec` prüfen.
- Nach Lua-Änderungen, wenn die Laufzeit lokal verfügbar ist, immer zusätzlich ausführen:
  - `luacheck --config .luacheckrc lua/LUA`
  - `busted --config-file .busted --verbose --coverage --`
- Für Änderungen an Web-Typen oder Events mindestens `@ak/web-shared` und den betroffenen Consumer mitdenken.
- Nach Änderungen nach Möglichkeit `yarn format` ausführen.
  - `yarn format` ruft `format-prettier` und `format-lua` nacheinander auf.
  - Wenn nur Nicht-Lua-Dateien betroffen sind, kann stattdessen gezielt `yarn format-prettier` verwendet werden.
  - Wenn nur Lua-Dateien betroffen sind, kann stattdessen gezielt `yarn format-lua` verwendet werden.
  - `yarn format` kann in diesem Repository an bereits vorhandenen Liquid-/HTML-Dateien unter `docs/` scheitern; solche Fehler getrennt von den gerade geänderten Dateien bewerten.
- Wenn keine passende Laufzeit verfügbar ist, statisch prüfen und explizit benennen, was nicht ausgeführt werden konnte.

## Änderungsstil

- Keine unnötigen Umbenennungen oder Formatierungswellen.
- Keine bestehenden lokalen Benutzeränderungen zurücksetzen.
- Wenn sich zentrale Konzepte, Vertragsbegriffe oder Projektkonventionen ändern, immer auch prüfen, ob `AGENTS.md` entsprechend aktualisiert werden muss.
- Bei Reviews Schwerpunkt auf:
  - Zustandskonsistenz
  - Persistenzfehler
  - EEP-/Callback-Integration
  - Verhaltensregressionen
  - fehlende Tests
- Gegencheck der Architekturdokumentationen in [ARCHITECTURE.md](ARCHITECTURE.md) und den jeweiligen Teilarchitekturen (`ARCHITECTURE_LUA.md`, `ARCHITECTURE_SERVER.md`, `ARCHITECTURE_SHARED.md`, `ARCHITECTURE_APP.md`)
- Gegencheck der Readmes in [README\*.md](README*.md)
