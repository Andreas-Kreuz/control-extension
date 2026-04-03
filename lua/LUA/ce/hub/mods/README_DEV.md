---
layout: page_with_toc
title: CeModule — Entwickler
subtitle: Was ein CeModule ist, wie es sich verhält und wie man eines entwickelt
permalink: lua/ce/hub/mods/dev/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Architektur von CeModule

## Was ist ein CeModule?

Ein `CeModule` ist ein Lua-Modul (eine Tabelle), das eine festgelegte Schnittstelle implementiert.
Der Hub ruft die Methoden des Moduls automatisch in jedem EEP-Zyklus auf.

Du bindest Module über `ControlExtension.addModules(...)` ein — der Hub übernimmt dann Initialisierung und zyklischen Aufruf.

## Pflichtfelder

| Feld      | Typ       | Beschreibung                                                         |
| --------- | --------- | -------------------------------------------------------------------- |
| `id`      | `string`  | Eindeutige UUID des Moduls — darf sich nie ändern                    |
| `name`    | `string`  | Lua-require-Name des Moduls, z.B. `"ce.mods.road.CeRoadModule"`      |
| `enabled` | `boolean` | Kann gesetzt werden, um das Modul zu aktivieren oder zu deaktivieren |

## Pflichtmethoden

| Methode  | Rückgabe | Beschreibung                                              |
| -------- | -------- | --------------------------------------------------------- |
| `init()` | —        | Wird einmalig beim ersten Lauf von `EEPMain()` aufgerufen |
| `run()`  | —        | Wird bei jedem Lauf von `EEPMain()` aufgerufen            |

## Lebenszyklus

Der Hub ruft jedes registrierte Modul in zwei Phasen auf:

1. **Initialisierung** — `init()` wird einmalig beim ersten Durchlauf von `EEPMain()` aufgerufen. Hier richtest Du z.B. interne Zustände oder Registries ein.
2. **Zyklus** — `run()` wird danach bei jedem weiteren Durchlauf von `EEPMain()` aufgerufen. Hier liest Du Zustände aus EEP und reagierst darauf.

Die Reihenfolge der Aufrufe entspricht der Reihenfolge, in der die Module bei `addModules(...)` übergeben wurden.

## Minimales Beispiel

```lua
-- ce/mods/mymod/MyCeModule.lua
local MyCeModule = {
    id = "a1b2c3d4-0000-0000-0000-000000000001",
    name = "ce.mods.mymod.MyCeModule",
    enabled = true,
}

function MyCeModule.init()
    print("MyCeModule initialisiert")
end

function MyCeModule.run()
    -- Wird bei jedem EEP-Zyklus aufgerufen
end

return MyCeModule
```

Einbinden in EEP:

```lua
local ControlExtension = require("ce.ControlExtension")
ControlExtension.addModules(require("ce.mods.mymod.MyCeModule"))

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
```

## Optionale Methoden

Du kannst weitere Methoden hinzufügen, z.B. für Konfiguration:

```lua
function MyCeModule.setOptions(options)
    -- Konfigurationsoptionen verarbeiten
end
```

`setOptions` wird nicht automatisch vom Hub aufgerufen — Du rufst es selbst auf, bevor `ControlExtension.runTasks()` startet:

```lua
ControlExtension.addModules(require("ce.mods.mymod.MyCeModule").setOptions({ debug = true }))
```

## Daten auf den Datenbus schreiben

Wenn Dein Modul Daten für die Data Bridge oder die Web App bereitstellen soll, schreibst Du diese über den eingebauten Datenbus.

Das geht zu jedem beliebigen Zeitpunkt — am naheliegendsten in `run()`, aber auch in `init()` oder bei externen Ereignissen.

Die Konvention der eingebauten Module:

1. Ein `*StatePublisher` sammelt mit einem `*DataCollector` die aktuellen Zustände.
2. Eine `*DtoFactory` wandelt die Zustände in Datentransferobjekte (DTOs) um.
3. Die DTOs werden nach `ceType` einsortiert: `ceType:string` → `dtoId:string|number` → `dto:table`.
4. Änderungen werden über `DataChangeBus.fire*()` veröffentlicht.

`StatePublisher` sind dabei keine einfachen Datenklassen, sondern zustandsbehaftete Adapter mit eigenem Lebenszyklus: registrieren, einmalig initialisieren, zyklisch synchronisieren. Mehr dazu in [hub/README_DEV.md](../README_DEV.md).

CeTypes und DTO-Strukturen aller eingebauten Module sind in [hub/data/DTO.md](../data/DTO.md) dokumentiert.

## Vorlagen

Fertige Vorlagen findest Du in [`ce.template`](../../template/README.md).
Bestehende Module wie `ce.mods.road.CeRoadModule` können als Referenz dienen — siehe [`ce.mods`](../../mods/README.md).

## Weiterführende Dokumentation

- [Öffentliche API von ce.ControlExtension](../README.md)
- [Datenmodell und DTO-CeTypes](../data/DTO.md)
- [StatePublisher-Muster und Laufzeitfluss](../README_DEV.md)
- [Zielarchitektur](../docs/Architecture.md)

---

Informationen für Anwender: [README.md](README.md)
