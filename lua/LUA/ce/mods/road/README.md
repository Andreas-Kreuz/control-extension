---
layout: page_with_toc
title: Ampeln? Automatisch!
subtitle: Du willst Dich nicht mehr um die Steuerung Deiner Ampeln k�mmern? - Dann beschreibe in Lua, wie Deine Kreuzung aussieht und das Skript Intersection �bernimmt f�r Dich den Rest.
permalink: lua/LUA/ce/mods/road/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Motivation

Willst Du mehr? - Lege Kontaktpunkte f�r die Verkehrsz�hlung an, damit die Ampel mit dem meisten Andrang bevorzugt geschaltet wird.

Das bekommst Du:

- Automatisches Schalten von Ampeln an Kreuzungen
- Priorisiertes Schalten der Ampeln nach Verkehrsandrang
- Optional, Ampeln nur dann schalten, wenn jemand davor wartet

# Zur Verwendung vorgesehene Klassen und Funktionen

## Klasse `TrafficLightModel`

Laden mit: `local TrafficLightModel = require("ce.mods.road.TrafficLightModel")`

Beschreibt das Modell einer Ampel mit den Phasen f�r rot, gr�n, gelb und rot-gelb, sowie dem Fu�g�ngersignal (falls vorhanden - dann hat die Ampel f�r den Stra�enverkehr rot)

### `TrafficLightModel:new()` - Ampelmodell anlegen

| Aufruf                                                                                                                                                                        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `TrafficLightModel:new(name, signalIndexRed, signalIndexGreen, signalIndexYellow, signalIndexRedYellow, signalIndexPedestrian, signalIndexSwitchOff, signalIndexBlinkYellow)` |

Jedes `TrafficLightModel` beschreibt, welche Signalstellung in EEP verwendet werden muss, um eine Ampel rot, rot-gelb, gr�n oder gelb zu schalten. Auch kann hinterlegt werden, welche Signalstellung f�r Fu�g�nger gr�n und welche f�r Ampel aus oder blinkend genutzt werden soll.
Mit der Funktion legst Du neue Modelle an. Das machst Du f�r jedes 3D-Modell, dass Du in einer Ampel nutzen m�chstest, falls das Modell
nicht schon mitgeliefert wird.

| Parameter                | Typ    | Bedeutung                                                                        |
| ------------------------ | ------ | -------------------------------------------------------------------------------- |
| name                     | string | Name des Ampeltyps                                                               |
| signalIndexRed           | number | Signalstellung im Signaldialog f�r rot (Index in der Liste "Stellung" im Dialog) |
| signalIndexGreen         | number | Signalstellung im Signaldialog f�r gr�n                                          |
| _signalIndexYellow_      | number | Signalstellung im Signaldialog f�r gelb (optional, sonst rot)                    |
| _signalIndexRedYellow_   | number | Signalstellung im Signaldialog f�r rot-gelben (optional, sonst rot)              |
| _signalIndexPedestrian_  | number | Signalstellung im Signaldialog f�r Fu�g�nger-gr�n (optional, sonst rot)          |
| _signalIndexSwitchOff_   | number | Signalstellung im Signaldialog f�r Ampel aus (optional, sonst gr�n)              |
| _signalIndexBlinkYellow_ | number | Signalstellung im Signaldialog f�r Ampel blinkt gelb                             |

| R�ckgabewert                                            |
| ------------------------------------------------------- |
| `TrafficLightModel` (neu erstellte Tabelle bzw. Objekt) |

**Beachte**: Die Funktion musst mit `:new()` statt `.new()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

### Mitgelieferte Ampelmodelle

```lua
-- Fuer die Strassenbahnsignale von MA1 - http://www.eep.euma.de/downloads/V80MA1F003.zip
-- 4er Signal, Stellung 2 als gr�n, z.B. Strab_Sig_09_LG auf gerade schalten
-- 4er Signal, Stellung 3 als gr�n, z.B. Strab_Sig_09_LG auf links schalten
-- 3er Signal, Stellung 3 als gr�n, z.B. Ak_Strab_Sig_05_gerade oder
--                                       Ak_Strab_Sig_05_gerade schalten
TrafficLightModel.MA1_STRAB_4er_2_gruen = TrafficLightModel:new("MA1_STRAB_4er_2_gruen", 1, 2, 4, 4)
TrafficLightModel.MA1_STRAB_4er_3_gruen = TrafficLightModel:new("MA1_STRAB_4er_3_gruen", 1, 3, 4, 4)
TrafficLightModel.MA1_STRAB_3er_2_gruen = TrafficLightModel:new("MA1_STRAB_3er_2_gruen", 1, 2, 3, 3)

-- Fuer die Ampeln von NP1 - http://eepshopping.de - Ampelset 1 und Ampelset 2
TrafficLightModel.NP1_3er_mit_FG = TrafficLightModel:new("Ampel_NP1_mit_FG", 2, 4, 5, 3, 1)
TrafficLightModel.NP1_3er_ohne_FG = TrafficLightModel:new("Ampel_NP1_ohne_FG", 1, 3, 4, 2)

-- Fuer die Ampeln von JS2 - http://eepshopping.de - Ampel-Baukasten (V80NJS20039)
-- Diese Signale sind teilweise mit und ohne Fussgaenger
TrafficLightModel.JS2_2er_nur_FG = TrafficLightModel:new("Ak_Ampel_2er_nur_FG", 1, 1, 1, 1, 2, 3, 3)
TrafficLightModel.JS2_3er_mit_FG = TrafficLightModel:new("Ampel_3er_XXX_mit_FG", 1, 3, 5, 2, 6, 7, 8)
TrafficLightModel.JS2_3er_ohne_FG = TrafficLightModel:new("Ampel_3er_XXX_ohne_FG", 1, 3, 5, 2, 1, 6, 7)
-- Zusatzampeln mit nur GELB und GR�N
TrafficLightModel.JS2_2er_OFF_YELLOW_GREEN = TrafficLightModel:new("Ampel_2er_Aus_Gelb-Gr�n", 1, 3, 5, 1, 1, 2, 6)
```

## Klasse `TrafficLight`

Laden mit: `local TrafficLight = require("ce.mods.road.TrafficLight")`

Diese Klasse wird dazu verwendet eine Signal auf der Anlage (signalId) mit einem Modell zu verkn�pfen. Eine so verkn�pfte Ampel kann dann einer Fahrspur zugewiesen werden. Die Ampel gilt f�r eine bestimmte Richtung und damit gegebenenfall f�r eine oder mehrere Fahrspuren.

### `TrafficLight:new()` - Ampel anlegen

| Aufruf                                                                                                                 |
| ---------------------------------------------------------------------------------------------------------------------- |
| `TrafficLight:new(name, signalId, trafficLightModel, redStructure, greenStructure, yellowStructure, requestStructure)` |

Jedes `TrafficLight` verbindet ein bestimmtes Signal anhand der Signal-ID mit einem Ampelmodell. F�r die einfache Unterscheidung kann ein Name vergeben werden. Mit dieser Funktion legst Du eine neue Ampel an. Das machst Du f�r alle Signale in EEP, die Du in der Kreuzung als Ampel verwenden m�chtest.

| Parameter            | Typ                 | Bedeutung                                                                        |
| -------------------- | ------------------- | -------------------------------------------------------------------------------- |
| `name`               | `string`            | Name des Verkehrssignals, z.B. "K1", "K2", "P1", "B1", "L1"                      |
| `signalId`           | `number`            | Die Signal-ID im Modul oben                                                      |
| `trafficLightModel`  | `TrafficLightModel` | Das verkn�pfte Modell. Die Ampel muss dieses Modell in 3D nutzen.                |
| _`redStructure`_     | `string`            | Immobilien-ID in EEP f�r rot deren Licht eingeschaltet wird (optional)           |
| _`greenStructure`_   | `string`            | Immobilien-ID in EEP f�r gr�n deren Licht eingeschaltet wird (optional)          |
| _`yellowStructure`_  | `string`            | Immobilien-ID in EEP f�r gelb deren Licht eingeschaltet wird (optional)          |
| _`requestStructure`_ | `string`            | Immobilien-ID in EEP f�r Anforderungen deren Licht eingeschaltet wird (optional) |

| R�ckgabewert                                       |
| -------------------------------------------------- |
| `TrafficLight` (neu erstellte Tabelle bzw. Objekt) |

**Beachte**: Die Funktion musst mit `:new()` statt `.new()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

_Vorschlag f�r den selbst vergebenen Namen:_

- `K1`, `K2`, `K3`, ... f�r Kfz
- `F1`, `F2`, `F3`, ... f�r Fu�g�nger
- `P1`, `S2`, `P3`, ... f�r Tram
- `B1`, `B2`, `B3`, ... f�r Bus
- `L1`, `L2`, `L3`, ... f�r unsichtbare Fahrspur-Ampeln

### Fu�g�ngersignale benennen

| Aufruf                                                                              |
| ----------------------------------------------------------------------------------- |
| `TrafficLight:new("K1", 12, TrafficLightModel.JS2_3er_mit_FG):withPedestrian("F1")` |
| `TrafficLight:newPedestrianOnly("F1", 20, TrafficLightModel.JS2_2er_nur_FG)`        |
| `TrafficLight:new("F1", 20, TrafficLightModel.JS2_2er_nur_FG):asPedestrianOnly()`   |

Ein `TrafficLight` kann ein Verkehrssignal, ein Fu�g�ngersignal oder beides zugleich darstellen.
Intern werden die Namen als `vehicleSignalName` und `pedestrianSignalName` getrennt gespeichert.

### Fahrspur-Ampeln und Signalgruppen

| Aufruf                                                                                                     |
| ---------------------------------------------------------------------------------------------------------- |
| `lane:driveOnDefaultSignalGroups(signalGroup...)`                                                          |
| `lane:routes(route...):driveOnlyOnSignalGroups(signalGroup...)`                                            |
| `lane:routes(route...):driveAlsoOnSignalGroups(signalGroup...)`                                            |
| `lane:routes(route...):driveOnlyOnSignalGroups(signalGroup...):showRequestsOnSignalGroups(signalGroup...)` |

Der Verkehr einer Fahrspur wird in EEP immer von genau einem Fahrspur-Signal gesteuert: dem `laneSignal` aus `Lane:new(...)`. Wenn mehrere sichtbare Ampeln entscheiden sollen, ob ein Fahrzeug fahren darf, nimm f�r `laneSignal` ein unsichtbares Signal. Dieses unsichtbare Signal h�lt die Fahrzeuge in EEP an oder gibt sie frei.

Signalgruppen beschreiben die Verkehrsstr�me, die eine Fahrspur freigeben k�nnen. Dazu ist die Route des aktuell an der ersten Stelle stehenden Fahrzeugs ausschlaggebend:

- `lane:driveOnDefaultSignalGroups(...)`: Standard-Signalgruppen. Der Fahrspurverkehr f�hrt, wenn eine dieser Signalgruppen gr�n ist, au�er f�r die erste Fahrzeugroute gilt gerade eine passende exklusive Regel.
- `lane:routes(...):driveAlsoOnSignalGroups(...)`: zus�tzliche Signalgruppen. Der Fahrspurverkehr f�hrt f�r diese Routen auch dann, wenn eine dieser Signalgruppen gr�n ist.
- `lane:routes(...):driveOnlyOnSignalGroups(...)`: exklusive Signalgruppen. Der Fahrspurverkehr f�hrt f�r diese Routen nur dann, wenn eine dieser Signalgruppen gr�n ist; Standard-Signalgruppen z�hlen dann nicht.

`routes(...)` ist vor `driveAlsoOnSignalGroups(...)` und `driveOnlyOnSignalGroups(...)` Pflicht und muss mindestens eine Route enthalten. Alle drei Methoden k�nnen mehrere Signalgruppen in einem Aufruf bekommen.

�ltere direkte TrafficLight-Schreibweisen wie `TrafficLight:applyToLane(...)`, `driveOnDefaultSignals(...)`, `driveOnlyOn(...)`, `driveAlsoOn(...)` und `showRequestsOn(...)` bleiben zur Kompatibilit�t erhalten. Neue Anlagen sollten Signalgruppen verwenden.

| Parameter     | Typ                | Bedeutung                                                          |
| ------------- | ------------------ | ------------------------------------------------------------------ |
| `signalGroup` | `SignalGroup`, ... | Eine oder mehrere Signalgruppen, deren Gr�n die Fahrspur freigibt. |
| `route`       | `string`, ...      | Eine oder mehrere Routen, f�r die eine Routensignal-Regel gilt.    |

Beispiele:

```lua
-- Eine einfache Fahrspur: K1 ist das sichtbare Signal (eine Ampel) und steuert direkt EEP.
local lane = Lane:new("K1L1", K1)

-- Andere sichtbare Ampeln entscheiden, ein unsichtbares Signal steuert die Fahrspur EEP.
local lane = Lane:new("L1", L1_unsichtbar)
lane:driveOnDefaultSignalGroups(sgLane1Straight):showRequestsOnSignalGroups(sgLane1Straight)

lane:routes("Tram 11 Heiderand", "Tram 11 Rehfeld")
    :driveOnlyOnSignalGroups(sgLane8Left)
    :showRequestsOnSignalGroups(sgLane8Left)

lane:routes("Rechtsabbieger")
    :driveAlsoOnSignalGroups(sgLane1Right)
    :showRequestsOnSignalGroups(sgLane1Right)
```

| R�ckgabewert                                                           |
| ---------------------------------------------------------------------- |
| `Lane` bzw. bei `routes(...)` bis zum Abschluss der Kette ein Builder. |

**Beachte**: Die Methoden werden mit Doppelpunkt aufgerufen, also z. B. `lane:driveOnDefaultSignalGroups(sgLane1Straight)`.

### `Signal:addLightStructure()` - Lichtsteuerung von Immobilien

| Aufruf                                                                                      |
| ------------------------------------------------------------------------------------------- |
| `Signal:addLightStructure(redStructure, greenStructure, yellowStructure, requestStructure)` |

F�gt bis zu vier Immobilien zu einer Ampel `TrafficLight` hinzu, deren Licht ein oder ausgeschaltet wird, sobald die Ampel auf rot, gelb oder gr�n geschaltet wird bzw. wenn sich die Anforderung an der Ampel �ndert.

| Parameter            | Typ      | Bedeutung                                                                        |
| -------------------- | -------- | -------------------------------------------------------------------------------- |
| `redStructure`       | `string` | Immobilien-ID in EEP f�r rot deren Licht eingeschaltet wird                      |
| `greenStructure`     | `string` | Immobilien-ID in EEP f�r gr�n deren Licht eingeschaltet wird                     |
| _`yellowStructure`_  | `string` | Immobilien-ID in EEP f�r gelb deren Licht eingeschaltet wird (optional)          |
| _`requestStructure`_ | `string` | Immobilien-ID in EEP f�r Anforderungen deren Licht eingeschaltet wird (optional) |

| R�ckgabewert                                                                             |
| ---------------------------------------------------------------------------------------- |
| Signal (Tabelle bzw. Objekt) - Die Ampel, welcher die Lichtimmobilen hinzugef�gt werden. |

**Beachte**: Die Funktion musst mit `:addLightStructure()` statt `.addLightStructure()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

_Hinweis:_
Passende Modelle f�r die Steuerung der Immobilien mit Licht findest Du im Modellset V10MA1F011.
Download unter <https://eep.euma.de/downloads.php> - Im Modell befindet sich eine ausf�hrliche Doku.

### `Signal:addAxisStructure()` - Achssteuerung von Immobilien

![BILD](../../../../assets/web/immo-achsen.png)

| Aufruf                                                                                                                           |
| -------------------------------------------------------------------------------------------------------------------------------- |
| `Signal:addAxisStructure(structureName, axisName, positionDefault, positionRed, positionGreen, positionRed, positionPedestrian)` |

F�gt bis zu vier Immobilien zu einer Ampel `TrafficLight` hinzu, deren Licht ein oder ausgeschaltet wird, sobald die Ampel auf rot, gelb oder gr�n geschaltet wird bzw. wenn sich die Anforderung an der Ampel �ndert.

| Parameter            | Typ                 | Bedeutung                                                                |
| -------------------- | ------------------- | ------------------------------------------------------------------------ |
| `structureName`      | `string`            | Name der Immobilie, deren Achse gesteuert werden soll                    |
| `axisName`           | `number`            | Name der Achse in der Immobilie, die gesteuert werden soll               |
| `positionDefault`    | `TrafficLightModel` | Grundstellung der Achse (wird f�r alle nicht angegebenen Phasen genutzt) |
| `positionRed`        | `string`            | Achsstellung bei rot                                                     |
| `positionGreen`      | `string`            | Achsstellung bei gr�n                                                    |
| `positionRed`        | `string`            | Achsstellung bei gelb                                                    |
| `positionPedestrian` | `string`            | Achsstellung bei FG                                                      |

| R�ckgabewert                                                                             |
| ---------------------------------------------------------------------------------------- |
| Signal (Tabelle bzw. Objekt) - Die Ampel, welcher die Achsenimmobilie hinzugef�gt wurde. |

**Beachte**: Die Funktion musst mit `:addAxisStructure()` statt `.addAxisStructure()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

## Klasse `Lane`

Laden mit: `local Lane = require("ce.mods.road.Lane")`

Eine Fahrspur definiert sich dadurch, dass darin Autos in einer Schlange an einer Fahrspur-Ampel anstehen.
Die Fahrspur-Ampel ist zwingend notwendig und kann direkt oder indirekt in Phasen verwendet werden.

### `Lane.Approach` - Zufahrt

`Lane.Approach` beschreibt, aus welcher Himmelsrichtung Fahrzeuge in die Kreuzung einfahren. Neue Anlagen sollten `Lane:setApproach(...)` verwenden.

- `Lane.Approach.NORTH`
- `Lane.Approach.NORTH_EAST`
- `Lane.Approach.EAST`
- `Lane.Approach.SOUTH_EAST`
- `Lane.Approach.SOUTH`
- `Lane.Approach.SOUTH_WEST`
- `Lane.Approach.WEST`
- `Lane.Approach.NORTH_WEST`

Migration: `Lane.Heading` und `Lane:setHeading(...)` bleiben als Kompatibilit�tsschicht erhalten, sind aber veraltet. Ein altes `Lane.Heading.NORTH` entspricht neu `Lane.Approach.SOUTH`, weil `Approach` die Zufahrt in die Kreuzung beschreibt.

### `Lane.Directions` - Fahrrichtungen

Um die Fahrtrichtungen einer Fahrspur festzulegen, nutze einen der folgenden Werte:

- `Lane.Directions.LEFT`
- `Lane.Directions.HALF_LEFT`
- `Lane.Directions.STRAIGHT`
- `Lane.Directions.HALF_RIGHT`
- `Lane.Directions.RIGHT`

### `Lane:new()` - Neue Fahrspur anlegen

| Aufruf                                                |
| ----------------------------------------------------- |
| `Lane:new(name, laneSignal, directions, trafficType)` |

Jede Fahrspur `Lane` bekommt genau ein `laneSignal`. Diese Ampel ist das EEP-Fahrspur-Signal, das Fahrzeuge wirklich anh�lt oder freigibt. Bei einfachen Fahrspuren kann das die sichtbare Ampel sein. Wenn mehrere Ampeln �ber dieselbe Fahrspur entscheiden sollen, ist `laneSignal` ein unsichtbares Signal.

| Parameter     | Typ                        | Bedeutung                                                         |
| ------------- | -------------------------- | ----------------------------------------------------------------- |
| `name`        | `string`                   | Name der Fahrspur, z.B. "L1", "L2", ... oder "K1L1", "K1L2", ...  |
| `laneSignal`  | `TrafficLight`             | Das eine EEP-Signal, das den Verkehr auf dieser Fahrspur steuert. |
| `directions`  | `{ Lane.Directions, ... }` | Tabelle mit einer oder mehreren Richtungen (optional)             |
| `trafficType` | `string`                   | Verkehrstyp (OBSOLET, MUSS IN `TrafficLight` �bertragen werden)   |

| R�ckgabewert                               |
| ------------------------------------------ |
| `Lane` (neu erstellte Tabelle bzw. Objekt) |

**Beachte**: Die Funktion musst mit `:new()` statt `.new()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

### `Lane:vehicleEntered()` / `lane:vehicleLeft(Zugname)` - Fahrzeuge mit Kontaktpunkten z�hlen

1. _Fahrspur betreten_<br> Rufe im Kontaktpunkt die Funktion `lane:vehicleEntered(Zugname)` auf, wenn ein Fahrzeug den Bereich betritt.

2. _Fahrspur verlassen_<br> Rufe im Kontaktpunkt die Funktion `lane:vehicleLeft(Zugname)` auf, wenn ein Fahrzeug den Bereich verl�sst.

[Mehr Informationen zur Fahrzeugerkennung in der Dokumentation](../../../docs/anleitungen-ampelkreuzung/tutorial3-priorisierung).

### `Lane:useSignalForQueue()` - Fahrzeuge an der Fahrspur-Ampel erkennen (NICHT EMPFOHLEN)

Dies z�hlt die Fahrzeig an der Fahrzeugampel. Da die Funktion aber nur zwischen Vor- und Hauptsignal funktioniert, wird sie nicht empfohlen! [Mehr Informationen zur Fahrzeugerkennung in der Dokumentation](../../../docs/anleitungen-ampelkreuzung/tutorial3-priorisierung).

### `Lane:useTrackForQueue(roadId)` - Fahrzeuge an der Stra�e erkennen (NICHT EMPFOHLEN)

Um die Fahrspur zu priorisieren, wenn sich **ein beliebiges Fahrzeug** auf der Stra�e vor der Ampel befindet, muss die ID des Stra�enst�cks einmalig hinterlegt werden: `lane:useTrackForQueue(strassenId)`. Da die Funtion aber weder die Reihenfolge der Fahrzeuge erkennt noch mehrere Fahrzeuge pro Track, wird sie nicht empfohlen! [Mehr Informationen zur Fahrzeugerkennung in der Dokumentation](../../../docs/anleitungen-ampelkreuzung/tutorial3-priorisierung).

## Klasse `TrafficPhase`

Laden mit: `local TrafficPhase = require("ce.mods.road.TrafficPhase")`

Die Phase `TrafficPhase` ist verantwortlich f�r den Wechsel zwischen den roten und gr�nen Ampelphasen. Jede Phase bekommt daf�r mindestens eine Signalgruppe.
Es sollten mindestens zwei Phasen `TrafficPhase` in einer Kreuzung angelegt werden. F�r das Anlegen neuer Phasen wird die Funktion `Intersection:newPhase(name)` empfohlen.

Wird dazu verwendet, mehrere Fahrspuren gleichzeitig zu schalten. Es muss sichergestellt werden, dass sich die Fahrwege der Fahrspuren einer Phase nicht �berlappen.

- `TrafficPhase:new(name)` - legt eine neue Phase an

- `Intersection:newSignalGroup(name)` legt eine Signalgruppe f�r einen Verkehrsfluss an.

- `SignalGroup:addVehicleSignals(K1)` f�gt ein oder mehrere physische `TrafficLight`-Objekte hinzu, f�r die mit den Zyklen Rot, Rot-Gelb, Gr�n und Gelb geschaltet wird.

- `SignalGroup:addTramSignals(S1)` f�gt ein oder mehrere physische `TrafficLight`-Objekte hinzu, f�r die mit den Zyklen Rot, Gr�n und Gelb geschaltet wird.

- `SignalGroup:addPedestrianSignals(F1)` f�gt ein oder mehrere physische `TrafficLight`-Objekte hinzu, f�r die mit den Zyklen Rot und Fu�g�nger-Gr�n geschaltet wird.

- `TrafficPhase:addSignalGroup(signalGroup...)` f�gt eine oder mehrere Signalgruppen zur Phase hinzu.

### `SignalGroup:addVehicleSignals()` - Ampeln f�r Kfz hinzuf�gen

| Aufruf                               |
| ------------------------------------ |
| `signalGroup:addVehicleSignals(...)` |

F�gt eine oder mehrere Ampeln vom Typ `TrafficLight` als Kfz-Ampeln zur Signalgruppe hinzu. Diese schalten nacheinander "Rot", "Rot-Gelb", "Gr�n", "Gelb", "Rot".

| Parameter | Typ                 | Bedeutung                                                    |
| --------- | ------------------- | ------------------------------------------------------------ |
| `...`     | `TrafficLight`, ... | Eine oder mehrere Ampeln (kommasepariert, nicht als Tabelle) |

| R�ckgabewert                                   |
| ---------------------------------------------- |
| `SignalGroup`, der die Ampel hinzugef�gt wurde |

**Beachte**: Die Funktion musst mit `:addVehicleSignals()` statt `.addVehicleSignals()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

### `SignalGroup:addPedestrianSignals()` - Ampeln f�r Fu�g�nger hinzuf�gen

| Aufruf                                  |
| --------------------------------------- |
| `signalGroup:addPedestrianSignals(...)` |

F�gt eine oder mehrere Ampeln vom Typ `TrafficLight` als Fu�g�nger-Ampeln zur Signalgruppe hinzu. Diese schalten nacheinander "Rot", "Gr�n Fu�g�nger", "Rot"

| Parameter | Typ                 | Bedeutung                                                    |
| --------- | ------------------- | ------------------------------------------------------------ |
| `...`     | `TrafficLight`, ... | Eine oder mehrere Ampeln (kommasepariert, nicht als Tabelle) |

| R�ckgabewert                                   |
| ---------------------------------------------- |
| `SignalGroup`, der die Ampel hinzugef�gt wurde |

**Beachte**: Die Funktion musst mit `:addPedestrianSignals()` statt `.addPedestrianSignals()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

### `SignalGroup:addTramSignals()` - Ampeln f�r Trams hinzuf�gen

| Aufruf                            |
| --------------------------------- |
| `signalGroup:addTramSignals(...)` |

F�gt eine oder mehrere Ampeln vom Typ `TrafficLight` als Tram-Ampeln zur Signalgruppe hinzu. Diese schalten nacheinander "Rot", "Gr�n", "Gelb", "Rot".

| Parameter | Typ                 | Bedeutung                                                    |
| --------- | ------------------- | ------------------------------------------------------------ |
| `...`     | `TrafficLight`, ... | Eine oder mehrere Ampeln (kommasepariert, nicht als Tabelle) |

| R�ckgabewert                                   |
| ---------------------------------------------- |
| `SignalGroup`, der die Ampel hinzugef�gt wurde |

**Beachte**: Die Funktion musst mit `:addTramSignals()` statt `.addTramSignals()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

## Klasse `Intersection`

Laden mit: `local Intersection = require("ce.mods.road.Intersection")`

### `Intersection:new()` - neue Kreuzung anlegen

| Aufruf                                     |
| ------------------------------------------ |
| `Intersection:new(name, greenTimeSeconds)` |

Legt eine neue Kreuzung an und registriert diese im Modul Kreuzungen. Nachdem Phasen zur Kreuzung hinzugef�gt wurden, funktioniert diese automatisch.

| Parameter            | Typ      | Bedeutung                                                             |
| -------------------- | -------- | --------------------------------------------------------------------- |
| `name`               | `string` | Name der Kreuzung, z.B. "Bahnshofsstr. / Hauptstr." oder "Kreuzung 1" |
| _`greenTimeSeconds`_ | `number` | L�nge einer Gr�nphase                                                 |

| R�ckgabewert                                       |
| -------------------------------------------------- |
| `Intersection` (neu erstellte Tabelle bzw. Objekt) |

**Beachte**: Die Funktion musst mit `:new()` statt `.new()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

### `Intersection:newSignalGroup()` - Eine Signalgruppe erstellen

| Aufruf                              |
| ----------------------------------- |
| `Intersection:newSignalGroup(name)` |

Legt eine Signalgruppe f�r einen Verkehrsfluss an. Jede logische Nutzung eines physischen `TrafficLight` darf nur in einer Signalgruppe vorkommen. Ein kombiniertes Fahrzeug-/Fu�g�ngersignal kann also einmal als Fahrzeug-Signal und einmal als Fu�g�nger-Signal verwendet werden, aber nicht in derselben Phase gleichzeitig freigegeben werden.

| Parameter | Typ      | Bedeutung                                                            |
| --------- | -------- | -------------------------------------------------------------------- |
| `name`    | `string` | Name der Signalgruppe, z.B. `sgLane1Straight` oder `sgPedNorthSouth` |

| R�ckgabewert                                      |
| ------------------------------------------------- |
| `SignalGroup`, die der Kreuzung hinzugef�gt wurde |

### `Intersection:newPhase()` - Eine Phase in einer Kreuzung erstellen

| Aufruf                        |
| ----------------------------- |
| `Intersection:newPhase(name)` |

F�gt eine neue Phase zur Kreuzung hinzu. Signalgruppen werden danach mit `TrafficPhase:addSignalGroup(...)` zur Phase hinzugef�gt.

| Parameter | Typ      | Bedeutung                                |
| --------- | -------- | ---------------------------------------- |
| `name`    | `string` | Name der Phase, z.B. "P1" oder "Phase A" |

| R�ckgabewert                                       |
| -------------------------------------------------- |
| `TrafficPhase`, die der Kreuzung hinzugef�gt wurde |

**Beachte**: Die Funktion musst mit `:newPhase()` statt `.newPhase()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

### `Intersection:addStaticCam()` - Eine Kamera zu dieser Kreuzung hinzuf�gen

| Aufruf                            |
| --------------------------------- |
| `Intersection:addStaticCam(name)` |

F�gt eine oder mehrere Ampeln vom Typ `TrafficLight` als Tram-Ampeln zur Kreuzung hinzu. Diese Schalten nacheinander "Rot", "Gr�n", "Gelb", "Rot"

| Parameter | Typ      | Bedeutung                         |
| --------- | -------- | --------------------------------- |
| `name`    | `string` | Name der statischen Kamera in EEP |

| R�ckgabewert |
| ------------ |
| `nil`        |

**Beachte**: Die Funktion musst mit `:addStaticCam()` statt `.addStaticCam()` aufgerufen werden -
also mit einem Doppelpunkt und nicht mit einem Punkt.

# Wichtige Hinweise

- **Damit das Ganze funktioniert**, muss `EEPMain()` mindestens den Befehl `ControlExtension.runTasks()` verwenden:

  ```lua
  local ControlExtension = require("ce.ControlExtension")
  ControlExtension.addModules(
      require("ce.hub.CeHubModule"),
      require("ce.mods.road.CeRoadModule") -- Registriert das Kreuzungsmodul
  )

  function EEPMain()
      ControlExtension.runTasks() -- F�hrt alle anstehenden Aktionen der registrierten Module aus
      return 1
  end
  ```

- **Fahrspuren mit Anforderungen und Fahrspuren die durch unterschiedliche Ampeln gesteuert werden ben�tigen zwingend Z�hlfunktionen** f�r die Fahrzeuge dieser Fahrspur. F�r andere Fahrspuren ist dies optional.
  - `lane:vehicleEntered(Zugname)` - im Kontaktpunkt aufrufen, wenn eine Fahrspur betreten wird (z.B. 50m vor der Ampel; aber nur auf dieser Fahrspursfahrbahn)

  - `lane:vehicleLeft(Zugname)` - im Kontaktpunkt aufrufen, wenn eine Fahrspur verlassen wird (hinter der Ampel)

  In der Z�hlfunktion MUSS der Zugname benutzt werden, da die Anforderungen und unterschiedlichen Ampeln durch die Routen der Fahrzeuge berechnet werden. Dazu dient folgender Quellcode:

  ```lua
  ------------------------------------------------
  -- Damit kommt wird die Variable "Zugname" automatisch durch EEP belegt
  -- http://emaps-eep.de/lua/code-schnipsel
  ------------------------------------------------
  setmetatable(_ENV, {
      __index = function(_, k)
          local p = load(k)
          if p then
              local f = function(z)
                  local s = Zugname
                  Zugname = z
                  p()
                  Zugname = s
              end
              _ENV[k] = f
              return f
          end
          return nil
      end
  })
  ```

  **Beachte:** Die Z�hlfunktionen m�ssen beim Betreten und Verlassen einer Fahrspur verwendet werden.
