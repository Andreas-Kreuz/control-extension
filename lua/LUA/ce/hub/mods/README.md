---
layout: page_with_toc
title: Hub-Module
subtitle: Definition des CeModule-Typs und die eingebauten Hub-Module
permalink: lua/LUA/ce/hub/mods/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Was ist `ce.hub.mods`?

Dieses Paket enthält die Schnittstellendefinition `CeModule.d.lua`.
Das eingebaute Hub-Modul liegt jetzt als `ce.hub.CeHubModule` eine Ebene höher und kann direkt über `ControlExtension.addModules(...)` eingebunden werden.

## Verwendung

Die Hub-Module werden über `ControlExtension.addModules(...)` eingebunden:

```lua
local ControlExtension = require("ce.ControlExtension")

ControlExtension.addModules(
    require("ce.hub.CeHubModule")
)

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
```

## Was ist ein CeModule?

Ein `CeModule` ist ein Lua-Modul (eine Tabelle), das eine festgelegte Schnittstelle mit Pflichtfeldern und Pflichtmethoden implementiert.
Der Hub ruft die Methoden automatisch in jedem EEP-Zyklus auf.

Wie ein CeModule aufgebaut sein muss und wie Du ein eigenes schreibst, findest Du in [README_DEV.md](README_DEV.md).

---

Architekturbeschreibung: [README_DEV.md](README_DEV.md)
