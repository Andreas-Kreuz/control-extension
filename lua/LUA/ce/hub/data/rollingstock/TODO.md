# TODO RollingStock-Tags, Transit-Metadaten und Tag-Ownership

## Warum wir das umbauen

- Der Hub soll generisch bleiben und keine Transit-Fachlogik in `Train` oder `RollingStock` tragen.
- RollingStock-Tags sind ein knapper globaler Speicher. Darum brauchen CE-Module eine zentrale Key-Registry im Hub, um Kollisionen zu vermeiden.
- Die fachliche Deutung der Transit-Felder gehört trotzdem ins Transit-Modul.
- Das Überschreiben von Nutzer-Tags ist riskant und darf nur nach expliziter Zustimmung über `ControlExtension.allowTagOverwrite()` passieren.
- Ohne diese Trennung koppeln wir Hub, Transit-Persistenz, Zuganzeige und DTO-Verträge unnötig eng.

## Zielbild

- Der Hub behält die zentrale `TagKeys`-Registry und generische Tag-I/O.
- Hub-`Train` und Hub-`RollingStock` enthalten keine Transit-Felder und keine Transit-Persistenz.
- Transit besitzt `TransitTrain` und die fachliche Zuordnung von `line`, `destination`, `direction`, `wagonNumber`.
- Tag-Persistenz ist standardmäßig aus und wird global in `ControlExtension` freigegeben.
- Generische Train-/RollingStock-DTOs bleiben transitfrei; Transit liefert eigene DTOs und Räume.

## Arbeitspakete

### Hub

- `TagKeys.lua` als zentrale Registry belassen und mit Owner-/Bedeutungs-Kommentaren strukturieren.
- Generische Tag-I/O in Utility/Helfer belassen.
- Transit-Felder und Persistenz aus `Train.lua` und `RollingStock.lua` entfernen.
- DTOs sowie `.d.lua`-/`.d.md`-Typen anpassen.

### Transit

- `TransitTrain` und `TransitTrainRegistry` einführen.
- Ein Transit-RollingStock-Metadatenmodul einführen.
- CE-Tag-Metadaten nur bei gesetzter globaler Freigabe lesen und schreiben.
- Transit-DTOs für Zug- und RollingStock-Metadaten ergänzen.

### Öffentliche API

- `ControlExtension.allowTagOverwrite()` ergänzen.
- README-Beispiele für Anwender vereinfachen.

### Consumer

- Shared-, Server- und App-Verträge auf ein Transit-Overlay umstellen.

## Tests

- Ohne Freigabe gibt es keine CE-Tag-Lese- oder Schreibpfade.
- Mit Freigabe werden die Transit-Metadaten korrekt persistiert.
- Der Hub bleibt transitfrei.
- Die App bekommt Transitdaten nur über Transit-Räume.

## Offene Folgeschritte

- Spätere feinere Policies pro Objekttyp.
- Mögliche Drittmodul-Konventionen für weitere reservierte Tag-Keys.
