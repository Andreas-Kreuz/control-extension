---
layout: page_with_toc
title: Hub-Daten
subtitle: Erfassen, Strukturieren und Veröffentlichen von EEP-Daten über den Datenbus
permalink: lua/LUA/ce/hub/data/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Was ist `ce.hub.data`?

Dieses Paket bildet die Datenpipeline der Control Extension für EEP-Daten wie Züge, Gleise, Signale, Weichen, Strukturen und Systemzustände ab.

Die aktive Struktur folgt dabei einem einheitlichen Muster:

- `Domain`: hält Zustand, Getter/Setter und Dirty-Tracking
- `Registry`: hält die bekannten Objekte eines CeTypes zentral nach ID
- `Discovery`: beantwortet "was existiert?" und pflegt neue/entfernte Einträge
- `Updater`: beantwortet "welche Felder aktualisieren wir?" und liest EEP-Werte unter Beachtung der Fetch-Optionen
- `Publisher`: beantwortet "welche Änderungen senden wir?" und beachtet die Sync-Optionen
- `DtoFactory`: serialisiert Domain-Objekte in DTOs für den Datenbus

`CeHubModule` orchestriert den Lebenszyklus:

1. Initiale Discovery und Initial-Updates in `module.init()`
2. Laufende Discovery und Updates in `module.run()`
3. Veröffentlichungen in den jeweiligen `*Publisher.syncState(...)`

Die verbleibenden `*StatePublisher.lua`-Dateien sind heute nur noch dünne Sync-Adapter, damit die Hub-Integration stabil bleibt.

## Datenbereiche und CeTypes

Jeder Datenbereich hat einen eigenen Unterordner. Dynamische Weltobjekte nutzen in der Regel die volle Klassenstruktur, einfache Singleton-Daten meist nur `Registry + Updater + Publisher`.

- [rollingstock/](rollingstock/) - Rollmaterial
- [trains/](trains/) - Züge, RollingStock-Discovery und Gleisbelegung
- [signals/](signals/) - Signale und wartende Fahrzeuge
- [switches/](switches/) - Weichen
- [structures/](structures/) - Immobilien und Landschaftselemente
- [tracks/](tracks/) - Gleisinformationen nach Track-Typ
- [slots/](slots/) - Datenslots
- [time/](time/) - EEP-Zeit
- [weather/](weather/) - Wetterdaten
- [runtime/](runtime/) - Laufzeit- und Frame-Metriken
- [framedata/](framedata/) - aktuelle Frame-Informationen
- [version/](version/) - Versions- und Layoutinformationen
- [modules/](modules/) - Modulstatus

Eine vollständige Übersicht aller aktiven CeTypes und DTO-Strukturen findest Du in [DTO.md](DTO.md).

---

Architekturbeschreibung: [README_DEV.md](README_DEV.md)
