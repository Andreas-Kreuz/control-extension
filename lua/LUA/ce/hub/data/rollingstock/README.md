# RollingStock

`RollingStock` beschreibt einzelne Fahrzeuge innerhalb eines Zugverbandes.

## Rollen

- `RollingStock`
  Domain-Objekt mit Getter/Setter und Dirty-Tracking
- `RollingStockRegistry`
  hält alle bekannten Fahrzeuge nach ID
- `RollingStockModel`
  modellbezogene Verhaltens-Hooks wie Türen, Linie und Ziel
- `RollingStockModelInfo`
  gemeinsame, aus Ressourcen gelesene Modell-Metadaten wie Achsnamen und TextureText-Namen
- `RollingStockModelInfoRegistry`
  cached `RollingStockModelInfo` nach XML-/3dm-Modellpfad
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

## Fahrzeugnummer und Kennzeichen

Fahrzeugnummern und Kennzeichen werden am einzelnen `RollingStock` gespeichert und über `ce.hub.RollingStock`
veröffentlicht:

- `vehicleNumber` nutzt weiterhin den kompakten Tag-Schlüssel `w`. Dieser Schlüssel war bereits als
  `wagonNumber` im Bestand vorhanden; ein Wechsel würde gespeicherte Anlagenwerte unnötig entwerten.
- `licencePlate` nutzt den neuen Tag-Schlüssel `p`. Der Schlüssel ist noch frei, kurz genug für den
  begrenzten EEP-Tag-Text und fachlich als "plate" gut lesbar.
- `nr`, `setWagonNr()` und `getWagonNr()` bleiben als Kompatibilitätsalias für `vehicleNumber` erhalten,
  damit vorhandene Skripte und ältere Web-Daten weiter funktionieren.

Zugweite Anzeigen im Web sind abgeleitete Zusammenfassungen aus den RollingStock-Werten. Sie werden nicht als
eigene Felder am Zug persistiert, weil Kennzeichen und Fahrzeugnummer je nach Bus, Anhänger oder gekuppelter Tram
pro RollingStock oder pro Fahrzeuggruppe vergeben werden können.
