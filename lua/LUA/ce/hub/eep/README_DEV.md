---
layout: page_with_toc
title: EEP-Paket — Entwickler
subtitle: Interner Aufbau des EepSimulators und Design-Entscheidungen
permalink: lua/ce/hub/eep/dev/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# EEP-Paket — Entwickler

## EepSimulator

`EepSimulator.lua` bildet die EEP-API nach, damit Lua-Skripte ohne laufendes EEP getestet werden können.

Die Funktionen gliedern sich in drei Typen:

### `EEP...` — EEP-API nachbilden

Diese Funktionen bilden die originale EEP-API nach, wie sie in [`EepOriginalApi.d.lua`](./EepOriginalApi.d.lua) beschrieben ist.

- Testcode ruft dieselben globalen `EEP...`-Funktionen auf wie in EEP.
- Die Implementierung liefert im Simulator konsistenten, testbaren Zustand.

### `emit...` — EEP-Callbacks auslösen

Diese Methoden lösen EEP-Callbacks gezielt im Simulator aus.

- Testcode kann Callback-Situationen nachstellen, die in echtem EEP vom Programm ausgelöst werden.
- Die Methoden rufen die zugehörigen globalen Callback-Funktionen aus `_G` auf, z.B. `EEPMain()`, `EEPOnTrainStoppedOnSignal(...)`.

Beispiele:

- `EepSimulator.emitMain()` → ruft `EEPMain()` auf
- `EepSimulator.emitOnSignal(signalId, stellung)` → ruft `EEPOnSignal_<signalId>(stellung)` auf
- `EepSimulator.emitOnSwitch(switchId, stellung)` → ruft `EEPOnSwitch_<switchId>(stellung)` auf

### `simulate...` — Anwender-Aktionen simulieren

Diese Methoden simulieren Aktionen, die normalerweise durch den Anwender oder die EEP-Oberfläche ausgelöst werden.

- Sie helfen dabei, Anlagen- und Testzustand gezielt vorzubereiten, z.B. Züge anlegen oder auf Gleise setzen.
- In `EepSimulator.lua` delegieren diese Methoden an `Runtime.simulate...`.

Beispiele:

- `EepSimulator.simulateAddTrain(...)`
- `EepSimulator.simulatePlaceTrainOnRailTrack(trackId, trainName)`
- `EepSimulator.simulateQueueTrainOnSignal(signalId, trainName)`

## EepOriginalApi.md

`EepOriginalApi.md` ist ein Hinweis für KI-Agenten, wie die EEP-API neu erstellt werden kann, falls `EepOriginalApi.d.lua` verloren geht oder aktualisiert werden muss. Sie bleibt als eigene Datei erhalten.

---

Informationen für Anwender: [README.md](README.md)
