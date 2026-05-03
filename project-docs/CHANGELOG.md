Die Control Extension für EEP ist ein Neustart. Sie ersetzt die Lua-Bibliothek für EEP von Andreas Kreuz.
Der erste Fokus liegt auf dem Webserver und der Bereitstellung der Daten von EEP.

Für die Installation nutze die bereitgestellte ZIP-Datei innerhalb von EEP.
Updateanleitung siehe

## **Control Extension v0.0.1** Vorschauversion ⚠️

Diese Version funktioniert lokal und kann getestet werden.
Aktuell kann sich mit jedem Release das Erscheinungsbild der App und die inneren Abläufe ändern.

### Neu in v0.0.1

- ⭐ **Lua Hub** - Lua Code zum Verwalten und Steuern von Anlagen
- ⭐ **Data Bridge** - Lua Code zum Anbinden des Servers
- ⭐ **Control Extension Server** - Ein Programm, das die Daten aus EEP mit einer App und per API bereitstellt
- ⭐ **Control Extension App** - Eine Web App, die vom Server bereitgestellt wird und auf Rechnern oder Mobilgeräten genutzt werden kann

## **Control Extension v0.0.2** Vorschauversion

### Neu in v0.0.2

- ⭐ Installation aller Dateien erfolgt nach `LUA\ce` bzw. `Resourcen\Anlagen\ce` im EEP-Verzeichnis
- ⭐ [Migrationsanleitung](/lua/LUA/ce/Migrate_ak_to_ce.md), wenn du von der Lua-Bibliothek für EEP von Andreas Kreuz kommst.
- ⭐ [Anleitung für Updates](/lua/LUA/ce/Update.md)
- ⭐ [Anleitung für Deinstallation](/lua/LUA/ce/Deinstallation.md)

### Behobene Fehler in v0.0.2

- 🐞 Karten können wieder ausgewählt werden

### Dokumentation in v0.0.2

- 📖 Installationsanleitungen aktualisiert
- 📖 Startseite der Dokumentation aktualisiert

## **Control Extension v0.0.3** Vorschauversion

### Neu in v0.0.3

- ⭐ Kompatibilitätsschicht für alte Anlagen mit der Lua-Bibliothek von Andreas Kreuz
  - Dafür wird ein eigener Installer bereitgestellt: `ak-compat-layer-for-control-extension-<VERSION>-installer.zip`
  - `[Using_ak_compat_layer.md](/lua/LUA/ce/Using_ak_compat_layer.md)` beschreibt, wie man bisherige Anlagen mit Ampelsteuerung weiterverwenden kann.
  - Es wird trotzdem mittelfristig empfohlen, auf die neue Struktur umzustellen.

## **Control Extension v0.0.4** Vorschauversion

### Neu in v0.0.4

- ⭐ Haltestellenanzeige für Linien
- ⭐ Neue Seite mit Einblicken in die App

### Dokumentation in v0.0.4

- 📖 Neue App Ansicht auf der Dokumentationsseite

## **Control Extension v0.0.5** Vorschauversion

### Neu in v0.0.5

- ⭐ Anzeige nächster Halte pro Fahrzeug
- ⭐ Filter für Fahrzeuge mit Linieninformationen
- ⭐ Neue Tooltips für Ampeln, die nur den Kurznamen und die Schaltung anzeigen

### Behobene Fehler in v0.0.5

- 🐞 Installer enthält keine doppelten Dateien mehr

## **Control Extension v0.0.6-alpha** Vorschauversion

### Neu in v0.0.6-alpha

- ⭐ Anzeige von Texturenamen und Inhalten für Zug und Fahrzeug
- ⭐ Anzeige von Achsen und Setzen von Achsen pro Rollmaterial
- ⭐ Neues Zug-Dashboard zum Anzeigen und Steuern des ausgewählten Zugs
- ⭐ Neue Über-Seite mit Versions- und Updateinformationen
- ⭐ Neue Fahrzeug- und Stationssymbole für eine klarere Darstellung in Listen
- ⭐ Suchfelder können nun optional verwendet werden

### Lua Änderungen in v0.0.6-alpha

- ⭐ `RollingStock` meldet Achs- und Texturinformationen.
  In der App und über die Daten-API stehen jetzt `axisNamesKnown`, `axisNames`, `axisValues`, `textureNames` und `xmlModel` pro `RollingStock` zur Verfügung.

- ⭐ `ControlExtension.setOptions(...)` unterstützt `anl3path`.
  Damit kann der Hub die aktuelle `.anl3`-Datei lesen und zusätzliche Daten wie Rollmaterial-Modelldateien und Achsnamen finden: `ControlExtension.setOptions({ anl3path = "C:\\Spiele\\Trend\\EEP18\\Resourcen\\Anlagen\\meine-anlage.anl3" })`.

- ⭐ `Train` meldet den Lichtstatus.
  Das Zug-DTO enthält `lights` mit den Lichtquellen `0` bis `3`, zum Beispiel `{ ["0"] = true, ["1"] = false }`.

- ⭐ `TransitTrain` meldet jetzt auch den Startpunkt.
  Neben `line`, `destination`, `direction` und `nextStations` gibt es jetzt `origin`; `RollingStockModel` kann diesen Wert mit `setOrigin(rollingStockName, origin)` setzen.

- ⭐ `RollingStockModel` kann den nächsten Halt anzeigen.
  Eigene `RollingStockModel`-Implementierungen können optional `setNextStop(rollingStockName, nextStop)` implementieren, um den nächsten Halt zu setzen. Damit kann man z.B. in den Texturen eines Modell den nächsten Halt anzeigen.

- ⭐ `RollingStockModels` registriert eigene Modelle über Modellname und `.3dm`-/XML-Modellpfad.
  Statt nur über den sichtbaren Namen kann ein `RollingStockModel` jetzt so registriert werden: `RollingStockModels.addModel("Mein Modell", "SCHIENE\\TRAM\\MEIN_MODELL.3dm", model)`.

- ⭐ `IncomingCommandExecutor` unterstützt Booleans.
  Die Argumente `"true"` und `"false"` werden automatisch zu `true` und `false`, wenn ein registriertes Lua-Kommando aufgerufen wird.

### Behobene Fehler in v0.0.6-alpha

- 🐞 Der Server verarbeitet keine veralteten `events-from-ce`-Dateien mehr
- 🐞 Das Beenden des Servers räumt Austauschdateien zuverlässiger auf
- 🐞 Linieninformationen werden nach EEP-Routenwechseln zuverlässiger aktualisiert; Fahrzeuge ohne passende Linienroute verschwinden aus Haltestellenanzeigen
- 🐞 Mehrere UI-Korrekturen für Achsensteuerung, Textfarben, Abstände und Zugauswahl
