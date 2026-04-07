# RollingStock

`RollingStock` beschreibt einzelne Fahrzeuge innerhalb eines Zugverbandes.

## Rollen

- `RollingStock`
  Domain-Objekt mit Getter/Setter und Dirty-Tracking
- `RollingStockRegistry`
  hält alle bekannten Fahrzeuge nach ID
- `RollingStockUpdater`
  liest Fahrzeugzustand aus EEP und schreibt Änderungen in die Domain-Objekte
- `RollingStockPublisher`
  veröffentlicht Änderungen für `ce.hub.RollingStock`
- `RollingStockDtoFactory`
  serialisiert Domain-Objekte in vollständige DTOs oder Patch-DTOs

## Herkunft der Einträge

RollingStock wird nicht separat entdeckt.
Die Existenz bekannter Fahrzeuge wird aus `TrainDiscovery` und der aktuellen Zugzusammenstellung abgeleitet.

## DTO

Das aktive DTO bündelt heute statische und dynamische Felder in einem CeType:

- `ce.hub.RollingStock`

Dazu gehören auch Felder, die früher separat transportiert wurden, zum Beispiel:

- `surfaceTexts`
- `rotX`
- `rotY`
- `rotZ`

Die vollständige Feldliste ist in [../DTO.md](../DTO.md) beschrieben.

Hinweis: Offene Fachthemen rund um Tags und Schlüssel-Ownership bleiben in [TODO.md](TODO.md) dokumentiert.
