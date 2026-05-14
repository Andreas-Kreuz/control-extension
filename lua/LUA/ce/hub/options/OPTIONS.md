---
layout: page_with_toc
title: Hub-Optionen
subtitle: CeType-zentrierte Discovery-, Update- und Publish-Optionen
permalink: lua/LUA/ce/hub/options/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Optionen fuer `CeHubModule`

Die Hub-Optionen werden ueber `CeHubModule.setOptions(...)` gesetzt.

```lua
local CeHubModule = require("ce.hub.CeHubModule")

CeHubModule.setOptions({
    waitForServer = true,
    ceTypes = {
        trains = {
            discoveryAndUpdate = true,
            publish = true,
            fieldUpdates = {
                speed = "oninterest",
                targetSpeed = "never",
            },
            fieldPublish = {
                speed = "always",
                targetSpeed = "oninterest",
            },
        },
    },
})
```

## Prinzip

Die Default-Optionen liegen zentral in `HubOptionDefaults.lua`.

`CeHubModule.setOptions(...)` merged Benutzeroptionen mit diesen Defaults und schreibt die wirksamen Optionen in `HubOptionsRegistry.lua`. Discovery, Updater, Publisher und DtoFactory lesen ihre wirksamen Optionen dann direkt aus dieser Registry.

## Feld-Policies

- `always` - Das Feld wird immer aktualisiert / veröffentlicht.
- `oninterest` - Das Feld wird nur aktualisiert / veröffentlicht, wenn der Dateneintrag ausgewählt ist.
- `never` - Das Feld wird nie aktualisiert / veröffentlicht.

## Relevante Defaults

Signalbezogene Wartedaten werden standardmäßig nur bei Interesse mit echten Werten veröffentlicht:

- `ceTypes.signals.fieldPublish.waitingVehiclesCount = "oninterest"`
- `ceTypes.waitingOnSignals.fieldPublish.waitingPosition = "oninterest"`
- `ceTypes.waitingOnSignals.fieldPublish.vehicleName = "oninterest"`
- `ceTypes.waitingOnSignals.fieldPublish.waitingCount = "oninterest"`

Nicht ausgewählte vollständige DTOs enthalten dafür Platzhalterwerte. Patch-DTOs für nicht ausgewählte
`ce.hub.WaitingOnSignal`-Einträge lassen diese Felder weg, wenn nur On-Interest-Felder geändert wurden.

## Legacy

Nicht mehr unterstuetzt:

- `options.sync.publishers`
- `options.sync.ceTypes`
- `options.sync.fields`
- `publisherOptions`
- `collectedCeTypes`
- `serverCeTypes`
