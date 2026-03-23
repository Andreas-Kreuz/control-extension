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
- Lua-Dateien verwenden das Charset latin1, alle anderen Dateien utf-8 (vergleiche .editorconfig)
- Markdown-Dateien sollen korrekte deutsche Umlaute verwenden. ASCII-Ersatzschreibungen wie `ae`, `oe` oder `ue` nur beibehalten, wenn sie sich auf Lua-Code oder Lua-Bezeichner beziehen.

## Dateikodierung

**Grundregel:** `.lua`-Dateien = `latin1` / `ISO-8859-1`, alle anderen Dateien = `UTF-8`.

### Edit- und Write-Tool: NIEMALS für `.lua`-Dateien mit Umlauten verwenden

Die Edit- und Write-Tools schreiben Dateien als UTF-8 zurück. Das korrumpiert alle latin1-Bytes in der gesamten Datei — auch in Zeilen, die gar nicht geändert wurden. Aus `ü` (0xFC) wird das UTF-8-Ersatzzeichen U+FFFD (0xEF 0xBF 0xBD), das nicht mehr reparierbar ist.

**Stattdessen für `.lua`-Änderungen Bash + Python auf Byte-Ebene verwenden:**

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

- Bei Shell-Kommandos zum Lesen oder Schreiben von `.lua`-Dateien immer die Kodierung explizit auf `latin1` setzen.
- `Windows PowerShell 5.1` unterstützt bei `Get-Content`/`Set-Content` weder `-Encoding ISO88591` noch `-Encoding Latin1`:
  - lesen:  `[System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding('iso-8859-1'))`
  - schreiben: `[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::GetEncoding('iso-8859-1'))`
- `PowerShell 7` unterstützt `-Encoding Latin1`; für Kompatibilität die PS-5.1-Variante bevorzugen.
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
- Die öffentlichen DTO-Felddefinitionen liegen in `lua/LUA/ce/hub/data/**/*.d.lua` sowie `lua/LUA/ce/mods/**/data/*DtoTypes.d.lua`; die Raumverträge mit `room`, `keyId` und verantwortlicher DtoFactory stehen in den jeweiligen `*DtoTypes.d.md`.
- Wenn sich ein exportierter Raum, sein `keyId` oder seine DTO-Felder ändern, müssen mindestens `DtoTypes.d.lua`, `DtoTypes.d.md`, die verantwortliche DtoFactory und die betroffene Server-Dokumentation gemeinsam geprüft und synchron gehalten werden.
- `DtoTypes.d.md` dokumentiert, in welcher Lua-Datei bzw. DtoFactory ein Raum definiert ist. Diese Zuordnung ist die Soll-Quelle für spätere Server-Anpassungen.
- Viele Module registrieren globale Callbacks über `_G[...]`. Bei Änderungen an Registrierungslogik auf bestehende Namenskonventionen achten.
- Persistenter Zustand liegt typischerweise in EEP-Datenslots; dafür werden kurze Schlüssel wie `b`, `z`, `r`, `t` verwendet.
- Hard-Resets und Recovery-Pfade sind wichtig. Wenn neue zustandsbehaftete Objekte eingeführt werden, muss auch deren Reset-Verhalten bedacht werden.

## Web-Hinweise

- Die Web-App ist React 19 mit Vite und MUI, nicht Angular.
- Der Web-Server ist eine Electron-/Node-Anwendung in TypeScript.
- Gemeinsame Typen und Events liegen in `apps/web-shared` und sollten bei API-Änderungen konsistent mit angepasst werden.
- In Cypress-Specs keine lokalen Hilfsfunktionen wie `chooseDirectory()` einführen, wenn dadurch der Test nicht mehr von oben nach unten lesbar ist.
- In Cypress-Specs verkettete Aufrufe an `.` umbrechen, statt lange Chains in einer Zeile zu lassen.

## Nützliche Kommandos

- Abhängigkeiten installieren: `yarn`
- Web-App lokal starten: `yarn start-app`
- Web-App + Server im Spielmodus: `yarn start-playing`
- Headless-Server starten: `yarn start-server`
- Gesamtbuild: `yarn build`
- Web-App Storybook: `yarn storybook`
- Web-App E2E headless: `yarn workspace @ak/web-app run cy-tests-run-headless`
- Web-Server linten: `yarn workspace @ak/web-server run lint`
- Lua prüfen, falls lokal installiert:
  - `luacheck --config .luacheckrc lua/LUA`
  - `busted --config-file .busted --verbose --coverage --`
- Lua formatieren, falls lokal installiert:
  - `lua-format -c lua-format.conf -i <datei.lua>`
  - `lua-format -c lua-format.conf --check <datei.lua>`
  - dabei immer die Projektkonfiguration `lua-format.conf` aus dem Repo verwenden

## Testing und Verifikation

- Für Lua-Änderungen zuerst betroffene Specs unter `lua/LUA/spec` prüfen.
- Nach Lua-Änderungen, wenn die Laufzeit lokal verfügbar ist, immer zusätzlich ausführen:
  - `luacheck --config .luacheckrc lua/LUA`
  - `busted --config-file .busted --verbose --coverage --`
- Für Änderungen an Web-Typen oder Events mindestens `@ak/web-shared` und den betroffenen Consumer mitdenken.
- Wenn keine passende Laufzeit verfügbar ist, statisch prüfen und explizit benennen, was nicht ausgeführt werden konnte.

## Änderungsstil

- Keine unnötigen Umbenennungen oder Formatierungswellen.
- Keine bestehenden lokalen Benutzeränderungen zurücksetzen.
- Bei Reviews Schwerpunkt auf:
  - Zustandskonsistenz
  - Persistenzfehler
  - EEP-/Callback-Integration
  - Verhaltensregressionen
  - fehlende Tests
- Gegencheck der Architekturdokumentationen in [ARCHITECTURE.md](ARCHITECTURE.md) und den jeweiligen Teilarchitekturen (`ARCHITECTURE_LUA.md`, `ARCHITECTURE_SERVER.md`, `ARCHITECTURE_SHARED.md`, `ARCHITECTURE_APP.md`)
