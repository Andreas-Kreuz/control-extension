---
layout: page_with_toc
title: Simuliere den Simulator!
subtitle: Mit diesem Skript kannst Du Deine Skripte ohne EEP testen.<br>Binde diese Skripte in ein Testskript ein und prüfe Deine Schaltungen.
permalink: lua/ce/hub/eep/
feature-img: "/docs/assets/headers/SourceCode.png"
img: "/docs/assets/headers/SourceCode.png"
---

# Was ist `ce.hub.eep`?

Mit dem `EepSimulator` kannst Du Deine Lua-Skripte testen, ohne EEP laufen zu haben.
`EepOriginalApi.d.lua` beschreibt alle EEP-Funktionen so, dass IDEs sie als Code-Vervollständigung anbieten können.

## Verwendung

* Ein Testskript lädt zuerst die Funktionen von EEP:<br>
  `require 'ce.hub.eep.EepSimulator'`

* Danach wird das eigentliche Skript geladen:<br>
  `require 'anlagen-script'`

Ein ausführlicheres Tutorial zu dem Thema findest Du hier: **[Demo-Anlage-Testen](../../../../anleitungen-ampelkreuzung/demo-anlage-testen)**

## Beispiel

Prüfe, ob ein Signal gesetzt wurde:

```lua
require("ce.hub.eep.EepSimulator")

EEPSetSignal(32, 2)
assert (2 == EEPGetSignal(32))
```

---

Architekturbeschreibung: [README_DEV.md](README_DEV.md)
