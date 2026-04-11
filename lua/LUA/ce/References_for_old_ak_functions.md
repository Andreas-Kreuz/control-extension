# Referenzen fuer alte `ak`-Funktionen und Module

Dieses Dokument richtet sich an Entwickler, die alte Referenzen aus der `ak`-Bibliothek repo-genau gegen die aktuelle `ce`-Struktur nachschlagen wollen.

Die Altseite bezieht sich auf `C:\Spiele\GitHub\ak-lua-bibliothek-fuer-eep\lua\LUA`.
Die Neuseite bezieht sich auf `control-extension\lua\LUA\ce`.

## Hinweise zur Lesart

- `1:1` bedeutet: alter und neuer Pfad sind als konkrete Modul- oder Dateireferenz belegbar.
- `Konzeptionell` bedeutet: Es gibt keinen sauberen 1:1-Ersatz, aber einen fachlichen Nachfolger.
- Historisch korrekte alte Namen werden beibehalten, insbesondere `ak.public-transport.*` und `ak.road.CrossingLuaModul`.

## Einstieg und Laufzeit

| Art           | Alt                                                  | Neu                                                      | Hinweis                                                                                                                                                        |
| ------------- | ---------------------------------------------------- | -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Konzeptionell | `require("ak.core.ModuleRegistry")`                  | `require("ce.ControlExtension")`                         | Fuer Anwender ist `ce.ControlExtension` der neue oeffentliche Einstieg. Intern liegen Teile heute in `ce.hub.ModuleRegistry` und `ce.hub.ControlExtensionHub`. |
| 1:1           | `ModuleRegistry.registerModules(...)`                | `ControlExtension.addModules(...)`                       | Neuer oeffentlicher Benutzerpfad.                                                                                                                              |
| 1:1           | `ModuleRegistry.runTasks(cycleCount)`                | `ControlExtension.runTasks(cycleCount)`                  | Zyklischer Lauf.                                                                                                                                               |
| 1:1           | `ModuleRegistry.activateServer()`                    | `ControlExtension.activateServer()`                      | Server-Kommunikation aktivieren.                                                                                                                               |
| 1:1           | `ModuleRegistry.deactivateServer()`                  | `ControlExtension.deactivateServer()`                    | Server-Kommunikation deaktivieren.                                                                                                                             |
| 1:1           | `ModuleRegistry.debug = true`                        | `ControlExtension.setDebug(true)`                        | Setter statt Feldzugriff.                                                                                                                                      |
| 1:1           | `ModuleRegistry.pauseEepDuringInitialization = true` | `ControlExtension.setPauseEepDuringInitialization(true)` | Setter statt Feldzugriff.                                                                                                                                      |
| Konzeptionell | `ModuleRegistry.useDlls(true)`                       | kein oeffentlicher Ersatz                                | In `ce.ControlExtension` gibt es dafuer keinen oeffentlichen Nachfolger.                                                                                       |
| 1:1           | `require("ak.scheduler.Scheduler")`                  | `require("ce.hub.scheduler.Scheduler")`                  | Scheduler-Kern.                                                                                                                                                |
| 1:1           | `require("ak.scheduler.Task")`                       | `require("ce.hub.scheduler.Task")`                       | Zeitgesteuerte Aufgabe.                                                                                                                                        |

## Modul-Wrapper

| Art           | Alt                                                      | Neu                                          | Hinweis                                                      |
| ------------- | -------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| Konzeptionell | `require("ak.core.CoreLuaModule")`                       | `require("ce.hub.CeHubModule")`              | Frueherer Kern-Wrapper, heute fachlich im Hub aufgegangen.   |
| Konzeptionell | `require("ak.data.DataLuaModule")`                       | `require("ce.hub.CeHubModule")`              | Datenexport ist heute Hub-orchestriert.                      |
| Konzeptionell | `require("ak.scheduler.SchedulerLuaModule")`             | `require("ce.hub.CeHubModule")`              | Scheduler wird heute ueber den Hub-Lebenszyklus mitgefuehrt. |
| 1:1           | `require("ak.road.CrossingLuaModul")`                    | `require("ce.mods.road.CeRoadModule")`       | Echter historischer Altpfad auf der `ak`-Seite.              |
| Konzeptionell | `require("ak.public-transport.PublicTransportLuaModul")` | `require("ce.mods.transit.CeTransitModule")` | OEffentlicher Verkehr / Linien / Haltestellen.               |

## Strassenverkehr

| Art | Alt                                             | Neu                                                  | Hinweis                                           |
| --- | ----------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------- |
| 1:1 | `require("ak.road.TrafficLight")`               | `require("ce.mods.road.TrafficLight")`               | Ampelobjekt.                                      |
| 1:1 | `require("ak.road.TrafficLightModel")`          | `require("ce.mods.road.TrafficLightModel")`          | Modellbeschreibung fuer Signale.                  |
| 1:1 | `require("ak.road.AxisStructureTrafficLight")`  | `require("ce.mods.road.AxisStructureTrafficLight")`  | Achsbasierte Strukturampel.                       |
| 1:1 | `require("ak.road.LightStructureTrafficLight")` | `require("ce.mods.road.LightStructureTrafficLight")` | Strukturampel.                                    |
| 1:1 | `require("ak.road.TramSwitch")`                 | `require("ce.mods.road.TramSwitch")`                 | Tram-Umschaltung.                                 |
| 1:1 | `require("ak.road.Lane")`                       | `require("ce.mods.road.Lane")`                       | Fahrspur.                                         |
| 1:1 | `require("ak.road.Crossing")`                   | `require("ce.mods.road.Intersection")`               | Fachliche Umbenennung `Crossing -> Intersection`. |
| 1:1 | `require("ak.road.CrossingSequence")`           | `require("ce.mods.road.IntersectionSequence")`       | Fachliche Umbenennung passend zur Intersection.   |
| 1:1 | `ak/road/CrossingDtoFactory.lua`                | `ce/mods/road/data/RoadDtoFactory.lua`               | DTO-Fabrik fuer Kreuzungsdaten.                   |
| 1:1 | `ak/road/TrafficLightModelDtoFactory.lua`       | `ce/mods/road/data/TrafficLightModelDtoFactory.lua`  | DTO-Fabrik fuer Signalmodelle.                    |

## OEffentlicher Verkehr / `public-transport`

| Art           | Alt                                                      | Neu                                                         | Hinweis                                              |
| ------------- | -------------------------------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------- |
| 1:1           | `require("ak.public-transport.Line")`                    | `require("ce.mods.transit.Line")`                           | Linie.                                               |
| 1:1           | `require("ak.public-transport.LineRegistry")`            | `require("ce.mods.transit.LineRegistry")`                   | Linien-Registry.                                     |
| 1:1           | `require("ak.public-transport.RoadStation")`             | `require("ce.mods.transit.RoadStation")`                    | Haltestelle.                                         |
| 1:1           | `require("ak.public-transport.RoadStationDisplayModel")` | `require("ce.mods.transit.models.RoadStationDisplayModel")` | Display-/Schildmodell.                               |
| Konzeptionell | `require("ak.public-transport.LineSegment")`             | `require("ce.mods.transit.LineSegment")`                    | Segmentlogik der Linie.                              |
| Konzeptionell | `require("ak.public-transport.Platform")`                | `require("ce.mods.transit.Platform")`                       | Plattform-/Steiglogik.                               |
| Konzeptionell | `ak/public-transport/PublicTransportLuaModule.lua`       | `ce/mods/transit/CeTransitModule.lua`                       | Modul-Wrapper.                                       |
| Konzeptionell | `ak/public-transport/PublicTransportJsonCollector.lua`   | `ce/mods/transit/data/TransitStatePublisher.lua`            | Nicht 1:1, da `ce` den Datenpfad anders organisiert. |

## Daten- und Web-Anbindung

| Art           | Alt                                          | Neu                                                  | Hinweis                                                                                                                                                                                                              |
| ------------- | -------------------------------------------- | ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1:1           | `require("ak.io.IoInit")`                    | `require("ce.databridge.IoInit")`                    | Initialisierung der dateibasierten Kommunikation.                                                                                                                                                                    |
| 1:1           | `require("ak.io.ServerExchangeCoordinator")` | `require("ce.databridge.ServerExchangeCoordinator")` | Austauschkoordination.                                                                                                                                                                                               |
| 1:1           | `require("ak.io.DataStoreFileWriter")`       | `require("ce.databridge.DataStoreFileWriter")`       | Dateischreiber fuer Datensnapshots.                                                                                                                                                                                  |
| 1:1           | `ak/io/ExchangeDirRegistry.lua`              | `ce/databridge/ExchangeDirRegistry.lua`              | Austauschverzeichnis.                                                                                                                                                                                                |
| 1:1           | `ak/io/ServerEventBuffer.lua`                | `ce/databridge/ServerEventBuffer.lua`                | Event-Puffer.                                                                                                                                                                                                        |
| 1:1           | `require("ak.events.DataChangeBus")`         | `require("ce.hub.publish.DataChangeBus")`            | Event- und Aenderungsbus.                                                                                                                                                                                            |
| 1:1           | `require("ak.data.DataStore")`               | `require("ce.hub.publish.InternalDataStore")`        | Interner materialisierter Zustand.                                                                                                                                                                                   |
| Konzeptionell | `require("ak.core.CoreWebConnector")`        | kein oeffentlicher 1:1-Ersatz                        | Die alte Connector-Logik ist in `ce` anders verteilt. Fuer Anwender ist `ce.ControlExtension` der stabile Einstieg; intern spielt `ce.hub.HubBridgeConnector` eine aehnliche Rolle, ist aber keine oeffentliche API. |
| Konzeptionell | `require("ak.data.DataWebConnector")`        | kein oeffentlicher 1:1-Ersatz                        | Der Datenfluss laeuft heute ueber Hub-/StatePublisher-/Bridge-Strukturen.                                                                                                                                            |
| Konzeptionell | `require("ak.core.ModulesJsonCollector")`    | kein direkter 1:1-Pfad                               | Module- und Zustandsdaten werden heute anders veroeffentlicht.                                                                                                                                                       |
| Konzeptionell | `require("ak.core.VersionJsonCollector")`    | kein direkter 1:1-Pfad                               | Versionsdaten laufen heute ueber den Hub-Datenpfad.                                                                                                                                                                  |

## Hub, EEP und Hilfsfunktionen

| Art | Alt                                        | Neu                                           | Hinweis                      |
| --- | ------------------------------------------ | --------------------------------------------- | ---------------------------- |
| 1:1 | `require("ak.core.eep.EepSimulator")`      | `require("ce.hub.eep.EepSimulator")`          | Test-/Simulationsumgebung.   |
| 1:1 | `require("ak.core.eep.TippTextFormatter")` | `require("ce.hub.eep.TippTextFormatter")`     | Formatierung von Tipptexten. |
| 1:1 | `require("ak.storage.StorageUtility")`     | `require("ce.hub.util.StorageUtility")`       | Persistenz-Helfer.           |
| 1:1 | `require("ak.util.TableUtils")`            | `require("ce.hub.util.TableUtils")`           | Tabellen-Helfer.             |
| 1:1 | `require("ak.util.Queue")`                 | `require("ce.hub.util.Queue")`                | Queue.                       |
| 1:1 | `require("ak.util.RuntimeRegistry")`       | `require("ce.hub.util.RuntimeRegistry")`      | Laufzeit-Registry.           |
| 1:1 | `ak/core/MainLoopRunner.lua`               | `ce/hub/MainLoopRunner.lua`                   | Hauptschleifen-Ausfuehrung.  |
| 1:1 | `ak/core/VersionInfo.lua`                  | `ce/hub/data/version/VersionInfo.lua`         | Versionsinformation.         |
| 1:1 | `ak/train/Train.lua`                       | `ce/hub/data/trains/Train.lua`                | Zugobjekt.                   |
| 1:1 | `ak/train/RollingStock.lua`                | `ce/hub/data/rollingstock/RollingStock.lua`   | Rollmaterial.                |
| 1:1 | `require("ak.train.TrainRegistry")`        | `require("ce.hub.data.trains.TrainRegistry")` | Zug-Registry.                |

## Sonstige 1:1-Umbenennungen

| Art | Alt                                            | Neu                                            | Hinweis             |
| --- | ---------------------------------------------- | ---------------------------------------------- | ------------------- |
| 1:1 | `require("ak.modellpacker.AkModellInstaller")` | `require("ce.modellpacker.AkModellInstaller")` | Modellpacker.       |
| 1:1 | `require("ak.modellpacker.AkModellPaket")`     | `require("ce.modellpacker.AkModellPaket")`     | Modellpacker.       |
| 1:1 | `require("ak.modellpacker.AkModellPacker")`    | `require("ce.modellpacker.AkModellPacker")`    | Modellpacker.       |
| 1:1 | `require("ak.third-party.json")`               | `require("ce.third-party.json")`               | JSON-Bibliothek.    |
| 1:1 | `require("ak.third-party.BetterContacts_BH2")` | `require("ce.third-party.BetterContacts_BH2")` | Drittanbieterdatei. |
| 1:1 | `require("ak.demo-anlagen...")`                | `require("ce.demo-anlagen...")`                | Demoanlagen.        |
| 1:1 | `require("ak.template...")`                    | `require("ce.template...")`                    | Vorlagen.           |
| 1:1 | `require("ak.rail.Rail")`                      | `require("ce.rail.Rail")`                      | Rail-Paket.         |

## Nicht blind ersetzen

Diese Muster sind bei einer Migration besonders fehleranfaellig:

- `ak.public-transport.*` wird nicht zu `ce.public-transport.*`, sondern zu `ce.mods.transit.*`.
- `ak.road.Crossing` wird nicht zu `ce.mods.road.Crossing`, sondern zu `ce.mods.road.Intersection`.
- `ak.road.CrossingSequence` wird nicht zu `ce.mods.road.CrossingSequence`, sondern zu `ce.mods.road.IntersectionSequence`.
- `ak.core.ModuleRegistry` hat keinen oeffentlichen 1:1-Ersatz unter `ce.hub.*`; fuer Anwender ist `ce.ControlExtension` der richtige Zielpfad.
