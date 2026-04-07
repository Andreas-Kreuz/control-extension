---
layout: page_with_toc
title: Hub-Daten - Entwickler
subtitle: Architektur, DTO-Fluss und Verantwortlichkeiten im ce.hub.data-Paket
permalink: lua/LUA/ce/hub/data/dev/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Hub-Daten - Entwickler

## Ziel der Struktur

Die Datenstruktur in `ce.hub.data` trennt fachlichen Zustand, EEP-Zugriff und Veröffentlichung bewusst voneinander.

Für dynamische CeTypes ist die gewünschte Rollenverteilung:

- `Domain`: Zustand, Getter/Setter, Dirty-Tracking
- `Registry`: zentrale Map der bekannten Objekte nach ID
- `Discovery`: erkennt neue und entfernte Objekte
- `Updater`: liest EEP-Zustand und schreibt per Setter in die Domain-Objekte
- `Publisher`: sendet Add/Change/Remove-Events und wertet Sync-Optionen aus
- `DtoFactory`: baut serialisierbare DTOs

Einfachere Singleton-CeTypes wie Zeit, Wetter oder Version nutzen meist nur den kleineren Ausschnitt `Registry + Updater + Publisher`, folgen aber denselben Zuständigkeitsgrenzen:

- Fetch-Logik liegt im `Updater`
- Sync-Logik liegt im `Publisher`

## DTO-Konvention: CeTypes und Listen

Alle Daten werden in eine dreistufige Map-Struktur einsortiert:

```text
ceType : string
  └─ dtoId : string | number
       └─ dto : table
```

- `ceType` ist die stabile Typkennung des Datenbereichs, z. B. `"ce.hub.Train"` oder `"ce.hub.Signal"`.
- `dtoId` ist ein eindeutiger Schlüssel innerhalb des CeTypes, z. B. der Zugname oder die Signal-ID.
- `dto` ist eine flache serialisierbare Tabelle ohne Funktionen.

## Ablauf: Wie kommt ein DTO auf den Bus?

1. `CeHubModule.init()` startet Initial-Discovery und Initial-Updates.
2. `CeHubModule.run()` führt die laufende Discovery und die laufenden Updates aus.
3. Ein `*Publisher` bewertet die Sync-Optionen des CeTypes.
4. Eine `*DtoFactory` serialisiert Domain-Objekte oder Patches in DTOs.
5. Der Publisher veröffentlicht Änderungen über `DataChangeBus.fire*()`.

Die historischen `*StatePublisher.lua`-Dateien sind auf dem aktiven Pfad nur noch dünne Adapter, die `Publisher.syncState(...)` mit den zugehörigen Optionen aufrufen.

## Optionen und Verantwortlichkeiten

Die Sync- und Fetch-Optionen werden auf drei Ebenen angewendet:

- Feld-Ebene: `collect = false`
  Der `Updater` liest dieses Feld nicht und die `DtoFactory` nimmt es nicht in DTOs auf.
- CeType-Ebene: `mode = all | none | selected`
  Das `CeHubModule` und die `Publisher` entscheiden damit, ob ein CeType vollständig, gar nicht oder nur für selektierte Objekte synchronisiert wird.
- Publisher-Ebene: `enabled = true | false`
  Der jeweilige `Publisher` kann komplett deaktiviert werden.

## Discovery und gekoppelte CeTypes

Nicht jeder CeType scannt die Welt unabhängig. Ein wichtiges Beispiel ist der Zugpfad:

- `TrainDiscovery` erkennt Tracks, Züge und RollingStock-Existenz gemeinsam.
- `TrainUpdater` aktualisiert die bekannten Zugobjekte.
- `RollingStockUpdater` aktualisiert die bekannten RollingStock-Objekte.
- `TrackPublisher`, `TrainPublisher` und `RollingStockPublisher` veröffentlichen anschließend ihre Änderungen getrennt.

Damit bleibt die Discovery-Logik zentral, während Registry, Updater und Publisher weiter je CeType getrennt bleiben.

## Vollständige DTO-Strukturen

Alle aktiven CeTypes und ihre DTO-Felder sind in [DTO.md](DTO.md) dokumentiert.

---

Informationen für Anwender: [README.md](README.md)
