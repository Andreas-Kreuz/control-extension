---
layout: page_with_toc
title: Hub-Daten - Entwickler
subtitle: Architektur, DTO-Fluss und Verantwortlichkeiten im ce.hub.data-Paket
permalink: lua/LUA/ce/hub/data/dev/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Hub-Daten - Entwickler

## Ziel der Struktur

Die Datenstruktur in `ce.hub.data` trennt fachlichen Zustand, EEP-Zugriff und Veröffentlichung bewusst voneinander.

Für dynamische CeTypes ist die gewünschte Rollenverteilung:

- `Domain`: Zustand, Getter/Setter, Dirty-Tracking
- `Registry`: zentrale Map der bekannten Objekte nach ID
- `Discovery`: erkennt neue und entfernte Objekte
- `Updater`: entscheidet, welche Felder aktualisiert werden, und ruft `pullX()` auf Domain-Objekten
- `Publisher`: sendet Add/Change/Remove-Events und wertet Sync-Optionen aus
- `DtoFactory`: baut serialisierbare DTOs

Einfachere Singleton-CeTypes wie Zeit, Wetter oder Version nutzen meist nur den kleineren Ausschnitt `Registry + Updater + Publisher`, folgen aber denselben Zuständigkeitsgrenzen:

- Der `Updater` trifft die Einscheidungen, dass Daten geladen werden sollen; EEP-Lesezugriffe erfolgen mit den `pullX()`-Methoden der Datenklassen
- Sync-Logik liegt im `Publisher`

## Daten-Fassaden und EEP-Zugriff

Die aktiven Datenklassen in `ce.hub.data` sind Fassaden vor dem EEP-Zustand. Sie halten die zuletzt bekannten Werte im Lua-Objekt, reduzieren direkte `EEP*Get*`- und `EEP*Set*`-Aufrufe und markieren geänderte Felder für die Veröffentlichung.

Die Grundregeln sind:

- `*Discovery` findet neue oder entfernte Objekte. `initFromAnl3(tableOfAnl3)` liest bereits geparste Anlagendaten aus der einmal geladenen `.anl3`-Struktur und befüllt Objekte nur über `seed*`-Methoden. Ist eine Domain in der `.anl3`-Erkennung enthalten, werden nur die dort gefundenen Objekte behalten. Ohne `.anl3`-Erkennung nutzt die Discovery die bisherigen Suchmechanismen und günstige Existenzprüfungen wie `Signal.exists(id)`, `Switch.exists(id)`, `Structure.exists(name)`, `Train.exists(name)` oder `RollingStock.exists(name)`.
- `*Updater` entscheiden nur, welche Werte gerade aktualisiert werden sollen. Sie rufen `pullX()` auf den Datenobjekten auf und enthalten auf dem aktiven Pfad keine direkten `EEP*Get*`-Aufrufe.
- Jede Objekt-Domain besitzt eine Registry mit Lookup über die Pflicht-ID. Train und RollingStock teilen sich intern den gekoppelten `TrainRollingStockStore`; die Kompatibilitätsmodule `TrainRegistry` und `RollingStockRegistry` bleiben trotzdem die öffentlichen Einstiege.
- `*DtoFactory` und `*Publisher` halten die bestehenden DTO-Verträge stabil. Sie lesen Werte cache-only über `peekX()` oder äquivalente cache-only Hilfsfunktionen und lösen keine EEP-Lesezugriffe aus.
- Direkte `EEP*Set*`-Aufrufe gehören in die passende `setX(...)`-Methode der Datenklasse. Direkte `EEP*Get*`-Aufrufe gehören in die passende `pullX(...)`-Methode der Datenklasse. Ausnahme sind Discovery-Existenzprüfungen und wenige globale Singleton-Fassaden wie Scenario, FrameData, Weather oder Time.
- Alte Collector-Module sollen nicht mehr erweitert oder neu verwendet werden. Wenn sie nur noch von Tests referenziert werden, sind sie Altlasten und können entfernt oder in die Fassade überführt werden.

Für Felder einer Datenklasse gilt dieses Namensschema:

```lua
peekX()          -- Schaut nur im Cache nach und ruft keine EEP-Funktion auf
getX()           -- read-through: nutzt Cache, ruft pullX() nur bei fehlendem Wert
replaceX(...)    -- überschreibt Cache, kein EEPSet-Aufruf, dirty nur bei Änderung
seedX(...)       -- Discovery-Seed, kein EEPSet, dirty nur bei Änderung
pullX()          -- EEPGet -> replaceX -> dirty nur bei Änderung -> Rückgabewerte ohne ok-Flag
setX(...)        -- idempotentes EEPSet -> replaceX nur bei akzeptiertem Set
```

Die Rückgabeform orientiert sich an der EEP-API ohne Erfolgsindikator. Beispiel: `EEPStructureGetPosition(name)` liefert `ok, x, y, z`; `Structure:getPosition()` und `Structure:pullPosition()` liefern bei Erfolg `x, y, z` und bei Fehlschlag `nil, nil, nil`.

`setX()` und `seedX()` müssen idempotent bleiben: gleiche Werte verursachen keinen EEP-Aufruf und markieren kein Feld erneut als dirty.

## DTO-Konvention: CeTypes und Listen

Alle Daten werden in eine dreistufige Map-Struktur einsortiert:

```text
ceType : string
  └─ dtoId : string | number
       └─ dto : table
```

- `ceType` ist die stabile Typkennung des Datenbereichs, z. B. `"ce.hub.Train"` oder `"ce.hub.Signal"`.
- `dtoId` ist ein eindeutiger Schlüssel innerhalb des CeTypes, z. B. der Zugname oder die Signal-ID.
- `dto` ist eine flache serialisierbare Tabelle ohne Funktionen.

## Ablauf: Wie kommt ein DTO auf den Bus?

1. `CeHubModule.init()` startet Initial-Discovery und Initial-Updates.
2. `CeHubModule.run()` führt die laufende Discovery und die laufenden Updates aus.
3. Ein `*Publisher` bewertet die Sync-Optionen des CeTypes.
4. Eine `*DtoFactory` serialisiert Domain-Objekte oder Patches in DTOs.
5. Der Publisher veröffentlicht Änderungen über `DataChangeBus.fire*()`.

Die historischen `*StatePublisher.lua`-Dateien sind auf dem aktiven Pfad nur noch dünne Adapter, die `Publisher.syncState(...)` mit den zugehörigen Optionen aufrufen.

## Optionen und Verantwortlichkeiten

Die Sync- und Fetch-Optionen werden auf drei Ebenen angewendet:

- Feld-Ebene: `collect = false`
  Der `Updater` liest dieses Feld nicht und die `DtoFactory` nimmt es nicht in DTOs auf.
- CeType-Ebene: `mode = all | none | selected`
  Das `CeHubModule` und die `Publisher` entscheiden damit, ob ein CeType vollständig, gar nicht oder nur für selektierte Objekte synchronisiert wird.
- Publisher-Ebene: `enabled = true | false`
  Der jeweilige `Publisher` kann komplett deaktiviert werden.

## Discovery und gekoppelte CeTypes

Nicht jeder CeType scannt die Welt unabhängig. Ein wichtiges Beispiel ist der Zugpfad:

- `TrainDiscovery` erkennt Tracks, Züge und RollingStock-Existenz gemeinsam.
- `TrainUpdater` aktualisiert die bekannten Zugobjekte.
- `RollingStockUpdater` aktualisiert die bekannten RollingStock-Objekte.
- `TrackPublisher`, `TrainPublisher` und `RollingStockPublisher` veröffentlichen anschließend ihre Änderungen getrennt.

Damit bleibt die Discovery-Logik zentral, während Registry, Updater und Publisher weiter je CeType getrennt bleiben.

## Vollständige DTO-Strukturen

Alle aktiven CeTypes und ihre DTO-Felder sind in [DTO.md](DTO.md) dokumentiert.

---

Informationen für Anwender: [README.md](README.md)
