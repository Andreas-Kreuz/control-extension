---
layout: page_with_toc
title: Hub - Entwickler
subtitle: Interner Laufzeitfluss und Verantwortlichkeiten des Lua-Hubs
permalink: lua/LUA/ce/hub/dev/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Hub - Entwickler

## Interner Laufzeitfluss

Der Hub orchestriert registrierte Module, Datenupdates und Publishing in einem festen Ablauf:

1. `ce.ControlExtension` ist der stabile Einstiegspunkt für EEP-Skripte.
2. `ModuleRegistry` registriert die verwendeten Lua-Module.
3. `MainLoopRunner` führt Initialisierung und Zyklus aus.
4. `CeHubModule.init()` registriert Hub-Publisher und Hub-Funktionen und startet die Initial-Discovery und Initial-Updates.
5. `CeHubModule.run()` führt die laufende Discovery und die laufenden Updates aus.
6. Die registrierten Publisher veröffentlichen Änderungen über `DataChangeBus`.
7. `InternalDataStore` kann daraus einen materialisierten Snapshot halten.
8. `ServerEventBuffer` nimmt veröffentlichte Events für die Bridge entgegen.
9. Die Bridge schreibt Austauschdateien und liest Remote-Kommandos.

Design-Entscheidung: Die öffentliche API beschränkt sich auf `ce.ControlExtension`. Interne Pfade unter `ce.hub.*` sind Infrastruktur und gelten nicht als stabile öffentliche API.

## Rollen im Hub-Datenpfad

Für die Hub-Daten gilt heute eine klare Aufteilung der Verantwortlichkeiten:

- `Domain`
  Zustand, Getter/Setter und Dirty-Tracking
- `Registry`
  zentrale Map der bekannten Objekte nach ID
- `Discovery`
  erkennt neue und entfernte Objekte
- `Updater`
  liest EEP-Zustand und schreibt per Setter in die Domain-Objekte
- `Publisher`
  wertet Sync-Optionen aus und sendet Add/Change/Remove-Events
- `DtoFactory`
  baut serialisierbare DTOs

Einfachere Singleton-CeTypes wie Zeit, Wetter, Version oder Runtime nutzen meist nur `Registry + Updater + Publisher`, folgen aber denselben Zuständigkeitsgrenzen:

- Fetch-Logik liegt im `Updater`
- Sync-Logik liegt im `Publisher`

## Rolle von `CeHubModule`

`CeHubModule` ist heute der zentrale Orchestrator des Hub-Datenpfads.

Es übernimmt insbesondere:

- Registrierung der Hub-CeTypes im `CeTypeRegistry`
- Anwenden der Sync-Optionen auf Publisher, CeTypes und Felder
- Initial-Discovery und Initial-Updates in `init()`
- laufende Discovery und Updates in `run()`

Typische Aufrufe im aktiven Pfad sind zum Beispiel:

- `StructureDiscovery.runInitialDiscovery()`
- `StructureUpdater.runInitialUpdate(...)`
- `SignalDiscovery.runDiscovery()`
- `SignalUpdater.runUpdate(...)`
- `TrainDiscovery.runDiscovery(...)`
- `TrainUpdater.runUpdate(...)`
- `RollingStockUpdater.runUpdate(...)`

## Rolle der `*StatePublisher`

Die historischen `*StatePublisher.lua`-Dateien existieren weiterhin, aber ihre Verantwortung ist heute kleiner:

- sie bleiben die registrierbaren Objekte für `StatePublisherRegistry`
- sie halten kompatible Felder wie `name`, `enabled`, `initialize()` und `syncState()`
- auf dem aktiven Pfad rufen sie nur noch den zugehörigen `Publisher.syncState(...)` auf

Das bedeutet:

- Discovery gehört nicht mehr in die StatePublisher
- Fetch-Logik gehört nicht mehr in die StatePublisher
- die eigentliche Synchronisationsentscheidung bleibt beim `Publisher`

## Bridge-Anbindung

Der `HubBridgeConnector` registriert die Hub-Publisher an der `StatePublisherRegistry`, damit sie über den `DataChangeBus` veröffentlichen können.

Diese Trennung bleibt bewusst bestehen:

- Fachlogik kennt den BridgeConnector nicht
- der BridgeConnector kennt die registrierbaren Publisher
- `DataChangeBus` bleibt generische Event-Infrastruktur

## MainLoopRunner und Publisher-Lebenszyklus

Der `MainLoopRunner` arbeitet weiterhin mit Modulen und registrierten Publisher-Adaptern:

1. `module.init()`
2. `module.run()`
3. `statePublisher.initialize()`
4. `statePublisher.syncState()`

Wichtig ist aber die neue Verantwortung innerhalb dieses Schemas:

- die relevante Datenarbeit liegt bei den Modulen, insbesondere bei `CeHubModule`
- `statePublisher.initialize()` ist meist nur noch leichtgewichtig oder ein Kompatibilitätshaken
- `statePublisher.syncState()` delegiert an den eigentlichen `Publisher`

## Discovery mit gekoppelten CeTypes

Nicht jeder CeType scannt die Welt unabhängig. Der wichtigste gekoppelte Pfad ist der Zugpfad:

- `TrainDiscovery` erkennt Tracks, Züge und RollingStock-Existenz gemeinsam
- `TrainUpdater` aktualisiert Zugobjekte
- `RollingStockUpdater` aktualisiert RollingStock-Objekte
- `TrackPublisher`, `TrainPublisher` und `RollingStockPublisher` veröffentlichen ihre Änderungen getrennt

Dadurch bleibt die Discovery zentral, während Registry, Updater und Publisher weiter je CeType getrennt bleiben.

## Rückgabewerte und Events

Die aktiven Hub-Publisher transportieren ihre Nutzdaten primär über `DataChangeBus.fire*()`.
Die Rückgabewerte von `syncState()` sind meist nur `{}` oder eine Kompatibilitätsschicht für bestehende Aufrufer.

Wenn ein Publisher Daten direkt zurückgibt, müssen diese nur serialisierbare Werte enthalten. Funktionen oder nicht-string-/nicht-number-Schlüssel sind unzulässig.

## Weiterführende Dokumentation

- [OPTIONS.md](OPTIONS.md) - Hub-Optionen, Fetch-Policy und Sync-Policy
- [data/README_DEV.md](data/README_DEV.md) - Rollen und DTO-Fluss der Hub-Daten
- [data/DTO.md](data/DTO.md) - aktive CeTypes und DTO-Felder
- [docs/Architecture.md](docs/Architecture.md) - Hub-Architektur und aktuelle Zielstruktur

---

Informationen für Anwender: [README.md](README.md)
