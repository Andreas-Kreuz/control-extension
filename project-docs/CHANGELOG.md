Die Control Extension für EEP ist ein Neustart. Sie ersetzt die Lua-Bibliothek für EEP von Andreas Kreuz.
Der erste Fokus liegt auf dem Webserver und der Bereitstellung der Daten von EEP.

Für die Installation nutze die bereitgestellte ZIP-Datei innerhalb von EEP.
Updateanleitung siehe

## **Control Extension v0.0.1** Vorschauversion ⚠️

Diese Version funktioniert lokal und kann getestet werden.
Aktuell kann sich mit jedem Release das Erscheinungsbild der App und die inneren Abläufe ändern.

### Neu

- ⭐ **Lua Hub** - Lua Code zum Verwalten und Steuern von Anlagen
- ⭐ **Data Bridge** - Lua Code zum Anbinden des Servers
- ⭐ **Control Extension Server** - Eine Programm, dass die Daten aus EEP mit einer App und per API bereitstellt
- ⭐ **Control Extension App** - Eine Web App, die vom Server bereitgestellt wird und auf Recher oder Mobilgeräten genutzt werden kann

## **Control Extension v0.0.2** Vorschauversion

### Neu

- ⭐ Installation aller Dateien erfolgt nach `LUA\ce` bzw. `Resourcen\Anlagen\ce` im EEP-Verzeichnis
- ⭐ [Migrationsanleitung](/lua/LUA/ce/Migrate_ak_to_ce.md), wenn du von der Lua-Bibliothek für EEP von Andreas Kreuz kommst.
- ⭐ [Anleitung für Updates](/lua/LUA/ce/Update.md)
- ⭐ [Anleitung für Deinstallation](/lua/LUA/ce/Deinstallation.md)

### Bugfixes

- 🐞 Karten können wieder ausgewählt werden

### Dokumentation

- 📖 Installationsanleitungen aktualisiert
- 📖 Startseite der Dokumentation aktualisiert

## **Control Extension v0.0.3** Vorschauversion

### Neu

- ⭐ Kompatibilitätsschicht für alte Anlagen mit der Lua-Bibliothek von Andreas Kreuz
  - Dafür wird ein eigener Installer bereitgestellt: `ak-compat-layer-for-control-extension-<VERSION>-installer.zip`
  - `[Using_ak_compat_layer.md](/lua/LUA/ce/Using_ak_compat_layer.md)` beschreibt, wie man bisherige Anlagen mit Ampelsteuerung weiterverwenden kann.
  - Es wird trotzdem mittelfristig empfohlen, auf die neue Struktur umzustellen.

## **Control Extension v0.0.4** Vorschauversion

### Neu

- ⭐ Haltestellenanzeige für Linien

### Dokumentation

- 📖 Neue App Ansicht auf der Dokumentationsseite
