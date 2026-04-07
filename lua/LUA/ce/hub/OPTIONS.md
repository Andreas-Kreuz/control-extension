---
layout: page_with_toc
title: Hub-Optionen
subtitle: Fetch- und Sync-Policy für CeHubModule
permalink: lua/LUA/ce/hub/options/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Optionen für `CeHubModule`

Die Hub-Optionen werden über `CeHubModule.setOptions(...)` gesetzt.

Der aktive Einstiegspunkt ist:

```lua
local CeHubModule = require("ce.hub.CeHubModule")

CeHubModule.setOptions({
    waitForServer = true,
    sync = {
        publishers = { ... },
        ceTypes = { ... },
        fields = { ... },
    },
})
```

## Überblick

Die Optionen sind heute in drei Sync-Ebenen plus einer allgemeinen Laufzeitoption aufgeteilt:

- `waitForServer`
  steuert, ob auf einen verfügbaren Server gewartet werden soll
- `sync.publishers`
  aktiviert oder deaktiviert ganze Publisher
- `sync.ceTypes`
  steuert, ob ein CeType komplett, gar nicht oder nur selektiv synchronisiert wird
- `sync.fields`
  steuert auf Feldebene, ob ein Feld überhaupt gelesen und in DTOs aufgenommen wird

Wichtig ist die Verantwortungstrennung:

- Fetch-Policy liegt beim `Updater`
- Sync-Policy liegt beim `Publisher`

## `waitForServer`

```lua
CeHubModule.setOptions({
    waitForServer = false,
})
```

Wenn `waitForServer` gesetzt ist, wird `ce.databridge.ServerExchangeCoordinator.checkServerStatus` entsprechend umgeschaltet.

## Publisher-Policy

Mit `sync.publishers` wird ein ganzer Publisher ein- oder ausgeschaltet:

```lua
CeHubModule.setOptions({
    sync = {
        publishers = {
            signals = { enabled = false },
            weather = { enabled = false },
            trains = { enabled = true },
        },
    },
})
```

Unterstützte Publisher-Aliase im Hub sind:

- `modules`
- `version`
- `runtimes`
- `frameData`
- `slots`
- `signals`
- `switches`
- `structures`
- `time`
- `weather`
- `tracks`
- `trains`
- `rollingStocks`

Wenn ein Publisher deaktiviert ist:

- sein `syncState()` veröffentlicht nichts mehr
- Discovery und Updater können trotzdem weiterlaufen, sofern sie für andere aktive Publisher benötigt werden
- `tracks`, `trains` und `rollingStocks` sind unabhängige Publisher-Aliasse und beeinflussen sich nicht gegenseitig

## CeType-Sync-Policy

Mit `sync.ceTypes` wird pro CeType-Alias der Modus gesetzt:

```lua
CeHubModule.setOptions({
    sync = {
        ceTypes = {
            trains = { mode = "selected" },
            rollingStocks = { mode = "selected" },
            structures = { mode = "all" },
            weather = { mode = "none" },
        },
    },
})
```

Gültige Modi laut `SyncPolicy`:

- `all`
  alle bekannten Objekte dieses CeTypes werden synchronisiert
- `none`
  dieser CeType ist für die Synchronisation deaktiviert
- `selected`
  nur selektierte dynamische Objekte werden vollständig synchronisiert

Regel für `selected`:

- `selected` ist nur für dynamische CeTypes sinnvoll
- bei nicht-dynamischen CeTypes wird `selected` intern zu `all` normalisiert

Das ist die Aufgabe von [`SyncPolicy.lua`](c:/Spiele/GitHub/control-extension/lua/LUA/ce/hub/sync/SyncPolicy.lua).

Typische CeType-Aliase sind:

- `modules`
- `runtimes`
- `frameData`
- `eepVersion`
- `weather`
- `saveSlots`
- `freeSlots`
- `signals`
- `waitingOnSignals`
- `switches`
- `structures`
- `time`
- `trains`
- `rollingStocks`
- `auxiliaryTracks`
- `controlTracks`
- `roadTracks`
- `railTracks`
- `tramTracks`

Wichtig:

- Die Aliase müssen zu den `ceTypes`-Einträgen der jeweiligen `*StatePublisher.options` passen.
- `CeHubModule` schreibt die normalisierten Modi zusätzlich in den `ServerEventDispatcher`, damit Server und Lua dieselbe CeType-Sicht haben.

## Field-Fetch-Policy

Mit `sync.fields` wird auf Feldebene gesteuert, ob ein Feld überhaupt gesammelt wird:

```lua
CeHubModule.setOptions({
    sync = {
        fields = {
            trains = {
                speed = { collect = true },
                targetSpeed = { collect = false },
            },
            rollingStocks = {
                surfaceTexts = { collect = false },
                rotX = { collect = false },
                rotY = { collect = false },
                rotZ = { collect = false },
            },
            structures = {
                smoke = { collect = false },
            },
        },
    },
})
```

Regel laut `SyncPolicy.shouldCollect(fieldOptions)`:

- `collect = false` bedeutet:
  dieses Feld wird vom `Updater` nicht gelesen
  und von der `DtoFactory` nicht in DTOs aufgenommen
- jedes andere Verhalten gilt als `collect = true`

Das ist die eigentliche Fetch-Policy des Hubs.

## Zusammenspiel von Fetch und Sync

Die drei Ebenen greifen nacheinander:

1. `sync.fields`
   bestimmt, ob ein Feld überhaupt gelesen werden darf
2. `sync.ceTypes`
   bestimmt, ob ein CeType grundsätzlich aktiv ist und ob dynamische Daten nur selektiv exportiert werden
3. `sync.publishers`
   bestimmt, ob ein kompletter Publisher überhaupt noch sendet

Beispiel:

```lua
CeHubModule.setOptions({
    sync = {
        publishers = {
            trains = { enabled = true },
        },
        ceTypes = {
            trains = { mode = "selected" },
        },
        fields = {
            trains = {
                speed = { collect = true },
                targetSpeed = { collect = false },
            },
        },
    },
})
```

Wirkung:

- Zugdaten bleiben aktiv
- vollständige dynamische Zugdaten werden nur für selektierte Züge gesendet
- `speed` darf gelesen und veröffentlicht werden
- `targetSpeed` wird weder gelesen noch in DTOs aufgenommen

## Typische Konfigurationen

### Nur statischere Hub-Daten veröffentlichen

```lua
CeHubModule.setOptions({
    sync = {
        ceTypes = {
            trains = { mode = "none" },
            rollingStocks = { mode = "none" },
            auxiliaryTracks = { mode = "none" },
            controlTracks = { mode = "none" },
            roadTracks = { mode = "none" },
            railTracks = { mode = "none" },
            tramTracks = { mode = "none" },
        },
    },
})
```

### Züge und RollingStock nur selektiv, aber Strukturen vollständig

```lua
CeHubModule.setOptions({
    sync = {
        ceTypes = {
            trains = { mode = "selected" },
            rollingStocks = { mode = "selected" },
            structures = { mode = "all" },
        },
    },
})
```

### Teure RollingStock-Felder abschalten

```lua
CeHubModule.setOptions({
    sync = {
        fields = {
            rollingStocks = {
                surfaceTexts = { collect = false },
                rotX = { collect = false },
                rotY = { collect = false },
                rotZ = { collect = false },
            },
        },
    },
})
```

### Ganze Publisher abschalten

```lua
CeHubModule.setOptions({
    sync = {
        publishers = {
            weather = { enabled = false },
            signals = { enabled = false },
        },
    },
})
```

## Legacy-Optionen

Die alten Optionen werden nicht mehr unterstützt:

- `publisherOptions`
- `collectedCeTypes`
- `serverCeTypes`

Wenn sie noch verwendet werden, wirft `CeHubModule.setOptions(...)` bewusst einen Fehler.

## Weiterführende Dokumentation

- [README.md](README.md) - Überblick über den Hub
- [README_DEV.md](README_DEV.md) - Hub-Laufzeitfluss und Rollen
- [data/README_DEV.md](data/README_DEV.md) - Datenklassen und DTO-Fluss
- [SyncPolicy.lua](c:/Spiele/GitHub/control-extension/lua/LUA/ce/hub/sync/SyncPolicy.lua) - Normalisierung und Bewertung der Fetch-/Sync-Policy
