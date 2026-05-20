# Architektur `ce.mods.road`

## Zweck

Dieses Paket kapselt die fachliche Logik für Straßenampeln, Fahrspuren und automatisch geschaltete Kreuzungen in EEP. Es ist kein reines Datenmodell, sondern kombiniert Konfiguration, zustandsbehaftete Laufzeitobjekte, Persistenz und direkte EEP-Aufrufe.

Die Kernaufgaben sind aktuell:

- Modellierung von Ampeltypen und konkreten Ampelinstanzen
- Verwaltung von Fahrspuren, Warteschlangen und Anforderungen
- Auswahl und zeitliche Ausführung der nächsten Verkehrsphase
- Pflege von Tipptexten an Signalen und optionalen Strukturen
- Export des Zustands für Web-Server und Web-App
- Bereitstellung kleiner EEP-naher Hilfen wie Straßenbahnweichen und Bus-Callbacks

Die Nutzungsdokumentation für den fachlichen Einsatz liegt in [README.md](./README.md). Das Datenmodell der exportierten Web-Räume ist in [DTO.md](./DTO.md) beschrieben. Diese Datei beschreibt die interne Struktur und den aktuellen Ist-Zustand des Pakets.

## Dateien in `ce/mods/road`

Das Paket ist jetzt in drei Bereiche gegliedert:

- Top-Level:
  [AxisStructureTrafficLight.lua](./AxisStructureTrafficLight.lua),
  [Bus.lua](./Bus.lua),
  [Intersection.lua](./Intersection.lua),
  [CeRoadModule.lua](./CeRoadModule.lua),
  [TrafficPhase.lua](./TrafficPhase.lua),
  [IntersectionSettings.lua](./IntersectionSettings.lua),
  [Lane.lua](./Lane.lua),
  [LaneSettings.lua](./LaneSettings.lua),
  [LightStructureTrafficLight.lua](./LightStructureTrafficLight.lua),
  [TrafficLight.lua](./TrafficLight.lua),
  [TrafficLightModel.lua](./TrafficLightModel.lua),
  [SignalIndication.lua](./SignalIndication.lua),
  [TramSwitch.lua](./TramSwitch.lua)
- [data/](./data/):
  [RoadDataCollector.lua](./data/RoadDataCollector.lua),
  [RoadDtoFactory.lua](./data/RoadDtoFactory.lua),
  [RoadStatePublisher.lua](./data/RoadStatePublisher.lua),
  [TrafficLightModelDtoFactory.lua](./data/TrafficLightModelDtoFactory.lua),
  [TrafficLightModelStatePublisher.lua](./data/TrafficLightModelStatePublisher.lua),
  [TrafficLightModelsDataCollector.lua](./data/TrafficLightModelsDataCollector.lua),
  [RoadDtoTypes.d.lua](./data/RoadDtoTypes.d.lua),
  [RoadDtoTypes.d.md](./data/RoadDtoTypes.d.md)
- [bridge/](./bridge/):
  [RoadBridgeConnector.lua](./bridge/RoadBridgeConnector.lua)

Wichtige Einordnung:

- `LaneSettings.lua` ist derzeit nur ein kleiner Hilfstyp und kein zentraler Teil des regulären Laufzeitpfads.
- `Bus.lua` und `TramSwitch.lua` sind EEP-Helfer im selben Themenfeld, aber nicht Teil des eigentlichen Kreuzungs-Schedulers.

## Architekturüberblick

Das Paket besteht aktuell aus fünf funktionalen Bereichen:

1. Domänenmodell: `SignalIndication`, `TrafficLightModel`, `TrafficLight`, `Lane`, `TrafficPhase`, `Intersection`
2. Modul- und Laufzeitintegration: `CeRoadModule`, `IntersectionSettings`
3. Datenexport: `RoadDataCollector`, `TrafficLightModelsDataCollector`, `RoadDtoFactory`, `TrafficLightModelDtoFactory`
4. Web-Anbindung: `RoadStatePublisher`, `TrafficLightModelStatePublisher`, `RoadBridgeConnector`
5. EEP-Helfer und Wertobjekte: `AxisStructureTrafficLight`, `LightStructureTrafficLight`, `TramSwitch`, `Bus`, `LaneSettings`

Der reguläre Ablauf sieht fachlich so aus:

1. Anwendercode erzeugt Modelle, Ampeln, Fahrspuren, Phasen und Kreuzungen.
2. `CeRoadModule.init()` registriert State-Publisher und Remote-Funktionen und ruft `Intersection.initPhases()` auf.
3. `CeRoadModule.run()` ruft zyklisch `Intersection.switchPhases()` auf.
4. `Intersection` berechnet je Kreuzung die nächste Phase und plant deren Ablauf über `Task` und `Scheduler`.
5. `TrafficLight` setzt Signalstellungen, Lichtimmobilien, Achsen und Tipptexte in EEP um.
6. Die Publisher senden Web-Zustände über `DataChangeBus`, die Datenbeschaffung dafür liegt in den Collectors unter `data/`.

Wichtig: Die Web-Schicht liest den Zustand aus den Fachobjekten aus, steuert aber nicht den Kernablauf. Die Umschaltlogik liegt vollständig in `Intersection`, `TrafficPhase`, `Lane` und `TrafficLight`.

## Bausteine

### [CeRoadModule.lua](./CeRoadModule.lua)

Moduleinstieg für den regulären Betrieb in `EEPMain()`.

Verantwortlichkeiten:

- einmalige Initialisierung des Pakets
- Registrierung der State-Publisher und Remote-Funktionen über `RoadBridgeConnector`
- Aufruf von `Intersection.initPhases()` nach Abschluss der Konfiguration
- zyklischer Aufruf von `Intersection.switchPhases()`
- implizites Nachziehen der Scheduler-Abhängigkeit über das eingebaute Hub-Modul `ce.hub.CeHubModule`

### [Intersection.lua](./Intersection.lua)

Zentrales Fachobjekt für eine Kreuzung und Haupt-Orchestrator der Verkehrslogik.

Verantwortlichkeiten:

- Verwaltung aller Kreuzungen in `Intersection.allIntersections`
- Halten von Phasen, Fahrspuren, Signalen, Ampelgruppen, optionalen Kameras und einer optionalen Tipptext-Struktur
- Umschalten zwischen Automatikmodus, manueller Phase und strikter Reihenfolge
- Berechnung der nächsten Phase über manuelle Vorgabe, Rundlauf oder Prioritätsvergleich
- Planung der zeitlichen Schaltfolge über `Task` und `Scheduler`
- Aktualisierung von Signal- und Struktur-Tipptexten
- Sammel-Reset aller Fahrspuren über `Intersection.resetVehicles()`

Wichtige Zustandsfelder pro Kreuzung:

- `currentPhase`
- `manualPhase`
- `nextPhase`
- `greenReached`
- `greenTimeFinished`
- `greenTimeSeconds`
- `switchInStrictOrder`
- `lanes`
- `signals`
- `staticCams`
- `tippStructure`

Besonderheiten:

- `Intersection.initPhases()` leitet die effektiven Fahrspuren einer Kreuzung aus den registrierten Phasen ab.
- `Intersection.switchPhases()` aktualisiert zusätzlich die globalen Signal-ID-Tipptexte für die Signal-IDs `1..1000`, sobald sich `IntersectionSettings.showSignalIdOnSignal` ändert.
- Neben `Intersection.allIntersections` existiert dateiintern noch eine zweite Tabelle `allIntersections`, die in einigen Schleifen ebenfalls verwendet wird.

### [TrafficPhase.lua](./TrafficPhase.lua)

Fachobjekt für eine Phase innerhalb einer Kreuzung.

Verantwortlichkeiten:

- Gruppierung von Ampelgruppen nach Typ
- Ableitung der zugehörigen Fahrspuren aus den registrierten Ampeln
- Vergleich alter und neuer Phase
- Erzeugung des zeitlichen Umschaltplans
- Berechnung und Zwischenspeicherung der mittleren Priorität `prio`

Wichtige Fachlogik:

- `signalHeadsToTurnRedAndGreen(oldPhase)` bestimmt, welche logischen Signal-Head-Verwendungen ihren Typ oder Zustand wechseln
- `tasksForPhaseChangeFrom(oldPhase, afterRedTask)` erzeugt die Taskfolge für Rot, Gelb, Rot-Gelb, Grün und Fußgängerphasen
- `lanesSortedByPriority()` berechnet die mittlere Priorität einer Phase aus den zugehörigen Fahrspuren
- `phasePriorityComparator(...)` vergleicht zwei Phasen für die automatische Auswahl

Aktueller Stand der Typen:

- Definiert sind `BUS`, `CAR`, `TRAM`, `PEDESTRIAN` und `BICYCLE`
- Im Kernpfad verwendet werden aktuell `CAR`, `TRAM` und `PEDESTRIAN`
- Öffentlich befüllt wird eine Phase mit `TrafficPhase:addSignalGroup(...)`. Die Ampelgruppen selbst werden über `SignalGroup:addVehicleSignals(...)`, `SignalGroup:addTramSignals(...)` und `SignalGroup:addPedestrianSignals(...)` aufgebaut.

### [Lane.lua](./Lane.lua)

Zustandsbehaftetes Fachobjekt für eine Fahrspur.

Verantwortlichkeiten:

- Verwaltung von Fahrzeugwarteschlange, Fahrzeuganzahl, Wartezyklen und aktueller Fahrspurphase
- Persistenz des Fahrspurzustands im Tipptext des Fahrspur-Signals
- Ermittlung von Anforderungen über Kontaktpunkte, Signale oder reservierte Straßentracks
- Berechnung von Fahrspurprioritäten für die Phasenwahl
- Zuordnung zusätzlicher Anforderungs-Ampelgruppen abhängig von Routen
- Spiegelung des Fahrzustands auf das eine EEP-Fahrspur-Signal `laneSignal`

Wichtige Betriebsarten für Anforderungen:

- gezählte Fahrzeuge über `vehicleEntered(...)` und `vehicleLeft(...)`
- Signalabfrage über `useSignalForQueue()`
- Track-Reservierung über `useTrackForQueue(roadId)`

Wichtige Zustandsfelder:

- `vehicleCount`
- `waitCount`
- `currentIndication`
- `queue`
- `firstVehiclesRoute`
- `requestType`
- `laneSignal`: das einzelne EEP-Signal, das Fahrzeuge auf der Fahrspur anhält oder freigibt
- `signalsToDriveOn`
- `defaultDriveSignals`
- `routeDriveRules`
- `requestSignals`
- `signalUsedForRequest`
- `tracksUsedForRequest`

Persistierte Felder pro Fahrspur:

- `f`: Fahrzeuganzahl
- `w`: Anzahl verpasster Grünzyklen
- `p`: letzte Phase
- `q`: Warteschlange als Pipe-getrennter String

Wichtig: Signal-Tipptexte speichern nur Strings. `Lane` serialisiert Zahlen, Status und Warteschlangen deshalb explizit als Strings.

### [TrafficLight.lua](./TrafficLight.lua)

Fachobjekt für eine konkrete Ampelinstanz.

Verantwortlichkeiten:

- Verknüpfung einer EEP-Signal-ID mit einem `TrafficLightModel`
- Halten der aktuellen Signalindikation
- Schalten des EEP-Signals über `EEPSetSignal(...)`
- Schalten zusätzlicher Lichtimmobilien über `EEPStructureSetLight(...)`
- Schalten zusätzlicher Achsimmobilien über `EEPStructureSetAxis(...)`
- Verteilung von Zustandsänderungen an registrierte Fahrspuren
- Aufbau und Anzeige von Tipptexten an Signalen oder Strukturen

Besonderheiten:

- negative oder nicht nutzbare Signal-IDs werden intern auf eigene negative IDs abgebildet; diese Ampeln sind logisch verwaltet und schalten kein EEP-Signal
- `lightStructures` und `axisStructures` ergänzen die eigentliche Signalsteuerung
- `Lane:driveOnDefaultSignalGroups(...)`, `Lane:routes(...):driveOnlyOnSignalGroups(...)` und `Lane:routes(...):driveAlsoOnSignalGroups(...)` koppeln Fahrspuren an Freigabe-Ampelgruppen
- `driveOnDefaultSignalGroups(...)` setzt Standard-Freigaben; `driveAlsoOnSignalGroups(...)` ergänzt sie für benannte Routen; `driveOnlyOnSignalGroups(...)` ersetzt sie für benannte Routen
- `routes(...)` muss mindestens eine Route enthalten
- ältere direkte TrafficLight-Lane-APIs bleiben zur Kompatibilität erhalten und delegieren auf die Lane-API
- `showRequestOnSignal(...)` steuert optionale Anforderungslichter an Zusatz-Immobilien
- das Feld `reason` ist zwar als Teil des Objekts vorgesehen und wird in `refreshInfo()` abgefragt, wird im aktuellen Codepfad aber nicht aktiv gesetzt

### [TrafficLightModel.lua](./TrafficLightModel.lua)

Definition eines Ampeltyps.

Verantwortlichkeiten:

- Zuordnung zwischen fachlichen Phasen und EEP-Signalstellungen
- Rückabbildung von Signalstellungen auf fachliche Phasen
- Registrierung aller Modelle in `TrafficLightModel.allModels`
- Bereitstellung vordefinierter Modelle für mehrere EEP-Ampelsets

Das Modell ist statisch und leichtgewichtig. Laufzeit- und Kreuzungszustand liegen in `TrafficLight`, `Lane`, `TrafficPhase` und `Intersection`.

### [SignalIndication.lua](./SignalIndication.lua)

Konstanten- und Hilfsschicht für Ampelphasen.

Aktuelle Phasen:

- `RED`
- `REDYELLOW`
- `YELLOW`
- `GREEN`
- `GREENYELLOW`
- `PEDESTRIAN`
- `OFF`
- `OFF_BLINKING`
- `UNKNOWN`

Wichtig: `canDrive(phase)` behandelt aktuell `GREEN`, `OFF` und `OFF_BLINKING` als freigebende Zustände.

### [IntersectionSettings.lua](./IntersectionSettings.lua)

Paketweite Anzeige- und Diagnoseeinstellungen.

Verantwortlichkeiten:

- Laden und Speichern globaler Kreuzungseinstellungen über `StorageUtility`
- Halten der globalen Bool-Flags für Tipptext-Ausgaben
- Bereitstellung von Setter-Funktionen für den lokalen Code und für Remote-Aufrufe

Aktuelle Settings:

- `showRequestsOnSignal`
- `showPhaseOnSignal`
- `showSignalIdOnSignal`
- `showLanesOnStructure`

Persistenzschlüssel:

- `reqInfo`
- `seqInfo`
- `sigInfo`
- `laneInfo`

### [bridge/RoadBridgeConnector.lua](./bridge/RoadBridgeConnector.lua)

Web-Adapter des Pakets.

Verantwortlichkeiten:

- Registrierung der State-Publisher beim `StatePublisherRegistry`
- Registrierung der erlaubten Remote-Funktionen beim `ServerExchangeCoordinator`

Registrierte Remote-Funktionen:

- `IntersectionSettings.setShowRequestsOnSignal`
- `IntersectionSettings.setShowPhaseOnSignal`
- `IntersectionSettings.setShowSignalIdOnSignal`
- `IntersectionSettings.setShowLanesOnStructure`
- `AkKreuzungSchalteAutomatisch`
- `AkKreuzungSchalteManuell`

### [RoadStatePublisher.lua](./RoadStatePublisher.lua)

State-Publisher für den aktuellen Kreuzungszustand.

Verantwortlichkeiten:

- Export aller Kreuzungen, Phasen, Fahrspuren und Ampeln
- Export der moduleigenen Anzeigeeinstellungen
- Normalisierung interner Werte für die Web-API
- Sortierung der Kreuzungen und Fahrspuren für stabile Ausgaben
- Emission der Daten über `DataChangeBus.fireListChange(...)`

Exportierte CeTypes:

- `ce.mods.road.Intersection`
- `ce.mods.road.IntersectionLane`
- `ce.mods.road.IntersectionPhase`
- `ce.mods.road.IntersectionTrafficLight`
- `ce.mods.road.ModuleSetting`

Wichtig: `syncState()` baut die Nutzdaten intern auf und veröffentlicht sie über `DataChangeBus`, liefert aber keine Nutzdaten zurück.

### [TrafficLightModelStatePublisher.lua](./TrafficLightModelStatePublisher.lua)

State-Publisher für statische Ampelmodelle.

Verantwortlichkeiten:

- Export aller registrierten `TrafficLightModel`-Definitionen
- Emission des CeTypes `ce.mods.road.TrafficLightModel` über `DataChangeBus`

Wie bei `RoadStatePublisher` erfolgt der eigentliche Transport aktuell über Events; `syncState()` liefert keine Nutzdaten zurück.

### [AxisStructureTrafficLight.lua](./AxisStructureTrafficLight.lua)

Wertobjekt für Achsimmobilien einer Ampel.

Verantwortlichkeiten:

- Validierung von Strukturname, Achsname und Positionswerten
- Sofortige Prüfung der referenzierten Achse über `EEPStructureGetAxis(...)`
- Halten der Zielpositionen pro Ampelphase

### [LightStructureTrafficLight.lua](./LightStructureTrafficLight.lua)

Wertobjekt für Lichtimmobilien einer Ampel.

Verantwortlichkeiten:

- Validierung der referenzierten Lichtimmobilien über `EEPStructureGetLight(...)`
- Halten der Strukturzuordnung für Rot, Gelb, Grün und Anforderung

### [TramSwitch.lua](./TramSwitch.lua)

Kleiner EEP-Helfer für Straßenbahnweichen.

Verantwortlichkeiten:

- Registrierung einer Weiche in EEP
- Anlegen des globalen Callbacks `EEPOnSwitch_<switchId>`
- Spiegelung der Weichenstellung auf bis zu drei Lichtimmobilien

### [Bus.lua](./Bus.lua)

Kleiner EEP-Helfer für Busachsen.

Verantwortlichkeiten:

- Öffnen und Schließen typischer Bustüren
- Initialisieren von Fahrer- und Fahrgastachsen
- Bereitstellung des globalen EEP-Callbacks `FAHRZEUG_INITIALISIERE`

### [LaneSettings.lua](./LaneSettings.lua)

Kleiner Hilfstyp für Fahrspureinstellungen.

Aktuelle Rolle:

- bündelt `lane`, `directions`, `routes`, `requestType` und `vehicleMultiplier`
- wird im aktuellen Kernlauf nicht von `Intersection`, `TrafficPhase` oder dem Web-Export verwendet

## Laufzeitfluss

Der reguläre Ablauf für eine automatisch geschaltete Kreuzung ist aktuell:

1. Anwendercode erzeugt `TrafficLightModel`, `TrafficLight`, `Lane`, `TrafficPhase` und `Intersection`.
2. `Lane:new(..., laneSignal, ...)` setzt das eine EEP-kontrollierende Fahrspur-Signal und lädt gespeicherten Zustand aus dessen Tipptext.
3. Zusätzliche Freigabe-Ampelgruppen werden optional über `driveOnDefaultSignalGroups(...)`, `routes(...):driveAlsoOnSignalGroups(...)` oder `routes(...):driveOnlyOnSignalGroups(...)` verdrahtet.
4. Phasen registrieren ihre Ampeln über `TrafficPhase:addSignalGroup(...)`.
5. `CeRoadModule.init()` registriert Web-Anbindung und ruft `Intersection.initPhases()` auf.
6. `Intersection.initPhases()` leitet aus allen Phasen die effektiven Fahrspuren und Ampeln je Kreuzung ab.
7. `CeRoadModule.run()` ruft zyklisch `Intersection.switchPhases()` auf.
8. `Intersection.switchPhases()` prüft pro Kreuzung, ob umgeschaltet werden darf, und ruft intern `switch(intersection)` auf.
9. `Intersection:calculateNextPhase()` wählt die nächste Phase per manueller Vorgabe, strikter Reihenfolge oder Prioritätsvergleich.
10. `TrafficPhase:tasksForPhaseChangeFrom(...)` erzeugt die Taskfolge für Gelb-, Rot-, Rot-Gelb-, Grün- und Fußgängerphasen.
11. `Scheduler:scheduleTask(...)` plant die einzelnen Umschaltvorgänge.
12. `TrafficLight.switchAll(...)` und `Signal:switchTo(...)` setzen Signalstellungen, Lichtimmobilien und Achsen.
13. Nach jedem Zyklus aktualisiert `Intersection` die Signal-Tipptexte und optional die Fahrspurübersicht an einer Struktur.
14. In Exportzyklen senden die State-Publisher den Web-Zustand über `DataChangeBus`.

Der reguläre Ablauf für Anforderungen in einer Fahrspur ist:

1. Ein Fahrzeug wird per Kontaktpunkt gezählt oder die Fahrspur liest ihren Zustand über Signal- oder Trackabfrage ein.
2. `Lane` aktualisiert Warteschlange, Fahrzeuganzahl und gegebenenfalls die erste Fahrzeugroute.
3. `Lane:checkRequests()` baut den Anforderungstext neu auf.
4. `refreshRequests(...)` informiert verknüpfte Anforderungsampeln.
5. `updateLaneSignal(...)` prüft anhand der freigebenden Ampeln und optionaler Routen, ob die sichtbare Fahrspurampel Grün zeigen darf.
6. Der Fahrspurzustand wird im Tipptext des Fahrspur-Signals gespeichert.

## Zustand

### Prozessweiter Zustand

`Intersection` hält:

- alle bekannten Kreuzungen in `Intersection.allIntersections`
- pro Kreuzung Phasen, Fahrspuren, Ampeln, Kameras und optionale Tipptext-Struktur
- den Umschaltzustand über `currentPhase`, `nextPhase`, `manualPhase`, `greenReached` und `greenTimeFinished`

`TrafficPhase` hält:

- die zugeordneten Ampelgruppen und logischen Signal-Head-Verwendungen mit Typ
- die daraus abgeleiteten Fahrspuren in `lanes`
- die zuletzt berechnete mittlere Priorität `prio`

`Lane` hält:

- Fahrzeuganzahl und Warteschlange
- verpasste Grünzyklen
- aktuelle Signalindikation
- Anforderungsmodus
- optionale Routen- und Freigaberegeln
- Signal- und Trackkonfiguration

`TrafficLight` hält:

- Signal-ID und Modell
- aktuelle Signalindikation
- registrierte Fahrspuren
- Licht- und Achsimmobilien
- vorbereitete Tooltip-Fragmente

`TrafficLightModel` hält:

- statische Signalindex-Zuordnungen je Modell
- die globale Liste aller Modelle

`IntersectionSettings` hält:

- die vier globalen Anzeigeflags
- optional den Persistenzslot `saveSlot`

### Persistenz

Das Paket nutzt aktuell zwei Persistenzformen:

- `Lane` speichert Laufzeitzustand pro Fahrspur im Tipptext des Fahrspur-Signals
- `IntersectionSettings` speichert die globalen Anzeigeeinstellungen über `StorageUtility`

Persistiert werden nur String-Werte. Deshalb serialisieren die Module Zahlen, Booleans und Warteschlangen vor dem Speichern.

Nicht persistent sind insbesondere:

- die Menge aller Kreuzungen
- die Zuordnung von Phasen zu Kreuzungen
- die registrierten State-Publisher und Remote-Funktionen
- statische Kameranamen und Strukturzuordnungen
- aktuelle Scheduler-Tasks

## Wichtige Invarianten

- Jede `Lane` hat genau einen `laneSignal`, der den Verkehr in EEP anhält oder freigibt.
- Eine `TrafficPhase` darf nur `TrafficLight`-Objekte enthalten.
- `Intersection.initPhases()` muss nach Abschluss der Konfiguration laufen, bevor `switchPhases()` sinnvoll arbeitet.
- `TrafficPhase:initPhase()` erwartet, dass die Ampeln ihre Fahrspuren bereits kennen.
- `Lane` serialisiert in den Signal-Tipptext und `IntersectionSettings` in `StorageUtility` nur String-Werte.
- Negative interne Signal-IDs stehen für logisch verwaltete Ampeln; `Signal:switchSignal(...)` setzt in diesem Fall kein EEP-Signal.
- `lightStructures` und `axisStructures` müssen auf existierende EEP-Strukturen beziehungsweise Achsen verweisen; die Hilfsklassen validieren das sofort.
- Die Web-Kommandos für Kreuzungen werden ausschließlich über `RoadBridgeConnector.registerFunctions()` freigegeben.
- Die State-Publisher müssen stabile Schlüsselfelder (`id` oder `name`) je exportiertem Element setzen.

## Typische Änderungsrisiken

### Inkonsistenter Umschaltablauf

Schon kleine Änderungen in `TrafficPhase:tasksForPhaseChangeFrom(...)` können den zeitlichen Ablauf zwischen Rot, Gelb, Rot-Gelb, Grün und Fußgängerphasen fachlich brechen.

### Verlorene oder fehlerhafte Persistenz

Änderungen an `Lane`-Tipptext-Persistenz oder `IntersectionSettings.saveSettings()/loadSettingsFromSlot()` können bestehende Anlagenzustände unlesbar machen oder Bool-Werte falsch interpretieren.

### Falsche Fahrspurzuteilung

Wenn `Intersection.initPhases()`, `TrafficLight:applyToLane(...)` oder `Lane:driveOn(...)` geändert werden, kann die Prioritätsberechnung falsche Fahrspuren einer Phase zuordnen.

### Sichtbare Nebenwirkungen in EEP

`TrafficLight`, `TramSwitch` und `Bus` rufen direkt `EEPSetSignal`, `EEPStructureSetLight`, `EEPStructureSetAxis`, `EEPShowInfoSignal`, `EEPShowInfoStructure`, `EEPChangeInfoSignal` oder `EEPSetTrainAxis` auf. Fehler wirken sich sofort sichtbar in EEP aus.

### Web-API-Drift

Änderungen an den State-Publishern können Web-Server, Web-App und das Datenmodell in [DTO.md](./DTO.md) auseinanderlaufen lassen.

### Globale Callback-Kollisionen

`TramSwitch` und `Bus` registrieren globale EEP-Callbacks. Änderungen an Namensschema oder Signatur können mit anderen Paketen kollidieren.

## Relevante Nachbarn

`ce/mods/road` arbeitet aktuell eng mit diesen Paketen zusammen:

- `ce.hub`: `ModuleRegistry`, `StatePublisherRegistry` und weitere Hub-Infrastruktur
- `ce.hub.scheduler`: `Scheduler`, `Task` und `CeHubModule`
- `ce.hub.publish`: `DataChangeBus` für Web-Zustandsänderungen
- `ce.hub.util`: `StorageUtility` für Persistenz-Helfer und Tipptext-Serialisierung
- `ce.hub.util.Queue`: Warteschlangen der Fahrspuren
- `ce.hub.eep.TippTextFormatter`: Aufbau der Tipptexte

## Empfehlung für KI-Agenten

Bei Änderungen in `ce/mods/road` zuerst diese Fragen beantworten:

1. Betrifft die Änderung nur einen State-Publisher oder auch die fachliche Schaltlogik?
2. Verändert sie zustandsbehafteten Laufzeit- oder Persistenzcode?
3. Muss die Web-Seite oder das Datenmodell in [DTO.md](./DTO.md) mit angepasst werden?
4. Greift die Änderung in EEP-nahe Aufrufe, Tipptexte oder globale Callbacks ein?
5. Bleibt der Umschaltablauf zwischen alter und neuer Phase fachlich korrekt und zeitlich vollständig?
