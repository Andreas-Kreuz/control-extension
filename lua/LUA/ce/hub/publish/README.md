---
layout: page_with_toc
title: DataChangeBus
subtitle: Ereignisverteilung für Datenänderungen in der Control Extension
permalink: lua/ce/hub/publish/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Was ist `ce.hub.publish`?

Der `DataChangeBus` leitet alle Datenänderungen als Events weiter.
Du kannst Dich als Anwender am Bus anmelden und auf Events reagieren.
Die verfügbaren Event-Typen sind in `EventTypes.d.lua` beschrieben.

## Unterstützte Event-Typen

- `CompleteReset` — vollständiger Neuaufbau aller Daten
- `DataAdded` — ein neues Element wurde hinzugefügt
- `DataChanged` — ein vorhandenes Element hat sich geändert
- `DataRemoved` — ein Element wurde entfernt
- `ListChanged` — eine komplette Liste hat sich geändert

## Listener registrieren

Ein Listener muss eine Methode `fireEvent(event)` besitzen:

```lua
local DataChangeBus = require("ce.hub.publish.DataChangeBus")

local myListener = {}
function myListener.fireEvent(event)
    if event.type == DataChangeBus.EventTypes.DataChanged then
        -- auf Änderung reagieren
    end
end

DataChangeBus.addListener(myListener)
```

## Event-Struktur

Jedes Event enthält:

- `eventCounter` — fortlaufende Nummer
- `type` — Event-Typ (siehe oben)
- `payload` — fachliche Nutzdaten mit `ceType`, `keyId` und `element` oder `list`

---

Architekturbeschreibung: [README_DEV.md](README_DEV.md)
