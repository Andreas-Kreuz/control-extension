---
layout: page_landing
title: Control Extension
subtitle: Hier findest du Informationen zur Control Extension
permalink: lua/LUA/ce/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Was ist die Control Extension?

Die Control Extension erweitert Deine EEP-Anlage um einen strukturierten Laufzeitkern für Lua-Module.
Du kannst Deine Anlagenlogik in wiederverwendbare Module aufteilen und bei Bedarf Daten und Steuerfunktionen über zusätzliche Werkzeuge nach außen bereitstellen.

Das Paket besteht aus vier Bausteinen:

1. **Lua Hub** in `ce.hub` — der Laufzeitkern. Er lädt und führt alle registrierten Module aus.
2. **Data Bridge** _(optional)_ in `ce.databridge` — überträgt Daten aus EEP an externe Werkzeuge.
3. **Control Extension Server** _(optional)_ — bereitet die Daten auf und stellt sie für Clients bereit.
4. **Control Extension Web App** _(optional)_ — zeigt Daten im Browser an und erlaubt die Bedienung.

Für die Anlagensteuerung genügt der Lua Hub. Server und Web App sind optional.

## Schnellstart

Damit ein EEP Anlage den Hub nutzt, wird der Einstiegspunkt `ce.ControlExtension` in den Lua Code der Anlage aufgenommen.

### Kurzes Beispiel

Nutze den Lua-Editor von EEP und klicke dann auf Skript neu laden. \
⚠️ **Wenn du schon eigenen Lua-Code hast, dann füge nur die beiden Zeilen mit `ControlExtension` hinzu.**

```lua
local ControlExtension = require("ce.ControlExtension")

function EEPMain()
   ControlExtension.runTasks(1)
   return 1
end
```

### Langes Beispiel

Die zusätzliche Konfiguration ist optional. Wenn du sie nicht verwendest, bleiben die Standardwerte aktiv.

```lua
local ControlExtension = require("ce.ControlExtension")

ControlExtension
    .setDebug(true)
    .activateServer()
    .setPauseEepDuringInitialization(true)
    .addModules(
        require("ce.mods.road.CeRoadModule"),
        require("ce.hub.CeHubModule").setOptions({
            collectedCeTypes = {
                require("ce.hub.CeHubModule").CeTypes.Train,
            },
        })
    )

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
```

### Control Server starten

Ist dein EEP in `C:\Trend\EEP18` installiert, dann findest du den Control Server in `C:\Trend\EEP18\LUA\ce\control-extension-server.exe`.

Eine vollständige Beschreibung der API findest Du in [hub/README.md](hub/README.md).

## Dokumentation

### Für Anwender

- [hub/README.md](hub/README.md) — Öffentliche API: `ControlExtension.addModules`, `runTasks`, `setDebug` u.a.
  - [hub/data/README.md](hub/data/README.md) — Daten aus EEP einsammeln und bereitstellen
  - [hub/eep/README.md](hub/eep/README.md) — EEP-Simulator für Tests; API-Beschreibung für IDEs
  - [hub/mods/README.md](hub/mods/README.md) — CeModule-Schnittstellendefinition und eingebaute Module
  - [hub/publish/README.md](hub/publish/README.md) — DataChangeBus: Events empfangen und auswerten
  - [hub/scheduler/README.md](hub/scheduler/README.md) — Aktionen nach Zeitablauf einplanen
  - [hub/util/README.md](hub/util/README.md) — Hilfsfunktionen für persistente Zustandsablage
- [databridge/README.md](databridge/README.md) — Dateibasierte Kommunikation mit dem Web-Server
- [mods/README.md](mods/README.md) — Verfügbare Erweiterungsmodule (Ampel, ÖPNV)
- [template/README.md](template/README.md) — Vorlagen für eigene Anlagen

### Für Entwickler

- [README_DEV.md](README_DEV.md) — Eigene CeModule entwickeln und integrieren
- [hub/README_DEV.md](hub/README_DEV.md) — Interne Hub-Architektur (ModuleRegistry, MainLoopRunner)
  - [hub/data/README_DEV.md](hub/data/README_DEV.md) — DTO-Konvention und Datenstruktur
  - [hub/eep/README_DEV.md](hub/eep/README_DEV.md) — EepSimulator-Implementierung
  - [hub/mods/README_DEV.md](hub/mods/README_DEV.md) — CeModule-Architektur: Felder, Lebenszyklus, Datenbus
  - [hub/publish/README_DEV.md](hub/publish/README_DEV.md) — DataChangeBus-Architektur und Invarianten
  - [hub/scheduler/README_DEV.md](hub/scheduler/README_DEV.md) — Scheduler/Task-Implementierung
  - [hub/util/README_DEV.md](hub/util/README_DEV.md) — StorageUtility-Implementierung
- [hub/data/DTO.md](hub/data/DTO.md) — Alle Datenräume und DTO-Typen im Überblick

### Weitere Pakete

- [rail/README.md](rail/README.md) — Zugsteuerung (in Arbeit)
- [modellpacker/README.md](modellpacker/README.md) — EEP-Installer erstellen
- [demo-anlagen/README.md](demo-anlagen/README.md) — Fertige Beispielanlagen
