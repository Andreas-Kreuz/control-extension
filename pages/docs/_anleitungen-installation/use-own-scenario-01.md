---
layout: page_with_toc
title: Control Extension in eigene Anlagen einbinden
subtitle: Starte den Server, ergänze den minimalen Lua-Einstieg und verwende die Control Extension in Deiner eigenen Anlage.
type: Anleitung
img: '/assets/thumbnails/GitHub.png'
date: 2026-04-11
permalink: docs/anleitungen-installation/use-own-scenario-01
tags: [Installation]
published: true
---

# Control Extension in eigene Anlagen einbinden

## Voraussetzung

Führe zuerst die Anleitung [Download und Installation](../anleitungen-installation/installation-01) aus.

## 1. Server starten

1. Starte `control-extension-server.exe` aus dem Installationsverzeichnis `LUA\ce`.

   Beispiel: `C:\Trend\EEP16\LUA\ce\control-extension-server.exe`

2. Prüfe im Server-Fenster, ob das richtige EEP-Verzeichnis ausgewählt ist.

3. Lasse den Server geöffnet, während Du EEP und Deine Anlage startest.

## 2. Eigene Anlage öffnen

1. Starte EEP.

2. Öffne Deine eigene Anlage.

3. Öffne den Lua-Code der Anlage, in den Du die Control Extension aufnehmen möchtest.

## 3. Control Extension minimal einbinden

Öffne den Lua-Editor in EEP. Die minimale Einbindung in die Anlage sieht so aus:

```lua
local ControlExtension = require("ce.ControlExtension")

function EEPMain()
    -- Dein bisheriger Code in EEPMain
    ControlExtension.runTasks(1)
    return 1
end
```

Wenn Deine Anlage bereits eine `EEPMain()` besitzt, ergänzt Du dort nur

- Außerhalb von `EEPMain()` den Aufruf:\
  `local ControlExtension = require("ce.ControlExtension")`
- Innerhalb von `EEPMain()` den Aufruf:\
  `ControlExtension.runTasks(1)`.

## 4. In den 3D-Modus schalten

1. Wechsle in EEP in den 3D-Modus.

2. Erst dann werden die Daten in `LUA\ce\databridge\exchange` geschrieben und vom Server verarbeitet.

3. Jetzt kannst Du Dich von einem zweiten Rechner oder Mobiltelefon mit der Web App verbinden.

:bulb: **Tipp:** So lange die 3D Simulation läuft, werden die Daten von EEP an den Server gesendet.
Die Datenaktualisierung wird pausiert, sobald 3D Simulation von EEP gestoppt wird.

:bulb: **Tipp:** Wenn du denselben Rechner für EEP und die App nutzt, dann lege dir Browser-Fenster mit der App neben EEP, wenn du App Aktualisierungen beobachten möchtest.

## Weiterführend

- [Demo-Anlage nutzen](../anleitungen-installation/use-demo)
- [Lua-Dokumentation](../lua/LUA/ce/)
