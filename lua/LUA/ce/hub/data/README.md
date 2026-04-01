---
layout: page_with_toc
title: Hub-Daten
subtitle: Einsammeln, Strukturieren und Bereitstellen von EEP-Daten über den Datenbus
permalink: lua/ce/hub/data/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Was ist `ce.hub.data`?

Dieses Paket sammelt Daten aus EEP (Züge, Gleise, Signale, Weichen usw.), strukturiert sie in CeTypes mit DTOs und stellt sie über den Datenbus bereit, damit Server und Web App sie empfangen können.

## Datenbereiche und CeTypes

Jeder Datentyp hat einen eigenen Unterordner mit den zugehörigen Collectors und DTO-Typen:

- [rollingstock/](rollingstock/) — Rollmaterial (Fahrzeuge)
- [trains/](trains/) — Züge und Gleisbelegung
- [signals/](signals/) — Signale
- [switches/](switches/) — Weichen
- [structures/](structures/) — Immobilien und Landschaftselemente
- [slots/](slots/) — Datenslots
- [time/](time/) — EEP-Zeit
- [tracks/](tracks/) — Gleisinformationen
- [store/](store/) — Materialisierter Snapshot

Eine vollständige Übersicht aller CeTypes und DTO-Strukturen findest Du in [DTO.md](DTO.md).

---

Architekturbeschreibung: [README_DEV.md](README_DEV.md)
