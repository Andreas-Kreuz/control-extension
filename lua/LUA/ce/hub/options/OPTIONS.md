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
                speed = "onselection",
                targetSpeed = "never",
            },
            fieldPublish = {
                speed = "always",
                targetSpeed = "onselection",
            },
        },
    },
})
```

## Prinzip

Die Default-Optionen liegen zentral in `HubOptionDefaults.lua`.

`CeHubModule.setOptions(...)` merged Benutzeroptionen mit diesen Defaults und schreibt die wirksamen Optionen in `HubOptionsRegistry.lua`. Discovery, Updater, Publisher und DtoFactory lesen ihre wirksamen Optionen dann direkt aus dieser Registry.

## Feld-Policies

- `always`
- `onselection`
- `never`

## Legacy

Nicht mehr unterstuetzt:

- `options.sync.publishers`
- `options.sync.ceTypes`
- `options.sync.fields`
- `publisherOptions`
- `collectedCeTypes`
- `serverCeTypes`
