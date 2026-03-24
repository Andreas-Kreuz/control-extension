---
layout: page_with_toc
title: Scheduler — Entwickler
subtitle: Interner Aufbau und Design-Entscheidungen des Schedulers
permalink: lua/ce/hub/scheduler/dev/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Scheduler — Entwickler

## Zweck

Der Scheduler erlaubt das Ausführen von Funktionen zu bestimmten EEP-Zeiten.

**Wichtig:** Geplante Funktionen werden nur zur Laufzeit persistiert und gehen beim Lua-Neustart verloren.
Plane deshalb keine Aktionen ein, die über einen Neustart hinaus gültig sein müssen.

## Bausteine

### Klasse `Task`

Kapselt eine Funktion und einen Namen.

- `Task:new(f, name)` — erstellt eine neue Aktion
- `f` ist die Lua-Funktion, die aufgerufen wird
- `name` ist ein Text für die Debug-Ausgabe

### Klasse `Scheduler`

Nimmt Aktionen entgegen und führt sie nach Ablauf einer Zeitspanne aus.

- `Scheduler:scheduleTask(offsetInSeconds, newTask, precedingTask)` — plant eine Aktion ein
- `Scheduler:runTasks()` — prüft die Zeit und führt fällige Aktionen aus; wird automatisch über `SchedulerCeModule` aufgerufen

## Design-Entscheidung

Der Scheduler ist ein Sub-Bereich des Hubs und kein eigenständiges Paket, weil er eng an den Hub-Lebenszyklus (`runTasks`) gekoppelt ist und keine eigene Laufzeit benötigt. Die Zeitbasis stammt direkt aus EEP.

---

Informationen für Anwender: [README.md](README.md)
