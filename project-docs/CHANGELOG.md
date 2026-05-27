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

## **Control Extension v0.0.7-alpha** Vorschauversion

### Neu in v0.0.7-alpha

- ⭐ Neue Navigation mit angepasster Darstellung für Desktop, Tablet und Mobilgeräte
- ⭐ App-Bereiche werden nur noch angezeigt, wenn das passende Control-Extension-Modul in EEP aktiv ist
- ⭐ Neue Start-Hilfe zum Einbinden der Control Extension, wenn noch keine Module aktiv sind
- ⭐ Überarbeitetes Zug-Dashboard mit Panels für Steuerung, Kameras, Achsen, Linieninformationen, Rollmaterial und Texturen
- ⭐ Gemeinsame Zugachsen können zusammen gesteuert werden, wenn die Achsnamen bekannt sind
- ⭐ Überarbeitete Symbole und kompaktere Darstellungen für Zug- und Rollmaterialinformationen

### Lua Änderungen in v0.0.7-alpha

- ⭐ Einstellungen für Ampeln und ÖPNV verwenden nun lesbare deutsche Namen mit Umlauten
- ⭐ Demo-Anlagen für Ampeln und Linien wurden aktualisiert

### Behobene Fehler in v0.0.7-alpha

- 🐞 Einstellungen für Ampeln und ÖPNV werden wieder im erwarteten Format an die App geliefert
- 🐞 Boolean-Einstellungen aus der App werden in Lua zuverlässiger verarbeitet
- 🐞 Nicht verfügbare Module blenden ihre Karten und Navigationseinträge aus
- 🐞 Der aktive Zug wird nicht mehr angezeigt, wenn das Hub-Modul nicht geladen ist
- 🐞 Alte Statistik-Route wurde entfernt; Statistik- und Versionsinfos liegen nun in der Einblicke-Seite
- 🐞 Mehrere UI-Korrekturen an Navigation, Textdarstellung, Abständen, Karten und Zugauswahl

## **Control Extension v0.0.8-alpha** Vorschauversion

### Neu in v0.0.8-alpha

- ⭐ Neu: Kreuzungsassistent in der App zum Erstellen und Überarbeiten von Kreuzungen.
  - Lua-Code für Fahrspuren, Ampelgruppen, Phasen, Fußgängerquerungen, Strukturlichter und routenabhängige Freigaben
- ⭐ Neu: Detailansicht für Rollmaterial-Modelle mit zusammengefassten Modellinformationen inkl. Anzeige von Kennzeichen und Fahrzeugnummern für Rollmaterial
- ⭐ ÖPNV-Linien unterstützen Depotabschnitte, Depotanzeigen und das Setzen eines Fahrzeugverbands auf einen Linienabschnitt

### Lua Änderungen in v0.0.8-alpha

- ⭐ 🚅🚅🚅 Es werden viel mehr Daten aus der `.anl3` gelesen und stehen in Server, API und App zur Verfügung.
  Der Hub kann nun Routen, Züge, Rollmaterial, Signale, Weichen, Gleise, Kontakte und Kameras aus der Anlage vorab laden und dadurch viele EEP-Aufrufe während der Laufzeit vermeiden.

- ⭐ 🚅🚅🚅 Performance: Die Data Bridge sendet EEP-Ereignisse standardmäßig über eine Pipe an den Server.
  Dadurch ist für Daten keine Datei mehr möglich; Austausch über Dateien ist weiterhin als Fallback auswählbar.

- ⭐ Die Data Bridge puffert ausgehende Ereignisse, bis sie erfolgreich übertragen wurden.
  Nach Server-Neustarts oder neuer Server-Sitzung wird automatisch ein vollständiger Sync angefordert.

- ⭐ Neue EEP-Funkktionaufruf-Analyse.
  Mit `ControlExtension.setOptions({ eepCallAnalysis = { enabled = true, runs = 100 } })` kann eine begrenzte Messung der EEP-Aufrufe in `eep-call-analysis.json` geschrieben werden.

- ⭐ Das Road-Modul nutzt nun Kreuzungsphasen und Ampelgruppen als zentrale Begriffe.
  `IntersectionSwitching` wurde durch `TrafficPhase`/`IntersectionPhase` ersetzt; Ampelgruppen können mehrere sichtbare Ampeln und routenabhängige Fahrspurregeln bündeln.

- ⭐ Gesicherter Straßenbahnübergang: `TramCrossing`.
  `TramCrossing` zählt einfahrende und ausfahrende Straßenbahnen, speichert den Zustand am Signal und kann mehrere Signale sowie Sicherungsanzeigen gemeinsam schalten.

- ⭐ Fahrspuren können mit `driveOnDefaultSignalGroups(...)`, `driveOnlyOnSignalGroups(...)`, `driveAlsoOnSignalGroups(...)` und `showRequestsOnSignalGroups(...)` konfiguriert werden.

- ⭐ Das Transit-Modul unterstützt Messfahrten.
  Fahrzeuge mit Tag `v=1` protokollieren Soll-/Ist-Abfahrten, Fahrzeiten, Standzeiten und übersprungene Stationen.

- ⭐ Das Transit-Modul kann an Depot-Signalen wartende Fahrzeuge automatisch auf geänderte Routen prüfen und sie auf neue Strecken schicken.

- ⭐ `Train` und `RollingStock` unterstützen getrennte Kennzeichen und Fahrzeugnummern über die Tag-Schlüssel `p` und `w`.

### Behobene Fehler in v0.0.8-alpha

- 🐞 Server-Tests speichern keinen Serverzustand mehr im `exchange`-Verzeichnis
- 🐞 Alte `events-from-ce`-Dateien werden weiterhin nur verarbeitet, wenn sie ausdrücklich als pending markiert sind
- 🐞 Ausgewählter Zug wird auch nach Lua-Neustarts in der Web-App aktualisiert
- 🐞 Fehler beim Datei-I/O, beim Lesen eingehender Kommandos und beim Log-Schreiben werden robuster behandelt
- 🐞 Die App leert die Loganzeige beim Neuladen zuverlässiger
- 🐞 Demo-Anlage aus Tutorial 3 überschreiben `os` nicht mehr

### Dokumentation in v0.0.8-alpha

- 📖 Ampel- und Kreuzungstutorials wurden auf Ampelgruppen, Phasen und den neuen Kreuzungsassistenten angepasst
- 📖 Road-, Hub-, Data-Bridge- und DTO-Dokumentation wurde für neue Routen-, Kreuzungs-, Signal- und Rollmaterialfelder aktualisiert
- 📖 Entwicklerhinweise für Windows-Kommandos, Lua-Formatierung und Projektprüfungen wurden ergänzt

## **Control Extension v0.0.9-alpha** Vorschauversion

### Neu in v0.0.9-alpha

- ⭐ Neuer Ampelaufsteller ermöglicht das Aufstellen von MA1 Straba Immobilien-Ampeln.
  Damit kann man die Signale im Gehäuse ausrichten.

- ⭐ Der Kreuzungsassistent wählt alle bekannten Signal-Modelle für Ampeln automatisch (TrafficLightModel).

- ⭐ Die Ampelphasentabelle im Kreuzungsassistenten wurde kompakter und übersichtlicher.
  Ampelgruppen können nach Zufahrt sortiert oder mit Fußgängersignalen separat gruppiert werden.

- ⭐ Die Fuhrpark-Navigation wurde erweitert, der aktive Zug ist schneller erreichbar.

- ⭐ Neue Demo-Anlage `Kreuzung1` für das Road-Modul.

- ⭐ 🚅🚅🚅 Erhebliche Performance-Verbesserungen durch das Parsen der Anlagedatei und die Minimierung von
  wiederholten EEP-Funktionsaufrufen .

### Lua Änderungen in v0.0.9-alpha

- ⭐ Structures melden nun auch den internen EEP-Modellpfad `gsbname`.
  Der Hub liest dazu Strukturdaten aus der `.anl3` und ergänzt Modellnamen aus den passenden `.ini`-Dateien.

- ⭐ Der Hub schützt EEP-API-Aufrufe während des Speicherns der Anlage.
  Nach `EEPOnSaveAnl` wird die `.anl3` verzögert neu gelesen, damit EEP die Datei zuerst vollständig freigibt.

- ⭐ Structures können per eingehendem Kommando über Namen positioniert, rotiert, beleuchtet und mit Tag-Text beschrieben werden.
  Das nutzt der Ampelaufsteller zum Platzieren der Signalbilder.

- ⭐ `TrafficLightModel` besitzt jetzt eine stabile `id` und kann mit `TrafficLightModel.resolve(id)` aufgelöst werden.
  Dadurch kann generierter Lua-Code auch eigene Ampelmodelle zuverlässiger referenzieren.

- ⭐ ÖPNV-Linienabschnitte unterstützen mehrere Depotanzeigen und eine eigene Auswahlfunktion für diese Anzeigen.

- ⭐ hub/data-Klassen bieten jetzt Methoden an, die auf EEP-Funktionen zugreifen und sich die Daten im Objekt merken
  und das Objekt als `dirty` markieren, wenn es verändert wurde. Alle Rückgabewerte erfolgen ohne das `ok` von EEPGet.

  ```lua
  peekX()          -- Schaut nur im Cache nach und ruft keine EEP-Funktion auf
  getX()           -- read-through: nutzt Cache, ruft pullX() nur bei fehlendem Wert
  replaceX(...)    -- überschreibt Cache, kein EEPSet-Aufruf, dirty nur bei Änderung
  seedX(...)       -- Discovery-Seed, kein EEPSet, dirty nur bei Änderung
  pullX()          -- EEPGet -> replaceX -> dirty nur bei Änderung -> Rückgabewerte ohne ok-Flag
  setX(...)        -- idempotentes EEPSet -> replaceX nur bei akzeptiertem Set
  ```

### Behobene Fehler in v0.0.9-alpha

- 🐞 Der Lua Hub führt nicht mehr zum Einfrieren beim Speichern der Anlage.
- 🐞 Fußgängersignale werden im Kreuzungsassistenten und bei der Code-Erzeugung zuverlässiger erkannt.
- 🐞 Der Ampelaufsteller kann Befehle zum Ausrichten von Strukturen mehrfach senden, ohne dass gespeicherte Tags die weitere Nutzung blockieren.
- 🐞 Kamerabefehle des Ampelaufstellers werden korrekt an EEP weitergegeben.
- 🐞 Kontaktpunkte im Kreuzungsassistenten verwenden stabile `kpId`-Zeichenketten.
- 🐞 Demo-Anlagen überschreiben `os` nicht mehr.

### Dokumentation in v0.0.9-alpha

- 📖 Lua-Architektur um Speicherschutz, `.anl3`-Reload und Struktur-Metadaten ergänzt
- 📖 Tutorial zur Ampelkreuzung mit Immobilien aktualisiert
- 📖 Lua-Server-Vertragsnotizen für DTO-Änderungen ergänzt

## **Control Extension v0.0.10-alpha** Vorschauversion

### Neu in v0.0.10-alpha

- ⭐ Unterstützung für DH1-Ampeln im Road-Modul.
  Neue `TrafficLightModel`-Definitionen erkennen DH1-Signale automatisch und bilden die passenden Signalstellungen für Rot, Grün, Gelb, Aus und Fußgängerphasen ab.

- ⭐ Neue Demo-Anlage mit DH1-Ampeln für das Road-Modul.
  Enthalten ist die Anlage `Kreuzung1_mit_DH1_Ampeln` sowie ein passendes Lua-Beispiel.

- ⭐ Der Kreuzungsassistent schlägt Signalmodelle aus den verbauten Signalen der aktuellen Anlage vor.
  Die Modellauswahl zeigt zuerst die in der Anlage vorkommenden Signalmodelle und kann bei Bedarf auf alle bekannten Modelle erweitert werden.

### Lua Änderungen in v0.0.10-alpha

- ⭐ `TrafficLightModel` unterstützt jetzt Modellnamen-Patterns für die automatische Erkennung.
  Diese Muster werden über die Road-DTOs an Server und App geliefert, damit Lua, Server und Kreuzungsassistent dieselbe Modellerkennung verwenden.

- ⭐ Die `.anl3`-Erkennung übernimmt bei Signalen jetzt Modellpfad und Halteabstand.
  Dadurch können Signalmodelle im Kreuzungsassistenten zuverlässiger automatisch vorbelegt werden.

- ⭐ Die Struktur-Erkennung läuft in kleineren Batches und aktualisiert neben Position und Rotation auch Tag, Licht, Rauch und Feuer.

- ⭐ Fahrspur-Tipptexte können jetzt zusätzlich die Kontaktpunkt-ID der Fahrspur anzeigen.

### Behobene Fehler in v0.0.10-alpha

- 🐞 Fahrspur-Warteschlangen mit sehr langen Zugnamen überschreiten die maximale Tag-Länge der EEP-Signale nicht mehr.

- 🐞 Fahrspur-Warteschlangen bleiben konsistent, wenn ältere oder namenlose Fahrzeuge eine Fahrspur verlassen.

- 🐞 Fußgängersignale kombinierter Ampeln werden korrekt beim Neuladen der Kreuzung erkannt.

- 🐞 Der Kreuzungsassistent ordnet Ampelgruppen beim Überarbeiten vorhandener Kreuzungen auch über Script-Variablennamen zu.
  Dadurch funktionieren doppelte Anzeigenamen und Fußgängergruppen mit mehreren Signalen zuverlässiger.

- 🐞 Generierter Lua-Code verwendet für Fahrspuren stabile Kontaktpunkt-IDs (`setKpId`).

- 🐞 Fehler in Demo-Anlage behoben, der das TrafficLightModel falsch angelegt hat.
