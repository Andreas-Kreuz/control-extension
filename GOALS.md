# Ziele dieses Projekts

## Ziele für Lua Hub `lua/LUA/ce/hub`

- [x] Prinzipieller Aufbau und Ablaufsteuerung \
       siehe [lua/LUA/ce/README.md](lua/LUA/ce/README.md)

- [x] Erfassung von Daten aus EEP-Lua-Funktionen \
       siehe [lua/LUA/ce/hub/data/README.md](lua/LUA/ce/hub/data/README.md)

- [x] Einfaches Einbinden der Control Extension \
       Funktioniert mit minimalem Code: [lua/LUA/ce/README.md](lua/LUA/ce/README.md)

- [ ] TODO: Internes Halten der kompletten erfassten Daten \
       geplant mit [lua/LUA/ce/hub/publish/InternalDataStore.lua](lua/LUA/ce/hub/publish/InternalDataStore.lua)

- [ ] TODO: Erfassung weiterer Daten mit Lua-Funktionen \
       Prüfen von Daten für Signale, Weichen, Züge, Rollmaterial, usw.

- [ ] TODO: Erfassung der Anlagedatei von EEP \
       Suche nach Lua internen Möglichkeiten zur Analyse der Anlagendatei

## Ziele für Data Bridge `lua/LUA/ce/databridge`

siehe [lua/LUA/ce/hub/databridge/README.md](lua/LUA/ce/databridge/README.md)

- [x] Eventbasierte Bereitstellung der Daten an den EEP-Webserver
- [x] Log-Ausgabe aus EEP als Datei
- [x] Entgegennahme von Lua-Kommandos
- [ ] Bereitstellung aller internen Daten als Datei

## Ziele für Web-Server

siehe [apps/web-server/README.md](apps/web-server/README.md)

- [x] TODO: Bereitstellung DTOs als TypeScript und Abgleich mit LUA
- [x] TODO: Bereitstellung der Daten über eine Web-API
- [ ] TODO: Bereitstellung der Daten über eine versionierte Web-API

## Ziele für Web-App

siehe [apps/web-app/README.md](apps/web-app/README.md)

- [ ] TODO: Anzeige und durchsuchen der Web-API
- [x] Anzeige der Züge
  - [x] Kameras auf Züge ausrichten
  - [ ] TODO: Züge filtern
  - [ ] TODO: Tag-Texte anzeigen
- [ ] TODO: Anzeige von Immobilien, Weichen, Speicherplätzen

## Ziele für Module (generell)

- [x] Dokumenation für XxxCeModule erstellt
- [ ] TODO: Template für Modul erstellen

## Ziele für das Eisenbahnmodul `ce/rail`

siehe [lua/LUA/ce/rail/README.md](lua/LUA/ce/rail/README.md)

- [ ] TODO: RailCeModule einführen
- [ ] TODO: Moduloptionen speichern und im GUI steuern
- [ ] TODO: Besetztmelder für Gleise und Bahnhöfe
- [ ] TODO: Tipptexte für Besetztmelder in Bahnhöfen und Gleisabschnitten
- [ ] TODO: Anzeige der Stationen in der Web App

## Ziele für das Straßenmodul `ce/road`

siehe [lua/LUA/ce/mods/road/README.md](lua/LUA/ce/mods/road/README.md)

- [x] Ampelsteuerung
- [x] Moduloptionen speichern in der Web App
- [x] Manuelle Ampelsteuerung in der Web App
- [x] Kameras für Kreuzungen speichern

## Ziele für das ÖPNV-Modul `ce/transit`

siehe [lua/LUA/ce/mods/transit/README.md](lua/LUA/ce/mods/transit/README.md)

- [x] Moduloptionen speichern und im GUI steuern
- [x] Routen und Stationen setzen
- [x] Alle Stationsanzeigen bei Kontaktpunktüberfahrt aktualisieren
- [ ] TODO: Anzeige der Stationen in der Web App
