---
layout: page_with_toc
title: Hub-Architektur
subtitle: Aktive Verantwortlichkeiten und Zielstruktur des Lua-Hubs
permalink: lua/LUA/ce/hub/docs/architecture/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Architektur des Lua-Hubs

Diese Datei beschreibt die aktive Architektur des Lua-Hubs und die Richtung für weitere Aufräumarbeiten.
Sie ist damit keine reine Zieldokumentation mehr, sondern die führende Beschreibung des aktuellen Zustands.

## Architekturprinzipien

Die aktuelle Architektur trennt bewusst zwischen drei Bereichen:

1. `hub`
   gemeinsame Laufzeit-, Daten- und Event-Infrastruktur
2. `databridge`
   dateibasierte Kommunikation mit dem Server
3. `mods`
   Fachlogik wie Straße und ÖPNV

Daraus folgen diese Leitlinien:

- jede Datei soll eine kleine, klar benannte Verantwortung haben
- fachlicher Zustand, EEP-Zugriff und Publishing sollen getrennt bleiben
- öffentliche Einstiegspunkte sollen stabil bleiben, interne Pfade gelten als Infrastruktur
- modulbezogenes Publishing bleibt beim jeweiligen Owner
- generische Infrastruktur kennt keine Fachsemantik

## Hub

Der Hub ist die interne Plattform des Lua-Teils. Er kapselt die gemeinsame Laufzeit, Datenhaltung und Publishing-Verdrahtung.

### `hub/`

Direkt unter `hub/` liegen die zentralen Laufzeitbausteine:

- `CeHubModule`
  zentraler Orchestrator des Hub-Datenpfads
- `MainLoopRunner`
  führt den Modul- und Publisher-Zyklus aus
- `ModuleRegistry`
  registriert die verwendeten Lua-Module
- `StatePublisherRegistry`
  hält die registrierbaren Publisher-Adapter
- `HubBridgeConnector`
  verbindet den Hub mit der Publishing- und Bridge-Infrastruktur

### `hub/data`

`hub/data` folgt heute auf dem aktiven Pfad einer klaren Rollenstruktur:

- `Domain`
- `Registry`
- `Discovery`
- `Updater`
- `Publisher`
- `DtoFactory`

Typische Beispiele:

- `structures`
  `Structure`, `StructureRegistry`, `StructureDiscovery`, `StructureUpdater`, `StructurePublisher`, `StructureDtoFactory`
- `signals`
  `Signal`, `SignalRegistry`, `SignalDiscovery`, `SignalUpdater`, `SignalPublisher`, `SignalDtoFactory`
- `switches`
  `Switch`, `SwitchRegistry`, `SwitchDiscovery`, `SwitchUpdater`, `SwitchPublisher`, `SwitchDtoFactory`
- `trains`
  `Train`, `TrainRegistry`, `TrainDiscovery`, `TrainUpdater`, `TrainPublisher`, `TrainDtoFactory`
- `rollingstock`
  `RollingStock`, `RollingStockRegistry`, `RollingStockUpdater`, `RollingStockPublisher`, `RollingStockDtoFactory`
- `tracks`
  gemeinsamer `TrackRegistry`, `TrackPublisher`, `TrackDtoFactory`, mit Discovery über `TrainDiscovery`

Einfachere Singleton-CeTypes wie `time`, `weather`, `runtime`, `version`, `modules`, `slots` und `framedata` verwenden meist nur:

- `Registry`
- `Updater`
- `Publisher`
- `DtoFactory`

### `CeHubModule` als Orchestrator

`CeHubModule` besitzt heute die aktive Discovery- und Update-Orchestrierung.

Das bedeutet:

- `init()` startet Initial-Discovery und Initial-Updates
- `run()` startet laufende Discovery und Updates
- Publisher werden dort nicht mehr als Ort der Datenerfassung verstanden

Beispielhafte Aufrufe im aktiven Pfad:

- `SignalDiscovery.runInitialDiscovery()`
- `SignalUpdater.runUpdate(...)`
- `StructureDiscovery.runInitialDiscovery()`
- `StructureUpdater.runInitialUpdate(...)`
- `TrainDiscovery.runDiscovery(...)`
- `TrainUpdater.runUpdate(...)`
- `RollingStockUpdater.runUpdate(...)`

### `*StatePublisher` als Adapter

Die `*StatePublisher.lua`-Dateien bleiben auf dem aktiven Pfad erhalten, aber in reduzierter Rolle:

- sie erfüllen die Schnittstelle für `StatePublisherRegistry`
- sie halten `enabled`, `name`, `initialize()` und `syncState()`
- ihr `syncState()` delegiert an den eigentlichen `Publisher`

Damit sind sie heute vor allem Registrierungs- und Kompatibilitätsadapter, nicht mehr der Ort für Discovery oder EEP-Fetching.

### `hub/publish`

`hub/publish` stellt die generische Event-Infrastruktur bereit:

- `DataChangeBus`
- `InternalDataStore`
- Event-Dispatcher und Transporthelfer

Dabei gilt weiter:

- `DataChangeBus` bleibt generisch
- der Bus interpretiert keine Fachobjekte
- Listener-Verdrahtung passiert außerhalb des Busses

### `hub/scheduler`

`hub/scheduler` enthält die gemeinsame Ablaufhilfe für zeitversetzte Aktionen:

- `Scheduler`
- `Task`
- scheduler-nahe Helfer

### `hub/eep`

`hub/eep` enthält technische EEP-Adapter und Simulator-Unterstützung:

- Wrapper um EEP-Funktionen
- Simulator-Unterstützung für Tests
- Hilfen für EEP-spezifische Text- und Anzeigeformate

### `hub/util`

`hub/util` enthält technische Helfer ohne Fachsemantik:

- Tabellen- und Queue-Helfer
- Laufzeitmetriken
- Persistenzhilfen

## Mods

Unter `mods/` liegt die Fachlogik der Erweiterungen, insbesondere:

- `road`
- `transit`

Jedes Fachmodul soll intern mindestens zwischen zwei Rollen unterscheiden:

1. Domänenlogik
   Modelle, Regeln, Zustandsübergänge, Registries und EEP-Fachlogik
2. modulbezogenes Publishing
   modulbezogene Publisher, DtoFactories und Bridge-Verdrahtung

## DataBridge

Die dateibasierte Kommunikation zwischen Lua und Server bleibt im Bereich `ce.databridge`.

Ihre Verantwortung umfasst:

- Initialisierung der I/O-Infrastruktur
- Verwaltung des Austauschverzeichnisses
- Lesen und Ausführen erlaubter Remote-Kommandos
- Puffern und Schreiben ausgehender Events
- Dateihandshake mit dem Server

Die Bridge besitzt keinen eigenen Fachzustand. Sie transportiert, puffert, liest und schreibt nur.

## Aktiver Laufzeitfluss

Der heutige Laufzeitfluss ist:

1. `ce.ControlExtension` dient als stabiler Einstiegspunkt für EEP-Skripte.
2. `ModuleRegistry` registriert die verwendeten Lua-Module.
3. `MainLoopRunner` ruft `module.init()` und später `module.run()` auf.
4. `CeHubModule.init()` registriert Publisher/Funktionen und führt Initial-Discovery sowie Initial-Updates aus.
5. `CeHubModule.run()` führt Discovery und Updates aus und startet danach den Scheduler.
6. `MainLoopRunner` ruft `initialize()` und `syncState()` der registrierten Publisher-Adapter auf.
7. Die eigentlichen Publisher veröffentlichen Änderungen über `DataChangeBus`.
8. `InternalDataStore` und `ServerEventDispatcher` konsumieren diese Events für Snapshot und Server-Transport.

## Discovery mit gekoppelten CeTypes

Einige CeTypes sind bewusst gekoppelt.
Das wichtigste Beispiel ist der Zugpfad:

- `TrainDiscovery` erkennt Tracks, Züge und RollingStock-Existenz gemeinsam
- `TrackPublisher`, `TrainPublisher` und `RollingStockPublisher` veröffentlichen anschließend getrennt

Damit bleibt die Discovery zentral, während Registry, Updater und Publisher weiter je CeType getrennt bleiben.

## Zielstruktur im Repository

Die aktuelle Struktur ist in kompakter Form:

```text
lua/LUA/ce/
  ControlExtension.lua
  hub/
    CeHubModule.lua
    MainLoopRunner.lua
    ModuleRegistry.lua
    StatePublisherRegistry.lua
    scheduler/
    eep/
    data/
      dynamic/
      framedata/
      modules/
      rollingstock/
      runtime/
      signals/
      slots/
      structures/
      switches/
      time/
      tracks/
      trains/
      version/
      weather/
    docs/
    publish/
    util/
  databridge/
  mods/
    road/
    transit/
```

## Öffentliche Schnittstellen

Stabil gehalten werden nur wenige Einstiegspunkte:

- `ce.ControlExtension`
- `ce.mods.road.CeRoadModule`
- `ce.mods.transit.CeTransitModule`

Interne Pfade unter `ce.hub.*` und `ce.databridge.*` sind Infrastruktur und sollen nicht als stabile öffentliche API behandelt werden.
