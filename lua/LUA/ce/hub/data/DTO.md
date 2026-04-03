---
layout: page_with_toc
title: Datenmodell
subtitle: Alle CeTypes und Datentypen der Control Extension im Überblick
permalink: lua/ce/hub/data/dto/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Datenmodell der `*StatePublisher.lua`

Diese Datei dokumentiert das aktuell erzeugte Datenmodell der Lua-Collector.

Grundlagen der Beschreibung:

- Primärquelle ist die aktuelle Implementierung in `*StatePublisher.lua` sowie in den indirekt genutzten Modellen wie `Train`, `RollingStock`, `Line` und `LineSegment`.
- Für Felder, die direkt aus EEP-Funktionen stammen, wurden Typ, Wertebereich und Beschreibung soweit möglich aus `Lua_manual.pdf` abgeleitet.
- Wo das Datenmodell nicht direkt aus EEP stammt, sondern aus Bibliothekslogik, ist das in der Beschreibung vermerkt.

Wichtig:

- Die meisten Collector senden Nutzdaten per `EventBroker.fireListChange(...)`; `syncState()` gibt oft `{}` zurück.
- Die Tabellen unten beschreiben das effektive Modell der Events und, wo relevant, die aktuelle Rückgabeform von `syncState()`.
- Bestehende Schreibweisen im Code bleiben in der Dokumentation erhalten, z. B. `occupiedTacks`.

## Überblick

| Collector                         | Datei                                                           | Effektive Ausgabe                                                                |
| --------------------------------- | --------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `ModulesStatePublisher`           | `lua/LUA/ce/hub/data/modules/ModulesStatePublisher.lua`         | direkte Rückgabe; zusätzlich `DataAdded`/`DataChanged` für `ce.hub.Module`       |
| `RuntimeStatePublisher`           | `lua/LUA/ce/hub/data/runtime/RuntimeStatePublisher.lua`         | `ListChanged` für `ce.hub.Runtime`; Rückgabe leer                                |
| `VersionStatePublisher`           | `lua/LUA/ce/hub/data/version/VersionStatePublisher.lua`         | `ListChanged` für `ce.hub.EepVersion`; Rückgabe leer                             |
| `SignalStatePublisher`            | `lua/LUA/ce/hub/data/signals/SignalStatePublisher.lua`          | `ListChanged` für `ce.hub.Signal` und `ce.hub.WaitingOnSignal`; Rückgabe leer    |
| `SwitchStatePublisher`            | `lua/LUA/ce/hub/data/switches/SwitchStatePublisher.lua`         | `ListChanged` für `ce.hub.Switch`; Rückgabe leer                                 |
| `TimeStatePublisher`              | `lua/LUA/ce/hub/data/time/TimeStatePublisher.lua`               | `ListChanged` für `ce.hub.Time`; Rückgabe leer                                   |
| `WeatherStatePublisher`           | `lua/LUA/ce/hub/data/weather/WeatherStatePublisher.lua`         | `ListChanged` für `ce.hub.Weather`; Rückgabe leer                                |
| `DataSlotsStatePublisher`         | `lua/LUA/ce/hub/data/slots/DataSlotsStatePublisher.lua`         | `ListChanged` für `ce.hub.SaveSlot` und `ce.hub.FreeSlot`; Rückgabe leer         |
| `StructureStatePublisher`         | `lua/LUA/ce/hub/data/structures/StructureStatePublisher.lua`    | `ListChanged` für `ce.hub.Structure`; Rückgabe leer                              |
| `TrainsAndTracksStatePublisher`   | `lua/LUA/ce/hub/data/trains/TrainsAndTracksStatePublisher.lua`  | indirekte Events für Züge, Rollmaterial, RollingStock-Nebenströme und Tracks     |
| `TrafficLightModelStatePublisher` | `lua/LUA/ce/mods/road/data/TrafficLightModelStatePublisher.lua` | `ListChanged` für `ce.mods.road.SignalTypeDefinition`; Rückgabe leer             |
| `RoadStatePublisher`              | `lua/LUA/ce/mods/road/data/RoadStatePublisher.lua`              | Events für Kreuzungsdaten; internes Datenobjekt wird derzeit nicht zurückgegeben |
| `TransitStatePublisher`           | `lua/LUA/ce/mods/transit/data/TransitStatePublisher.lua`        | Events für ÖPNV-Daten; internes Datenobjekt wird derzeit nicht zurückgegeben     |

## Transportform

| Thema                               | CeType                                  | Schlüssel |
| ----------------------------------- | --------------------------------------- | --------- |
| Module                              | `ce.hub.Module`                         | `id`      |
| Laufzeit                            | `ce.hub.Runtime`                        | `id`      |
| Version                             | `ce.hub.EepVersion`                     | `id`      |
| Signale                             | `ce.hub.Signal`                         | `id`      |
| Wartende Fahrzeuge an Signalen      | `ce.hub.WaitingOnSignal`                | `id`      |
| Weichen                             | `ce.hub.Switch`                         | `id`      |
| Zeit                                | `ce.hub.Time`                           | `id`      |
| Wetter                              | `ce.hub.Weather`                        | `id`      |
| Belegte Datenslots                  | `ce.hub.SaveSlot`                       | `id`      |
| Freie Datenslots                    | `ce.hub.FreeSlot`                       | `id`      |
| Strukturen                          | `ce.hub.Structure`                      | `id`      |
| Züge, statisch                      | `ce.hub.TrainStatic`                    | `id`      |
| Züge, dynamisch                     | `ce.hub.TrainDynamic`                   | `id`      |
| RollingStock, statisch              | `ce.hub.RollingStockStatic`             | `id`      |
| RollingStock, dynamisch             | `ce.hub.RollingStockDynamic`            | `id`      |
| RollingStock-Textflächen            | `ce.hub.RollingStockTextures`           | `id`      |
| RollingStock-Rotation               | `ce.hub.RollingStockRotation`           | `id`      |
| Sonstige Gleise                     | `ce.hub.AuxiliaryTrack`                 | `id`      |
| Steuerstrecken                      | `ce.hub.ControlTrack`                   | `id`      |
| Straßen                             | `ce.hub.RoadTrack`                      | `id`      |
| Bahngleise                          | `ce.hub.RailTrack`                      | `id`      |
| Straßenbahngleise                   | `ce.hub.TramTrack`                      | `id`      |
| Ampelmodell-Definitionen            | `ce.mods.road.SignalTypeDefinition`     | `id`      |
| Kreuzungen                          | `ce.mods.road.Intersection`             | `id`      |
| Kreuzungs-Fahrspuren                | `ce.mods.road.IntersectionLane`         | `id`      |
| Kreuzungs-Schaltungen               | `ce.mods.road.IntersectionSwitching`    | `id`      |
| Kreuzungs-Ampeln                    | `ce.mods.road.IntersectionTrafficLight` | `id`      |
| Kreuzungs-Moduleinstellungen        | `ce.mods.road.ModuleSetting`            | `name`    |
| ÖPNV-Linien                         | `ce.mods.transit.Line`                  | `id`      |
| ÖPNV-Stationen                      | `ce.mods.transit.Station`               | `id`      |
| ÖPNV-Moduleinstellungen             | `ce.mods.transit.ModuleSetting`         | `name`    |
| Änderungsereignisse für Liniennamen | `ce.mods.transit.LineName`              | `id`      |

## Datenschemata

### `ce.hub.Module`

Elementtyp: Modulstatus

| Name      | Typ                  | Wertebereich        | Beschreibung                             |
| --------- | -------------------- | ------------------- | ---------------------------------------- |
| `id`      | `string` \| `number` | pro Modul eindeutig | Modul-ID aus dem registrierten Lua-Modul |
| `name`    | `string`             | freier Text         | Modulname aus der Registrierung          |
| `enabled` | `boolean`            | `true`, `false`     | Aktivierungsstatus des Moduls            |

Hinweis:

- `syncState()` liefert aktuell kein Listenobjekt, sondern ein Root-Objekt mit leeren `ceTypes = {}` plus Einträgen unter `root[module.id]`.

### `ce.hub.EepVersion`

Elementtyp: Versionsinfo

| Name             | Typ               | Wertebereich       | Beschreibung                                                         |
| ---------------- | ----------------- | ------------------ | -------------------------------------------------------------------- |
| `id`             | `string`          | fest `versionInfo` | technischer Schlüssel                                                |
| `name`           | `string`          | fest `versionInfo` | Anzeigename                                                          |
| `eepVersion`     | `string`          | z. B. `16.3`       | EEP-Version aus `EEPVer`; im Collector bewusst als String formatiert |
| `luaVersion`     | `string`          | Lua-Versionsstring | `_VERSION` des eingebetteten Lua                                     |
| `singleVersion`  | `string`          | Versionsstring     | Programmversion des Web-/Single-Prozesses                            |
| `eepLanguage`    | `string` \| `nil` | Sprachkennung      | Sprache der laufenden EEP-Instanz aus `EEPLng`                       |
| `layoutVersion`  | `number` \| `nil` | Versionsnummer     | Versionsnummer der geladenen Anlage aus `EEPGetAnlVer()`             |
| `layoutLanguage` | `string` \| `nil` | Sprachkennung      | Sprache der geladenen Anlage aus `EEPGetAnlLng()`                    |
| `layoutName`     | `string` \| `nil` | freier Text        | Name der geladenen Anlage aus `EEPGetAnlName()`                      |
| `layoutPath`     | `string` \| `nil` | Pfad               | Dateipfad der geladenen Anlage aus `EEPGetAnlPath()`                 |

### `ce.hub.Runtime`

Elementtyp: Laufzeitmetrik

| Name                 | Typ               | Wertebereich | Beschreibung                                          |
| -------------------- | ----------------- | ------------ | ----------------------------------------------------- |
| `id`                 | `string`          | Metrikname   | technischer Schlüssel der Laufzeitgruppe              |
| `count`              | `integer`         | `>= 0`       | Anzahl gemessener Aufrufe                             |
| `time`               | `number`          | Sekunden     | akkumulierte Laufzeit der Gruppe                      |
| `lastTime`           | `number`          | Sekunden     | zuletzt gemessene Laufzeit                            |
| `framesPerSecond`    | `number` \| `nil` | fps          | aktuelle Bildrate aus `EEPGetFramesPerSecond()`       |
| `currentFrame`       | `number` \| `nil` | Framezähler  | aktueller Framezähler aus `EEPGetCurrentFrame()`      |
| `currentRenderFrame` | `number` \| `nil` | Framezähler  | gesamter Framezähler aus `EEPGetCurrentRenderFrame()` |

### `ce.hub.Signal`

Elementtyp: Signal

| Name                    | Typ                 | Wertebereich                      | Beschreibung                                                                                          |
| ----------------------- | ------------------- | --------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `id`                    | `integer`           | `> 0`                             | Signal-ID aus EEP                                                                                     |
| `position`              | `integer`           | `> 0`; `0` wäre "existiert nicht" | Signalstellung aus `EEPGetSignal`; laut Lua-Handbuch liefert `0` ein nicht existierendes Signal       |
| `tag`                   | `string`            | freier Text bis 1024 Zeichen      | Tag-Text des Signals; aktuell aus `EEPSignalGetTagText`, leere Zeichenkette wenn kein Tag gesetzt ist |
| `waitingVehiclesCount`  | `integer`           | `>= 0`                            | Anzahl der am Signal wartenden Fahrzeugverbände aus `EEPGetSignalTrainsCount`                         |
| `stopDistance`          | `number` \| `nil`   | Meter                             | Halteabstand des Signals aus `EEPGetSignalStopDistance()`                                             |
| `itemName`              | `string` \| `nil`   | freier Text                       | Name des Signalartikels aus `EEPGetSignalItemName(signalId, false)`                                   |
| `itemNameWithModelPath` | `string` \| `nil`   | freier Text                       | Name inklusive Modellpfad aus `EEPGetSignalItemName(signalId, true)`                                  |
| `signalFunctions`       | `string[]` \| `nil` | Liste von Zustandswerten          | alle auslesbaren Signalfunktionen; aktuell als Stringliste serialisiert                               |
| `activeFunction`        | `string` \| `nil`   | Eintrag aus `signalFunctions`     | zur aktuellen `position` passende Signalfunktion                                                      |

Abgeleitet aus:

- `EEPGetSignal(signalId)`
- `EEPGetSignalTrainsCount(signalId)`
- `EEPGetSignalStopDistance(signalId)`
- `EEPGetSignalItemName(signalId, includeModelPath)`
- `EEPGetSignalFunctions(signalId)`
- `EEPGetSignalFunction(signalId, selectionIndex)`

### `ce.hub.WaitingOnSignal`

Elementtyp: Wartender Fahrzeugverband an einem Signal

| Name              | Typ       | Wertebereich                   | Beschreibung                                                        |
| ----------------- | --------- | ------------------------------ | ------------------------------------------------------------------- |
| `id`              | `string`  | `<signalId>-<position>`        | zusammengesetzter technischer Schlüssel                             |
| `signalId`        | `integer` | `> 0`                          | referenziertes Signal                                               |
| `waitingPosition` | `integer` | `>= 1`                         | Position innerhalb der Warteschlange am Signal                      |
| `vehicleName`     | `string`  | Fahrzeugverbandsname oder `""` | Name aus `EEPGetSignalTrainName`; bei fehlendem Namen leerer String |
| `waitingCount`    | `integer` | `>= 0`                         | Gesamtanzahl wartender Fahrzeugverbände an diesem Signal            |

Abgeleitet aus:

- `EEPGetSignalTrainName(signalId, position)`

### `ce.hub.Switch`

Elementtyp: Weiche

| Name       | Typ       | Wertebereich                      | Beschreibung                                                                                         |
| ---------- | --------- | --------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `id`       | `integer` | `> 0`                             | Weichen-ID                                                                                           |
| `position` | `integer` | `> 0`; `0` wäre "existiert nicht" | Weichenstellung aus `EEPGetSwitch`; laut Lua-Handbuch liefert `0` eine nicht existierende Weiche     |
| `tag`      | `string`  | freier Text bis 1024 Zeichen      | Tag-Text der Weiche; aktuell aus `EEPSwitchGetTagText`, leere Zeichenkette wenn kein Tag gesetzt ist |

Abgeleitet aus:

- `EEPGetSwitch(switchId)`

### `ce.hub.Time`

Elementtyp: EEP-Zeit

| Name           | Typ               | Wertebereich    | Beschreibung                                       |
| -------------- | ----------------- | --------------- | -------------------------------------------------- |
| `id`           | `string`          | fest `times`    | technischer Schlüssel                              |
| `name`         | `string`          | fest `times`    | Anzeigename                                        |
| `timeComplete` | `integer`         | `0` bis `86399` | Sekunden seit Mitternacht aus `EEPTime`            |
| `timeLapse`    | `number` \| `nil` | Zeitraffer      | aktueller Zeitrafferfaktor aus `EEPGetTimeLapse()` |
| `timeH`        | `integer`         | `0` bis `23`    | Stundenanteil aus `EEPTimeH`                       |
| `timeM`        | `integer`         | `0` bis `59`    | Minutenanteil aus `EEPTimeM`                       |
| `timeS`        | `integer`         | `0` bis `59`    | Sekundenanteil aus `EEPTimeS`                      |

Abgeleitet aus:

- `EEPTime`
- `EEPGetTimeLapse()`
- `EEPTimeH`
- `EEPTimeM`
- `EEPTimeS`

### `ce.hub.Weather`

Elementtyp: globaler Wetterzustand

| Name              | Typ               | Wertebereich       | Beschreibung                                             |
| ----------------- | ----------------- | ------------------ | -------------------------------------------------------- |
| `id`              | `string`          | fest `weather`     | technischer Schlüssel                                    |
| `name`            | `string`          | fest `weather`     | Anzeigename                                              |
| `season`          | `number` \| `nil` | EEP-spezifisch     | Jahreszeit aus `EEPGetSeason()`                          |
| `cloudsIntensity` | `number` \| `nil` | Prozent / EEP-Wert | globaler Wolkenanteil aus `EEPGetCloudsIntensity()`      |
| `cloudsMode`      | `number` \| `nil` | EEP-spezifisch     | Wolkenmodus aus `EEPGetCloudsMode()`                     |
| `windIntensity`   | `number` \| `nil` | Prozent / EEP-Wert | globale Windstärke aus `EEPGetWindIntensity()`           |
| `rainIntensity`   | `number` \| `nil` | Prozent / EEP-Wert | globale Regenintensität aus `EEPGetRainIntensity()`      |
| `snowIntensity`   | `number` \| `nil` | Prozent / EEP-Wert | globale Schneefallintensität aus `EEPGetSnowIntensity()` |
| `hailIntensity`   | `number` \| `nil` | Prozent / EEP-Wert | globale Hagelintensität aus `EEPGetHailIntensity()`      |
| `fogIntensity`    | `number` \| `nil` | Prozent / EEP-Wert | globale Nebeldichte aus `EEPGetFogIntensity()`           |

### `ce.hub.SaveSlot`

Elementtyp: belegter Datenslot

| Name   | Typ                                        | Wertebereich                | Beschreibung                                                 |
| ------ | ------------------------------------------ | --------------------------- | ------------------------------------------------------------ |
| `id`   | `integer`                                  | `1` bis `1000`              | Slotnummer                                                   |
| `name` | `string`                                   | freier Text, fallback `"?"` | Name des Slots aus `AkSlotNamesParser` oder `StorageUtility` |
| `data` | `string` \| `number` \| `boolean` \| `nil` | EEP-Datenslot-Inhalt        | Inhalt aus `EEPLoadData(id)`                                 |

Abgeleitet aus:

- `EEPLoadData(slot)`

### `ce.hub.FreeSlot`

Elementtyp: freier Datenslot

| Name   | Typ               | Wertebereich        | Beschreibung                  |
| ------ | ----------------- | ------------------- | ----------------------------- |
| `id`   | `integer`         | `1` bis `1000`      | Slotnummer                    |
| `name` | `string` \| `nil` | immer nicht gesetzt | bei freien Slots nicht belegt |
| `data` | `string` \| `nil` | immer nicht gesetzt | bei freien Slots nicht belegt |

### `structures`

Elementtyp: Struktur / Immobilie / Landschaftselement

| Name            | Typ       | Wertebereich                                                              | Beschreibung                                                                    |
| --------------- | --------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `id`            | `string`  | `#<nummer>`                                                               | Lua-Name der Struktur                                                           |
| `name`          | `string`  | `#<nummer>`                                                               | aktuell identisch zu `id`                                                       |
| `pos_x`         | `number`  | Koordinate in Anlagenkoordinaten                                          | X-Position aus `EEPStructureGetPosition`, auf zwei Nachkommastellen gerundet    |
| `pos_y`         | `number`  | Koordinate in Anlagenkoordinaten                                          | Y-Position aus `EEPStructureGetPosition`, auf zwei Nachkommastellen gerundet    |
| `pos_z`         | `number`  | Koordinate in Anlagenkoordinaten                                          | Z-Position aus `EEPStructureGetPosition`, auf zwei Nachkommastellen gerundet    |
| `rot_x`         | `number`  | Winkel in Grad                                                            | Rotation um X aus `EEPStructureGetRotation`, auf zwei Nachkommastellen gerundet |
| `rot_y`         | `number`  | Winkel in Grad                                                            | Rotation um Y aus `EEPStructureGetRotation`, auf zwei Nachkommastellen gerundet |
| `rot_z`         | `number`  | Winkel in Grad                                                            | Rotation um Z aus `EEPStructureGetRotation`, auf zwei Nachkommastellen gerundet |
| `modelType`     | `integer` | EEP-Modelltyp, z. B. `16`, `17`, `18`, `19`, `22`, `23`, `24`, `25`, `38` | Modelltyp aus `EEPStructureGetModelType`                                        |
| `modelTypeText` | `string`  | feste Textmenge                                                           | lesbarer Modelltyptext aus Collector-Mapping                                    |
| `tag`           | `string`  | freier Text bis 1024 Zeichen                                              | Tag-Text aus `EEPStructureGetTagText`                                           |
| `light`         | `boolean` | `true`, `false`                                                           | Lichtzustand aus `EEPStructureGetLight`                                         |
| `smoke`         | `boolean` | `true`, `false`                                                           | Rauchzustand aus `EEPStructureGetSmoke`                                         |
| `fire`          | `boolean` | `true`, `false`                                                           | Feuerzustand aus `EEPStructureGetFire`                                          |

Hinweis:

- Der Collector nimmt nur Strukturen auf, bei denen mindestens eines von `light`, `smoke` oder `fire` verfügbar ist.

Vollständige Liste `modelType` für Strukturen laut `Lua_manual.pdf` und `EEPStructureGetModelType`:

| Wert | Bedeutung                                             |
| ---- | ----------------------------------------------------- |
| `16` | `"Gleisobjekte" Bahngleise`                           |
| `17` | `"Gleisobjekte" Straßenbahn`                          |
| `18` | `"Gleisobjekte" Straßen`                              |
| `19` | `"Gleisobjekte" Wasserwege/Diverse`                   |
| `22` | Immobilien                                            |
| `23` | Landschaftselemente Fauna                             |
| `24` | Landschaftselemente Flora                             |
| `25` | Landschaftselemente Terra                             |
| `38` | Landschaftselemente, Bodenmodelle zur 3D-Texturierung |

### `ce.hub.TrainStatic`

Elementtyp: statische Zugdaten / selten geänderte Verbandsdaten

| Name                | Typ                | Wertebereich                              | Beschreibung                                                 |
| ------------------- | ------------------ | ----------------------------------------- | ------------------------------------------------------------ |
| `id`                | `string`           | Zugname, typ. `#...`                      | Name des Fahrzeugverbands                                    |
| `name`              | `string`           | Zugname                                   | Anzeigename; aktuell identisch zu `id`                       |
| `route`             | `string`           | Routenname, fallback `Alle`               | Route aus `EEPGetTrainRoute`                                 |
| `rollingStockCount` | `integer`          | `>= 0`                                    | Anzahl Rollmaterialien aus `EEPGetRollingstockItemsCount`    |
| `length`            | `number`           | Meter, `>= 0`                             | Zuglänge aus `EEPGetTrainLength`                             |
| `line`              | `string` \| `nil`  | freier Text                               | aus dem Tag-Modell der Bibliothek                            |
| `destination`       | `string` \| `nil`  | freier Text                               | aus dem Tag-Modell der Bibliothek                            |
| `direction`         | `string` \| `nil`  | freier Text                               | aus dem Tag-Modell der Bibliothek                            |
| `trackType`         | `string` \| `nil`  | z. B. `rail`, `road`, `tram`, `auxiliary` | Bibliotheksklassifikation, nicht direkt EEP                  |
| `movesForward`      | `boolean`          | `true`, `false`                           | aus der Zuggeschwindigkeit abgeleitete Fahrtrichtung         |

Abgeleitet aus:

- `EEPGetTrainRoute(trainName)`
- `EEPGetRollingstockItemsCount(trainName)`
- `EEPGetTrainLength(trainName)`

Vollständige Liste `trackType` laut `TrainDetection` / `TrackDetection`:

| Wert        | Bedeutung                                                             |
| ----------- | --------------------------------------------------------------------- |
| `rail`      | Bahngleise                                                            |
| `tram`      | Straßenbahn-Gleise                                                    |
| `road`      | Straßen                                                               |
| `auxiliary` | sonstige Splines / Wasserwege                                         |
| `control`   | Steuerstrecken / nicht direkt einem der vier Track-Systeme zugeordnet |

### `ce.hub.TrainDynamic`

Elementtyp: häufig aktualisierte Zugdaten

| Name            | Typ                | Wertebereich         | Beschreibung                                               |
| --------------- | ------------------ | -------------------- | ---------------------------------------------------------- |
| `id`            | `string`           | Zugname              | Referenz auf den Fahrzeugverband                           |
| `speed`         | `number`           | km/h                 | aktuelle Geschwindigkeit aus `EEPGetTrainSpeed(trainName)` |
| `targetSpeed`   | `number`           | km/h                 | Zielgeschwindigkeit aus `EEPGetTrainSpeed(trainName, true)`|
| `couplingFront` | `integer`          | Statuscode           | Zustand der vorderen Zugkupplung                           |
| `couplingRear`  | `integer`          | Statuscode           | Zustand der hinteren Zugkupplung                           |
| `active`        | `boolean`          | `true`, `false`      | ob der Zug aktuell in EEP ausgewählt ist                   |
| `trainyardId`   | `integer` \| `nil` | Depot-ID             | ID des virtuellen Depots aus `EEPIsTrainInTrainyard()`     |
| `inTrainyard`   | `boolean`          | `true`, `false`      | ob sich der Zug in einem virtuellen Depot befindet         |

Abgeleitet aus:

- `EEPGetTrainSpeed(trainName)`
- `EEPGetTrainCouplingFront(trainName)`
- `EEPGetTrainCouplingRear(trainName)`
- `EEPGetTrainActive()`
- `EEPIsTrainInTrainyard(trainName)`

### `ce.hub.RollingStockStatic`

Elementtyp: statische RollingStock-Daten / selten geänderte Fahrzeugdaten

| Name              | Typ                  | Wertebereich                              | Beschreibung                                                                                          |
| ----------------- | -------------------- | ----------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `id`              | `string`             | Fahrzeugname                              | technischer Schlüssel; aktuell gleich `name`                                                          |
| `name`            | `string`             | Fahrzeugname                              | Name des Rollmaterials                                                                                |
| `trainName`       | `string`             | Zugname oder `""`                         | zugeordneter Fahrzeugverband                                                                          |
| `positionInTrain` | `integer`            | `0`-basiert, `-1` falls unbekannt         | Position im Zugverband                                                                                |
| `couplingFront`   | `integer`            | Statuscode der vorderen Kupplung          | aus `EEPRollingstockGetCouplingFront`                                                                 |
| `couplingRear`    | `integer`            | Statuscode der hinteren Kupplung          | aus `EEPRollingstockGetCouplingRear`                                                                  |
| `length`          | `number`             | Meter                                     | Fahrzeuglänge aus `EEPRollingstockGetLength`                                                          |
| `propelled`       | `boolean` \| `number`| im Projekt als "hat Antrieb" genutzt      | abgeleitet aus `EEPRollingstockGetMotor`; das Lua-Handbuch beschreibt hier die Motor-/Ganginformation |
| `modelType`       | `integer`            | `1` bis `15`                              | Modelltyp aus `EEPRollingstockGetModelType`                                                           |
| `modelTypeText`   | `string`             | feste Textmenge                           | lesbarer Modelltyptext aus lokalem Mapping                                                            |
| `tag`             | `string`             | freier Text bis 1024 Zeichen              | Tag-Text aus `EEPRollingstockGetTagText`                                                              |
| `nr`              | `string` \| `nil`    | freier Text                               | Wagennummer aus dem bibliotheksinternen Tag-Modell                                                    |
| `trackType`       | `string` \| `nil`    | z. B. `rail`, `road`, `tram`, `auxiliary` | Bibliotheksklassifikation, nicht direkt EEP                                                           |
| `hookStatus`      | `number`             | Statuscode                                | Hakenzustand aus `EEPRollingstockGetHook()`                                                           |
| `hookGlueMode`    | `number`             | Statuscode                                | Haken-/Ladegutzand aus `EEPRollingstockGetHookGlue()`                                                 |

Abgeleitet aus:

- `EEPRollingstockGetLength`
- `EEPRollingstockGetMotor`
- `EEPRollingstockGetModelType`
- `EEPRollingstockGetTagText`
- `EEPRollingstockGetHook`
- `EEPRollingstockGetHookGlue`

### `ce.hub.RollingStockDynamic`

Elementtyp: häufig aktualisierte RollingStock-Daten

| Name                 | Typ               | Wertebereich                          | Beschreibung                                                                                      |
| -------------------- | ----------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `id`                 | `string`          | Fahrzeugname                          | Referenz auf das Rollmaterial                                                                     |
| `trackId`            | `integer`         | Track-ID                              | aus `EEPRollingstockGetTrack`                                                                     |
| `trackDistance`      | `number`          | Meter vom Gleisanfang                 | aus `EEPRollingstockGetTrack`                                                                     |
| `trackDirection`     | `integer`         | `1` oder `0`                          | laut Lua-Handbuch: `1 = in Fahrtrichtung`, `0 = entgegen`                                         |
| `trackSystem`        | `integer`         | `1` bis `4`                           | laut Lua-Handbuch: `1 = Bahngleise`, `2 = Straßen`, `3 = Tram`, `4 = sonstige Splines/Wasserwege`|
| `posX`               | `number`          | Anlagenkoordinate                     | X-Position aus `EEPRollingstockGetPosition`                                                       |
| `posY`               | `number`          | Anlagenkoordinate                     | Y-Position aus `EEPRollingstockGetPosition`                                                       |
| `posZ`               | `number`          | Anlagenkoordinate                     | Z-Position aus `EEPRollingstockGetPosition`                                                       |
| `mileage`            | `number`          | Zahl                                  | zurückgelegte Strecke in Metern seit Einsetzen des Modells                                        |
| `orientationForward` | `boolean`         | `true`, `false`                       | relative Ausrichtung im Zugverband aus `EEPRollingstockGetOrientation()`                          |
| `smoke`              | `number`          | Statuscode                            | Rauchzustand des Rollmaterials aus `EEPRollingstockGetSmoke()`                                    |
| `active`             | `boolean`         | `true`, `false`                       | ob das Rollmaterial aktuell in EEP ausgewählt ist, abgeleitet aus `EEPRollingstockGetActive()`   |

Abgeleitet aus:

- `EEPRollingstockGetOrientation`
- `EEPRollingstockGetSmoke`
- `EEPRollingstockGetActive()`
- `EEPRollingstockGetTrack`
- `EEPRollingstockGetPosition`
- `EEPRollingstockGetMileage`

Hinweis:

- Textflächen und Rotation werden nicht mehr direkt in den RollingStock-DTOs transportiert, sondern separat in `ce.hub.RollingStockTextures` und `ce.hub.RollingStockRotation`.

### `ce.hub.RollingStockTextures`

Elementtyp: beschreibbare Textflächen eines Rollmaterials

| Name           | Typ                    | Wertebereich                  | Beschreibung                                                                   |
| -------------- | ---------------------- | ----------------------------- | ------------------------------------------------------------------------------ |
| `id`           | `string`               | Fahrzeugname                  | technischer Schlüssel des Rollmaterials                                        |
| `surfaceTexts` | `table<string,string>` | Surface-ID als String -> Text | alle fortlaufend auslesbaren Textflächen aus `EEPRollingstockGetTextureText()` |

Hinweis:

- Die Flächen werden sequentiell ab Oberfläche `1` gelesen.
- Eine leere Zeichenkette ist ein gültiger, exportierter Textwert.
- Der Lesevorgang endet bei der ersten Oberfläche mit `ok = false`.

### `ce.hub.RollingStockRotation`

Elementtyp: Rotation eines Rollmaterials

| Name   | Typ      | Wertebereich   | Beschreibung                                               |
| ------ | -------- | -------------- | ---------------------------------------------------------- |
| `id`   | `string` | Fahrzeugname   | technischer Schlüssel des Rollmaterials                    |
| `rotX` | `number` | Winkel in Grad | Rotation um die X-Achse aus `EEPRollingstockGetRotation()` |
| `rotY` | `number` | Winkel in Grad | Rotation um die Y-Achse aus `EEPRollingstockGetRotation()` |
| `rotZ` | `number` | Winkel in Grad | Rotation um die Z-Achse aus `EEPRollingstockGetRotation()` |

Hinweis:

- Die Werte werden vor Vergleich und Export auf zwei Nachkommastellen gerundet, um Event-Rauschen zu reduzieren.

### `ce.hub.*Track`

Elementtyp: Track-Eintrag für `ce.hub.AuxiliaryTrack`, `ce.hub.ControlTrack`, `ce.hub.RoadTrack`, `ce.hub.RailTrack`, `ce.hub.TramTrack`

| Name                  | Typ                | Wertebereich       | Beschreibung                                                      |
| --------------------- | ------------------ | ------------------ | ----------------------------------------------------------------- |
| `id`                  | `integer`          | Track-ID           | technische ID des Tracks                                          |
| `reserved`            | `boolean` \| `nil` | `true`, `false`    | ob der Track aktuell reserviert ist                               |
| `reservedByTrainName` | `string` \| `nil`  | Zugname oder `nil` | Name des reservierenden Zugs aus `EEPIs*TrackReserved(..., true)` |

Vollständige Liste `trackType` laut `TrainDetection` / `TrackDetection`:

| Wert        | Bedeutung                                                             |
| ----------- | --------------------------------------------------------------------- |
| `rail`      | Bahngleise                                                            |
| `tram`      | Straßenbahn-Gleise                                                    |
| `road`      | Straßen                                                               |
| `auxiliary` | sonstige Splines / Wasserwege                                         |
| `control`   | Steuerstrecken / nicht direkt einem der vier Track-Systeme zugeordnet |

Vollständige Liste `modelType` für RollingStock laut `Lua_manual.pdf` und `EEPRollingstockGetModelType`:

| Wert | Bedeutung            |
| ---- | -------------------- |
| `1`  | Tenderlok            |
| `2`  | Schlepptenderlok     |
| `3`  | Tender               |
| `4`  | Elektrolok           |
| `5`  | Diesellok            |
| `6`  | Triebwagen           |
| `7`  | U- oder S-Bahn       |
| `8`  | Straßenbahn          |
| `9`  | Güterwaggon          |
| `10` | Personenwaggon       |
| `11` | Luftfahrzeug         |
| `12` | Maschine (z.B. Kran) |
| `13` | Wasserfahrzeug       |
| `14` | LKW                  |
| `15` | PKW                  |

### `ce.mods.road.SignalTypeDefinition`

Elementtyp: Ampelmodell-Definition

| Name                            | Typ                | Wertebereich        | Beschreibung                           |
| ------------------------------- | ------------------ | ------------------- | -------------------------------------- |
| `id`                            | `string`           | Modellname          | technischer Schlüssel des Ampelmodells |
| `name`                          | `string`           | Modellname          | Anzeigename                            |
| `type`                          | `string`           | aktuell fest `road` | Modellfamilie                          |
| `positions.positionRed`         | `integer` \| `nil` | Signalzustandsindex | Rotphase                               |
| `positions.positionGreen`       | `integer` \| `nil` | Signalzustandsindex | Grünphase                              |
| `positions.positionYellow`      | `integer` \| `nil` | Signalzustandsindex | Gelbphase                              |
| `positions.positionRedYellow`   | `integer` \| `nil` | Signalzustandsindex | Rot-Gelb-Phase                         |
| `positions.positionPedestrians` | `integer` \| `nil` | Signalzustandsindex | Fußgängerphase                         |
| `positions.positionOff`         | `integer` \| `nil` | Signalzustandsindex | ausgeschaltet                          |
| `positions.positionOffBlinking` | `integer` \| `nil` | Signalzustandsindex | Blinkbetrieb                           |

### `ce.mods.road.Intersection`

Elementtyp: Kreuzung

| Name               | Typ               | Wertebereich           | Beschreibung                                   |
| ------------------ | ----------------- | ---------------------- | ---------------------------------------------- |
| `id`               | `integer`         | laufende Nummer ab `1` | technischer Schlüssel der Collectorrunde       |
| `name`             | `string`          | freier Text            | Kreuzungsname                                  |
| `currentSwitching` | `string` \| `nil` | Sequenzname            | aktuell aktive Schaltung                       |
| `manualSwitching`  | `string` \| `nil` | Sequenzname            | manuell gewählte Schaltung                     |
| `nextSwitching`    | `string` \| `nil` | Sequenzname            | nächste geplante Schaltung                     |
| `ready`            | `boolean`         | `true`, `false`        | Ergebnis von `crossing:isGreenPhaseFinished()` |
| `timeForGreen`     | `number`          | Sekunden               | Grünphasenlänge                                |
| `staticCams`       | `string[]`        | Kameranamen            | Liste statischer Kameras der Kreuzung          |

### `ce.mods.road.IntersectionLane`

Elementtyp: Fahrspur einer Kreuzung

| Name                         | Typ                | Wertebereich                                                 | Beschreibung                                     |
| ---------------------------- | ------------------ | ------------------------------------------------------------ | ------------------------------------------------ |
| `id`                         | `string`           | `<intersectionId>-<laneName>`                                | technischer Schlüssel                            |
| `intersectionId`             | `integer`          | referenziert `ce.mods.road.Intersection.id`                  | zugehörige Kreuzung                              |
| `name`                       | `string`           | freier Text                                                  | Fahrspurname                                     |
| `phase`                      | `string`           | `NONE`, `YELLOW`, `RED`, `RED_YELLOW`, `GREEN`, `PEDESTRIAN` | aus der Ampelphasenlogik der Bibliothek          |
| `vehicleMultiplier`          | `number`           | projektabhängig                                              | Gewichtungsfaktor für Zähler                     |
| `eepSaveId`                  | `integer` \| `nil` | Datenslot-ID                                                 | zugehörige persistente ID                        |
| `type`                       | `string`           | `NORMAL`, `TRAM`, `PEDESTRIAN`                               | Fahrspurtyp                                      |
| `countType`                  | `string`           | `CONTACTS`, `SIGNALS`, `TRACKS`                              | Herkunft der Anforderungserkennung               |
| `waitingTrains`              | `table`            | Queue-Inhalt                                                 | wartende Fahrzeuge/Züge in aktueller Reihenfolge |
| `waitingForGreenCyclesCount` | `integer`          | `>= 0`                                                       | Anzahl Warteschleifen bis Grün                   |
| `directions`                 | `table`            | projektabhängig                                              | Richtungsdefinition der Fahrspur                 |
| `switchings`                 | `string[]`         | Sequenznamen                                                 | Schaltungen, die diese Fahrspur freigeben        |
| `tracks`                     | `table`            | Track-IDs oder Highlight-Daten                               | für Hervorhebung genutzte Tracks                 |

### `ce.mods.road.IntersectionSwitching`

Elementtyp: Kreuzungs-Schaltung

| Name             | Typ             | Wertebereich                    | Beschreibung                                                                                 |
| ---------------- | --------------- | ------------------------------- | -------------------------------------------------------------------------------------------- |
| `id`             | `string`        | `<crossingName>-<sequenceName>` | technischer Schlüssel                                                                        |
| `intersectionId` | `string`        | Kreuzungsname                   | aktueller Code verwendet hier den Namen, nicht die numerische `ce.mods.road.Intersection.id` |
| `name`           | `string`        | Sequenzname                     | Name der Schaltung                                                                           |
| `prio`           | `number \| nil` | projektabhängig                 | Priorität der Schaltung                                                                      |

### `ce.mods.road.IntersectionTrafficLight`

Elementtyp: Ampel innerhalb einer Kreuzung

| Name              | Typ                           | Wertebereich                                | Beschreibung                |
| ----------------- | ----------------------------- | ------------------------------------------- | --------------------------- |
| `id`              | `integer \| string`           | Signal-ID                                   | technischer Schlüssel       |
| `signalId`        | `integer`                     | Signal-ID                                   | referenziertes EEP-Signal   |
| `modelId`         | `string`                      | Modellname                                  | referenziertes Ampelmodell  |
| `currentPhase`    | `number` \| `string` \| `nil` | projektabhängig                             | aktuelle interne Ampelphase |
| `intersectionId`  | `integer`                     | referenziert `ce.mods.road.Intersection.id` | zugehörige Kreuzung         |
| `lightStructures` | `table<string, object>`       | indexierte Map                              | zugehörige Lichtstrukturen  |
| `axisStructures`  | `object[]`                    | Liste                                       | zugehörige Achsstrukturen   |

Unterobjekt `lightStructures[*]`:

| Name               | Typ               | Wertebereich   | Beschreibung                               |
| ------------------ | ----------------- | -------------- | ------------------------------------------ |
| `structureRed`     | `string` \| `nil` | Immobilienname | Immobilienname für das Rotlicht            |
| `structureGreen`   | `string` \| `nil` | Immobilienname | Immobilienname für das Grünlicht           |
| `structureYellow`  | `string` \| `nil` | Immobilienname | Immobilienname für das Gelblicht           |
| `structureRequest` | `string` \| `nil` | Immobilienname | Immobilienname für die Anforderungsanzeige |

Unterobjekt `axisStructures[*]`:

| Name                 | Typ             | Wertebereich    | Beschreibung                |
| -------------------- | --------------- | --------------- | --------------------------- |
| `structureName`      | `string`        | Immobilienname  | betroffener Immobilienname  |
| `axisName`           | `string`        | Achsname        | betroffene Achse            |
| `positionDefault`    | `number \| nil` | projektabhängig | Default-Position            |
| `positionRed`        | `number \| nil` | projektabhängig | Position bei Rot            |
| `positionGreen`      | `number \| nil` | projektabhängig | Position bei Grün           |
| `positionYellow`     | `number \| nil` | projektabhängig | Position bei Gelb           |
| `positionPedestrian` | `number \| nil` | projektabhängig | Position bei Fußgängerphase |
| `positionRedYellow`  | `number \| nil` | projektabhängig | Position bei Rot-Gelb       |

### `ce.mods.road.ModuleSetting`

Elementtyp: Kreuzungs-Moduloption

| Name          | Typ       | Wertebereich         | Beschreibung                   |
| ------------- | --------- | -------------------- | ------------------------------ |
| `category`    | `string`  | feste Textmenge      | logische Gruppe in der UI      |
| `name`        | `string`  | pro Gruppe eindeutig | Anzeigename der Option         |
| `description` | `string`  | freier Text          | Beschreibung für die UI        |
| `type`        | `string`  | aktuell `boolean`    | Optionstyp                     |
| `value`       | `boolean` | `true`, `false`      | aktueller Wert                 |
| `eepFunction` | `string`  | Lua-Funktionsname    | Setter-Funktion für die Option |

### `ce.mods.transit.Line`

Elementtyp: ÖPNV-Linie

| Name           | Typ        | Wertebereich        | Beschreibung               |
| -------------- | ---------- | ------------------- | -------------------------- |
| `id`           | `string`   | Liniennummer        | technischer Schlüssel      |
| `nr`           | `string`   | Liniennummer        | Anzeigenummer der Linie    |
| `trafficType`  | `string`   | `TRAM` oder `BUS`   | Verkehrstyp der Linie      |
| `lineSegments` | `object[]` | Liste von Segmenten | Routenabschnitte der Linie |

Unterobjekt `lineSegments[*]`:

| Name          | Typ        | Wertebereich   | Beschreibung                       |
| ------------- | ---------- | -------------- | ---------------------------------- |
| `id`          | `string`   | Routenname     | technischer Schlüssel des Segments |
| `destination` | `string`   | freier Text    | Ziel dieses Linienabschnitts       |
| `routeName`   | `string`   | EEP-Routenname | Referenz zur EEP-Route             |
| `lineNr`      | `string`   | Liniennummer   | Rückverweis auf die Linie          |
| `stations`    | `object[]` | Liste          | Halte des Segments in Reihenfolge  |

Unterobjekt `stations[*]`:

| Name            | Typ      | Wertebereich    | Beschreibung             |
| --------------- | -------- | --------------- | ------------------------ |
| `station.name`  | `string` | Stationsname    | Name der Zielstation     |
| `timeToStation` | `number` | Minuten, `>= 0` | Fahrzeit bis zur Station |

### `ce.mods.transit.Station`

Elementtyp: ÖPNV-Station

Aktueller Stand:

- Der Collector erzeugt derzeit immer eine leere Liste.
- Es gibt aktuell kein JSON-Schema, weil noch keine Stationseinträge erzeugt werden.

### `ce.mods.transit.ModuleSetting`

Elementtyp: ÖPNV-Moduloption

| Name          | Typ       | Wertebereich         | Beschreibung                   |
| ------------- | --------- | -------------------- | ------------------------------ |
| `category`    | `string`  | feste Textmenge      | logische Gruppe in der UI      |
| `name`        | `string`  | pro Gruppe eindeutig | Anzeigename der Option         |
| `description` | `string`  | freier Text          | Beschreibung für die UI        |
| `type`        | `string`  | aktuell `boolean`    | Optionstyp                     |
| `value`       | `boolean` | `true`, `false`      | aktueller Wert                 |
| `eepFunction` | `string`  | Lua-Funktionsname    | Setter-Funktion für die Option |

### `ce.mods.transit.LineName`

Elementtyp: Änderungsereignis für Linien

Schema:

- identisch zu `ce.mods.transit.Line`
- wird von `LineRegistry.fireChangeLinesEvent()` gesendet

## Rückgabewerte der `syncState()`-Funktionen

| Collector                                     | Rückgabe heute             | Bemerkung                               |
| --------------------------------------------- | -------------------------- | --------------------------------------- |
| `ModulesStatePublisher.syncState()`           | Objekt mit Modulen nach ID | einzig relevanter direkter Rückgabewert |
| `RuntimeStatePublisher.syncState()`           | `{}`                       | Nutzdaten nur im Event                  |
| `VersionStatePublisher.syncState()`           | `{}`                       | Nutzdaten nur im Event                  |
| `SignalStatePublisher.syncState()`            | `{}`                       | Nutzdaten nur im Event                  |
| `SwitchStatePublisher.syncState()`            | `{}`                       | Nutzdaten nur im Event                  |
| `TimeStatePublisher.syncState()`              | `{}`                       | Nutzdaten nur im Event                  |
| `WeatherStatePublisher.syncState()`           | `{}`                       | Nutzdaten nur im Event                  |
| `DataSlotsStatePublisher.syncState()`         | `{}`                       | Nutzdaten nur im Event                  |
| `StructureStatePublisher.syncState()`         | `{}`                       | Nutzdaten nur im Event                  |
| `TrainsAndTracksStatePublisher.syncState()`   | leeres `data`              | Nutzdaten über Registries               |
| `TrafficLightModelStatePublisher.syncState()` | `{}`                       | Nutzdaten nur im Event                  |
| `RoadStatePublisher.syncState()`              | `{}`                       | internes Datenobjekt wird verworfen     |
| `TransitStatePublisher.syncState()`           | `{}`                       | internes Datenobjekt wird verworfen     |

## Verwendete EEP-Funktionen und Handbuchbezug

Die wichtigsten direkt genutzten EEP-Funktionen für das Datenmodell sind:

- `EEPGetFramesPerSecond`, `EEPGetCurrentFrame`, `EEPGetCurrentRenderFrame`
- `EEPGetSignal`, `EEPGetSignalTrainsCount`, `EEPGetSignalTrainName`, `EEPGetSignalStopDistance`, `EEPGetSignalItemName`, `EEPGetSignalFunctions`, `EEPGetSignalFunction`
- `EEPGetSwitch`
- `EEPLoadData`
- `EEPStructureGetPosition`, `EEPStructureGetRotation`, `EEPStructureGetModelType`, `EEPStructureGetTagText`
- `EEPGetTrainRoute`, `EEPGetTrainLength`, `EEPGetTrainSpeed`, `EEPGetTrainCouplingFront`, `EEPGetTrainCouplingRear`, `EEPGetTrainActive`, `EEPIsTrainInTrainyard`
- `EEPRollingstockGetLength`, `EEPRollingstockGetMotor`, `EEPRollingstockGetModelType`, `EEPRollingstockGetTagText`, `EEPRollingstockGetOrientation`, `EEPRollingstockGetSmoke`, `EEPRollingstockGetHook`, `EEPRollingstockGetHookGlue`, `EEPRollingstockGetActive`, `EEPRollingstockGetTextureText`, `EEPRollingstockGetRotation`, `EEPRollingstockGetTrack`, `EEPRollingstockGetPosition`, `EEPRollingstockGetMileage`
- `EEPIsAuxiliaryTrackReserved`, `EEPIsControlTrackReserved`, `EEPIsRoadTrackReserved`, `EEPIsRailTrackReserved`, `EEPIsTramTrackReserved`
- `EEPGetAnlVer`, `EEPGetAnlLng`, `EEPGetAnlName`, `EEPGetAnlPath`
- `EEPGetSeason`, `EEPGetCloudsIntensity`, `EEPGetCloudsMode`, `EEPGetWindIntensity`, `EEPGetRainIntensity`, `EEPGetSnowIntensity`, `EEPGetHailIntensity`, `EEPGetFogIntensity`
- die Zeitvariablen `EEPTime`, `EEPTimeH`, `EEPTimeM`, `EEPTimeS` sowie `EEPGetTimeLapse`

Beschreibungen, Typen und Wertebereiche wurden, soweit vorhanden, aus `Lua_manual.pdf` übernommen oder daraus abgeleitet. Für fachliche Objekte der Bibliothek wie Kreuzungen, Fahrspuren, Linien und Moduloptionen stammt die Beschreibung aus dem Projektcode selbst.
