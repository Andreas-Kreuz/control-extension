# Züge und Discovery

Der Zugpfad ist der zentrale Discovery-Pfad für die bewegten Weltobjekte im Hub.

## Rollen

- `TrainDiscovery`
  Erkennt Tracks, Züge und RollingStock-Existenz.
  Pflegt neue und entfernte Einträge in `TrackRegistry`, `TrainRegistry` und `RollingStockRegistry`.
- `TrainUpdater`
  Aktualisiert bekannte Züge über Setter auf `Train`.
- `RollingStockUpdater`
  Aktualisiert bekannte RollingStock-Einträge über Setter auf `RollingStock`.
- `TrainPublisher`
  Sendet Änderungen für `ce.hub.Train`.
- `RollingStockPublisher`
  Sendet Änderungen für `ce.hub.RollingStock`.
- `TrackPublisher`
  Sendet Änderungen für die Track-CeTypes `ce.hub.AuxiliaryTrack`, `ce.hub.ControlTrack`, `ce.hub.RoadTrack`, `ce.hub.RailTrack` und `ce.hub.TramTrack`.

## Discovery-Regeln

Neue oder geänderte Züge werden insbesondere über die aktuelle Gleisbelegung und zugbezogene EEP-Ereignisse erkannt.

Wichtig ist dabei:

- `TrainDiscovery` entscheidet, welche Züge und RollingStock-Elemente bekannt sind.
- RollingStock wird nicht separat in der Welt gesucht, sondern aus der bekannten Zugzusammenstellung abgeleitet.
- Die Track-Discovery ist Teil desselben Discovery-Laufs, damit Gleisbelegung und Zugsnapshot zusammenpassen.

## Update-Regeln

Ein Zug erhält ein Vollupdate, wenn er neu erkannt oder neu zusammengestellt wurde.
Ein Teilupdate reicht aus, wenn sich nur laufend aktualisierte Felder geändert haben, etwa Geschwindigkeit oder Depotstatus.

RollingStock folgt demselben Muster:

- selten geänderte Felder wie Modelltyp oder Kupplungsdaten werden nur bei Bedarf neu gelesen
- häufig geänderte Felder wie Position, Ausrichtung oder Rauchzustand werden im normalen Updater-Lauf aktualisiert

## DTOs

Aktiv sind heute genau zwei CeTypes in diesem Pfad:

- `ce.hub.Train`
- `ce.hub.RollingStock`

Die Felder dieser DTOs sind in [../DTO.md](../DTO.md) dokumentiert.
