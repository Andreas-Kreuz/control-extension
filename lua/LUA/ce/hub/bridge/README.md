---
layout: page_with_toc
title: Bridge-Anbindung
subtitle: Lua-seitige Anbindung der Control Extension an den Web-Server
permalink: lua/LUA/ce/hub/bridge/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Was ist `ce.hub.bridge`?

In diesem Verzeichnis liegt die Lua-Datei für die Anbindung des Hubs an die Bridge.
Das geschieht immer über einen `BridgeConnector`.

## Keine öffentliche API

Dieses Paket hat keine öffentliche API für Lua-Skripte.
Die Bridge wird indirekt über `ControlExtension` gesteuert:

- `ControlExtension.activateServer()` — schaltet die Server-Kommunikation ein
- `ControlExtension.deactivateServer()` — schaltet sie aus, ohne die übrigen Module zu stoppen

Direkter Zugriff auf Dateien unter `ce.hub.bridge` ist nicht vorgesehen.

---

Architekturbeschreibung: [README_DEV.md](README_DEV.md)
