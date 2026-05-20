---
layout: page_with_toc
title: Ampelsteuerung 1
type: Tutorial mit Anlage
subtitle: Hier erfährst Du, wie Du die Ampeln einer Kreuzung mit 4 Fahrspuren in Lua verwendest - danach funktioniert alles automatisch.
img: '/assets/thumbnails/tutorial1-ampel.jpg'
date: 2017-09-01
permalink: docs/anleitungen-ampelkreuzung/ampelkreuzung
tags: [Verwendung, Anleitung]
published: false
---

# Ampelkreuzung automatisch steuern

<p class="lead"> Diese Anleitung zeigt Dir, wie Du in EEP eine mit Ampeln versehene Kreuzung mit der Lua-Bibliothek verdrahten kannst.</p>

<hr>

Dafür benötigst Du folgendes:

- **EEP 14** und einen **Editor für Lua-Skripte** Deiner Wahl, z.B. Notepad++
- **Zettel und Stift** - z.B.: [_Kreuzungsaufbau.pdf_](../../assets/Kreuzungsaufbau.pdf)
- Die **Anlage Andreas_Kreuz-Tutorial-Ampelkreuzung.anl3** (Download auf der Startseite)
  <br>Für den Betrieb dieser Anlage brauchst Du folgende **Modelle**:

  | 1Spur-Großstadtstraßen-System-Grundset (V10NAS30002) | _[Download](https://eepshopping.de/1spur-gro%C3%83%C6%92%C3%82%C5%B8stadtstra%C3%83%C6%92%C3%82%C5%B8en-system-grundset%7C7656.html)_ |
  | 1Spur-Ergänzungsset | _[Download](https://www.eepforum.de/filebase/file/215-freeset-zu-meinem-1spur-strassensystem/)_ |
  | Ampel-Baukasten für mehrspurige Straßenkreuzungen (V80NJS20039) | _[Download](https://eepshopping.de/ampel-baukasten-f%C3%83%C6%92%C3%82%C2%BCr-mehrspurige-stra%C3%83%C6%92%C3%82%C5%B8enkreuzungen%7C6624.html)_ |
  | Straßenbahnsignale als Immobilien (V80MA1F010 und V10MA1F011) | _[Download](http://www.eep.euma.de/download.php)_ |

⭐ **_Tipp_**: Die Lua-Bibliothek ist in der Installation der Anlage enthalten. Möchtest Du Deine eigene Anlage verwenden, so kannst Du die Bibliothek wie folgt installieren: [_Installation der Control Extension_](../anleitungen-installation/installation)

# Los geht's

- Öffne die Anlage in EEP
- Öffne Deinen Editor für Lua-Skripte

## Das Lua-Haupt-Skript anlegen

⭐ _**Tipp:** Aktiviere in EEP unter Programmeinstellungen das EEP Ereignisfenster, damit Du die Lua Meldungen lesen kannst._

❗ _**Beachte:** Diese Anleitung geht davon aus, dass in der geöffneten Anlage noch nichts mit LUA gemacht wurde. Verwendest Du Dein eigenes Anlagen-Skript, dann lösche es nicht, sondern ergänze es um die weiter unten aufgeführten Befehle._

<br>

- Das Haupt-Skript `meine-ampel-main.lua` wirst Du im nächsten Schritt im LUA-Verzeichnis von EEP anlegen: `C:\Trend\EEP14\LUA`

- Öffne den LUA-Editor in EEP, wähle alles mit `<Strg>` + `<A>` aus und ersetze es durch

  ```lua
  clearlog()
  require("meine-ampel-main")
  ```

- Klicke in EEP auf _"Skript neu laden"_ und wechsle in den 3D-Modus. <br>😀 **Wenn Du alles richtig gemacht hast**, erscheint im Log eine Fehlermeldung, dass `meine-ampel-main.lua` nicht gefunden werden kann.

  ![BILD](../../assets/tutorial/kreuzung/skript-nicht-gefunden.jpg)

<br>

- Lege nun das Haupt-Skript an `C:\Trend\EEP14\LUA\meine-ampel-main.lua` im Verzeichnis `LUA` an

  Dies wird das Skript werden, welches in der Anlage verwendet wird. Egal, wie Deine Anlage heißt.

- Klicke in EEP auf _"Skript neu laden"_ und wechsle in den 3D-Modus. <br>😀 **Wenn Du alles richtig gemacht hast**, erscheint eine Fehlermeldung, dass `meine-ampel-main.lua` nicht gefunden werden kann.

  ![BILD](../../assets/tutorial/kreuzung/eepmain-nicht-gefunden.jpg)

## Notwendige Befehle in das Lua-Skript aufnehmen

- Ergänze das Lua-Haupt-Skript um die folgenden Zeilen.

  ```lua
  local TrafficLight = require("ce.mods.road.TrafficLight")
  local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
  local Intersection = require("ce.mods.road.Intersection")
  local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
  local Lane = require("ce.mods.road.Lane")

  -- Hier kommt der Code

  local ControlExtension = require("ce.ControlExtension")
  ControlExtension.addModules(
      require("ce.hub.CeHubModule"),
      require("ce.mods.road.CeRoadModule")
  )

  function EEPMain()
      ControlExtension.runTasks()
      return 1
  end
  ```

- Klicke in EEP auf _"Skript neu laden"_ und wechsle in den 3D-Modus. <br>😀 **Wenn Du alles richtig gemacht hast**, verschwindet die Fehlermeldung

  ![BILD](../../assets/tutorial/kreuzung/eepmain-angelegt.jpg)

**Was ist grade passiert?**

- Die ersten Zeilen `local XXX = require("ce.mods.road.XXX")` sorgt dafür, daß die einzelnen Dateien z.B. `ce/mods/road/Crossing.lua` einmal eingelesen wird. Nach diesem Aufruf stehen Dir alle Funktionen dieser Datei zur Verfügung.
- Die Zeile `local ControlExtension = require("ce.ControlExtension")` lädt den öffentlichen Einstiegspunkt der Bibliothek.
- Mit den Zeilen `ControlExtension.addModules(require("ce.hub.CeHubModule"), require("ce.mods.road.CeRoadModule"))` werden das "CeHubModule" und das "CeRoadModule" in der Anwendung bekannt gemacht.
- Die Zeile `ControlExtension.runTasks()` ist für das wiederkehrende Ausführen aller Aufgaben, dadurch werden die Kreuzungsschaltungen und die geplanten Aktionen durchgeführt.
- Wichtig ist auch, dass die Funktion EEPMain mit `return 1` beendet wird, damit sie alle 200 ms aufgerufen wird.

## Alle Signale mit Tipp-Text markieren

Um die Signale (in dem Fall Ampeln) der Kreuzung zu bearbeiten ist es am einfachsten, wenn Du die Signal-IDs aller Signale in Tipp-Texten anzeigst.
In diesem Schritt läßt Du Dir von `Crossing` alle Signal-IDs in 3D anzeigen.

❗ _**Beachte:** Verwende diesen Code nicht, wenn Du in Deiner Anlagen selbst Tipp-Texte mit `EEPShowSignalInfo(...)` an Deinen Signalen anzeigst. Denn all diese Tipp-Texte werden gelöscht._

- Um die Tipp-Texte anzuzeigen, füge die folgenden beiden Zeilen vor der EEPMain()-Methode hinzu:

  ```lua
  -- Hier kommt der Code
  IntersectionSettings.showSignalIdOnSignal = true
  IntersectionSettings.showPhaseOnSignal = true
  ```

- Klicke in EEP auf _"Skript neu laden"_ und wechsle in den 3D-Modus. <br>😀 **Wenn Du alles richtig gemacht hast**, siehst Du an allen Signalen Tipp-Texte mit den IDs dieser Signale.

  ![BILD](../../assets/tutorial/kreuzung/signal-ids2.jpg)

**Was ist grade passiert?**

- Das neu Laden der Anlage hat dafür gesorgt, dass das Skript `Intersection` anhand der Variablen erkannt hat, dass es für alle Signale von 1 bis 1000 deren Signal-ID als Tipp-Text einblenden soll.

## Die Fahrspuren und Signal-IDs der Kreuzung notieren

_**Tipp:** Das [PDF-Dokument Kreuzungsaufbau.pdf](../../assets/Kreuzungsaufbau.pdf) hilft Dir deine Kreuzung zu notieren._

Notiere Dir, welche _Fahrspuren_ es gibt und wie die IDs der zu schaltenden Ampeln heißen - merke Dir dabei, welche unterschiedlichen Ampelmodelle eingesetzt werden.

**Wichtige Unterscheidung dabei:** Welche Ampeln steuern den Verkehr direkt (das sind die Fahrspur-Ampeln) und welche Ampeln müssen neben den Fahrspur-Ampeln noch in Ampelgruppen berücksichtigt werden.

In der Beispielanlage sind es:

- Kombinierte Fußgänger- und Strassenverkehrsampeln
- Reine Fußgängerampeln _(die sind in der Skizze bei "FG" unterstrichen)_
- Strassenverkehrsampeln _(die sind in der Skizze bei "Fahrspur" unterstrichen)_

![BILD](../../assets/tutorial/kreuzung/kreuzungsaufbau-tutorial-richtungen.png)

**Was ist eine _Fahrspur_**: In diesem Abschnitt wird viel von _Fahrspuren_ geredet. Eine _Fahrspur_ besteht aus Straßen-Splines, auf denen mehrere Fahrzeuge hintereinander an einer Ampel anstehen.

- **Jede Fahrspur hat genaue eine Fahrspur-Ampel.** Dies ist die einzige Ampel, die auf der Straße der Fahrspur stehen darf.
  Die Fahrspur-Ampel läßt Fahrzeuge der Fahrspur anhalten oder fahren.

- **Nur die Fahrspur-Ampel steuert Fahrzeuge.** Nur die Ampel auf der Fahrspur darf die Fahrzeuge durch das Ampelbild steuern.
  Du kannst aber weitere Ampeln für Fahrzeuge aufstellen, z.B. eine zweite Ampel auf der linken Straßenseite oder ein dritte über dem Verkehr. Nur die Fahrspur-Ampel darf den Verkehr auf der Straße steuern - alle anderen Ampeln müssen so aufgestellt werden, dass sie den Verkehr nicht beeinflussen.

- **Fahrspuren werden nicht geschaltet, sondern Ampelgruppen.** Jede Phase der Kreuzung schaltet bestimmte Ampelgruppen auf grün. Dabei wird auch die Fahrspur-Ampel gesteuert.
  - Im einfachen Fall ist die Fahrspur-Ampel Teil genau einer Ampelgruppe
  - Später werden wir Szenarien haben, in denen die Fahrspur-Ampel unsichtbar ist, da mehrere andere Ampeln für die Fahrspur gelten. Der Verkehr wird dann abhängig von den anderen Ampeln gesteuert.

- **Empfehlung: Erstelle immer eigene Fahrspuren für Linksabbieger, wenn diese den Gegenverkehr kreuzen**.
  Wenn Du dich nicht selbst darum kümmern willst, dass Fahrzeuge den Gegenverkehr beachten, dann solltest Du immer eigene Linksabbieger-Fahrspuren anlegen. Schalte Linksabbieger-Fahrspuren nur dann auf grün, wenn der Gegenverkehr den Fahrweg der Linksabbieger nicht kreuzen kann.
  - **Alternative:** Du kannst auch eigene unsichtbaren Ampeln in der Mitte der Kreuzung einbauen und die Linkabbieder nur dann fahren lassen, wenn kein Gegenverkehr kommt. Dies musst Du jedoch selbst machen.

Erst im nächsten Schritt werden mehrere Ampelgruppen der _Fahrspuren_ in Phasen zusammengefasst.

## Schreibe die Ampeln und Fahrspuren in das Haupt-Skript

⭐ _**Tipp:** In EEP sind viele Signalmodelle "Ampel" unterschiedlich gesteuert, was die Rot-, Grün- und Gelb-Schaltung angeht. Damit jede Ampel Deiner Kreuzung verwendet werden kann und automatisch funktioniert, gibt es_ `TrafficLightModel` _. In diesem Lua-Skript sind die Signalstellungen der Ampeln hinterlegt. Weitere Informationen findest Du unter: [Unterstütze weitere Ampeln in TrafficLightModel](../lua/LUA/ce/mods/road/)_

Schreibe nun die Ampeln in das Haupt-Skript.

```lua
local K1 = TrafficLight:new("K1", 12, TrafficLightModel.JS2_3er_mit_FG)
local K2 = TrafficLight:new("K2", 17, TrafficLightModel.JS2_3er_ohne_FG)
local K3 = TrafficLight:new("K3", 9, TrafficLightModel.JS2_3er_mit_FG)
local K4 = TrafficLight:new("K4", 14, TrafficLightModel.JS2_3er_mit_FG)
local K5 = TrafficLight:new("K5", 16, TrafficLightModel.JS2_3er_mit_FG)
local K6 = TrafficLight:new("K6", 18, TrafficLightModel.JS2_3er_ohne_FG)
local K7 = TrafficLight:new("K7", 11, TrafficLightModel.JS2_3er_mit_FG)
local K8 = TrafficLight:new("K8", 10, TrafficLightModel.JS2_3er_mit_FG)
local K9 = TrafficLight:new("K9", 19, TrafficLightModel.JS2_3er_ohne_FG)
local K10 = TrafficLight:new("K10", 13, TrafficLightModel.JS2_3er_mit_FG)
local K11 = TrafficLight:new("K11", 15, TrafficLightModel.JS2_3er_mit_FG)
local K12 = TrafficLight:new("K12", 24, TrafficLightModel.JS2_3er_ohne_FG)

local F1 = K1:withPedestrian("F1")
local F2 = K3:withPedestrian("F2")
local F3 = TrafficLight:newPedestrianOnly("F3", 20, TrafficLightModel.JS2_2er_nur_FG)
local F4 = TrafficLight:newPedestrianOnly("F4", 21, TrafficLightModel.JS2_2er_nur_FG)
local F5 = K4:withPedestrian("F5")
local F6 = K5:withPedestrian("F6")
local F7 = K7:withPedestrian("F7")
local F8 = K8:withPedestrian("F8")
local F9 = TrafficLight:newPedestrianOnly("F9", 22, TrafficLightModel.JS2_2er_nur_FG)
local F10 = TrafficLight:newPedestrianOnly("F10", 23, TrafficLightModel.JS2_2er_nur_FG)
local F11 = K10:withPedestrian("F11")
local F12 = K11:withPedestrian("F12")
```

Schreibe danach die Fahrspuren in das Skript:

```lua
-------------------------------------------------------------------------------
-- Definiere die Fahrspuren fuer die Kreuzung
-------------------------------------------------------------------------------

--   +---------------------------------------------- Neue Fahrspur
--   |        +------------------------------- Name der Fahrspur
--   |        |     +------------------------- Speicher ID - um die Anzahl der Fahrzeuge
--   |        |     |                                        und die Wartezeit zu speichern
--   |        |     |      +------------------ Fahrspur-Ampel - da wartet der Verkehr
--   |        |     |      |  +--------------- Richtungen dieser Fahrspur
n1 = Lane:new("N1", K1, {'STRAIGHT', 'RIGHT'})
n2 = Lane:new("N2", K3, {'LEFT'}) -- zusätzlich in der Ampelgruppe: K2

-- Fahrspuren im Osten
o1 = Lane:new("O1", K4, {'STRAIGHT', 'RIGHT'})
o2 = Lane:new("O2", K6, {'LEFT'}) -- zusätzlich in der Ampelgruppe: K5

-- Fahrspuren im Sueden
s1 = Lane:new("S1", K7, {'STRAIGHT', 'RIGHT'})
s2 = Lane:new("S2", K8, {"LEFT"}) -- zusätzlich in der Ampelgruppe: K9

-- Fahrspuren im Westen
w1 = Lane:new("W1", K10, {'STRAIGHT', 'RIGHT'})
w2 = Lane:new("W2", K12, {'LEFT'}) -- zusätzlich in der Ampelgruppe: K11
```

- Klicke in EEP auf _"Skript neu laden"_ und wechsle in den 3D-Modus. <br> 😀 **Wenn Du alles richtig gemacht hast**, siehst Du weiterhin an allen Signalen Tipp-Texte mit den IDs dieser Signale und keine Fehlermeldung im Log.

**Was ist grade passiert?**

- Du hast soeben die Ampeln `TrafficLight` und die Fahrspuren `Lane` der Kreuzung festgelegt. Jede kann für sich allein geschaltet werden oder zusammen mit anderen Fahrspuren. Die Zusammenfassung in Ampelgruppen und Phasen kommt im nächsten Schritt.

## Schalte die Ampelgruppen nun zu Phasen zusammen

Eine _Phase_ `TrafficPhase` legt fest, welche _Ampelgruppen_ gleichzeitig "grün" bekommen sollen. An einer Kreuzung ist immer nur eine Phase aktiv.

Das macht die Automatik dann für Dich: Bevor eine neue Phase ihre Ampelgruppen auf "grün" schaltet, werden erst alle Signalgeber der vorherigen Phase auf rot geschaltet - wenn sie nicht mehr in der neuen Phase enthalten sind.

❗ _**Beachte**: Eine **Phase** darf **Ampelgruppen** nur so schalten, dass sich die Fahrzeuge der Fahrspuren überlappungsfrei fahren können._

Notiere Dir nun, welche der _Ampelgruppen_ zu _Phasen_ zusammengefasst werden sollen.

![BILD](../../assets/tutorial/kreuzung/kreuzungsaufbau-tutorial-schaltungen.png)

⭐ _**Tipp**: Wichtig ist, das jeder Fahrspur in mindestens einer Phase berücksichtigt wird.
Im Beispiel siehst Du, dass Fahrspuren in mehreren Phasen enthalten sein können.
Es würde jedoch genügen, entweder die Phasen 1 bis 4 oder die Phasen 5 bis 8 zu verwenden, da in diesen jeweils alle Fahrspuren enthalten sind._

## Schreibe die Ampelgruppen und Phasen in das Haupt-Skript

```lua
--------------------------------------------------------------
-- Definiere die Ampelgruppen, Phasen und die Kreuzung
--------------------------------------------------------------
-- Eine Phase bestimmt, welche Fahrspuren gleichzeitig auf
-- grün geschaltet werden dürfen, alle anderen sind rot

k1 = Intersection:new("Tutorial 1")

local sgNorthStraightRight = k1:newSignalGroup("sgNorthStraightRight"):addVehicleSignals(K1)
local sgNorthLeft = k1:newSignalGroup("sgNorthLeft"):addVehicleSignals(K2, K3)
local sgEastStraightRight = k1:newSignalGroup("sgEastStraightRight"):addVehicleSignals(K4)
local sgEastLeft = k1:newSignalGroup("sgEastLeft"):addVehicleSignals(K5, K6)
local sgSouthStraightRight = k1:newSignalGroup("sgSouthStraightRight"):addVehicleSignals(K7)
local sgSouthLeft = k1:newSignalGroup("sgSouthLeft"):addVehicleSignals(K8, K9)
local sgWestStraightRight = k1:newSignalGroup("sgWestStraightRight"):addVehicleSignals(K10)
local sgWestLeft = k1:newSignalGroup("sgWestLeft"):addVehicleSignals(K11, K12)
local sgPedNorth = k1:newSignalGroup("sgPedNorth"):addPedestrianSignals(F1, F2)
local sgPedEast = k1:newSignalGroup("sgPedEast"):addPedestrianSignals(F3, F4)
local sgPedSouth = k1:newSignalGroup("sgPedSouth"):addPedestrianSignals(F7, F8)
local sgPedWest = k1:newSignalGroup("sgPedWest"):addPedestrianSignals(F9, F10)
local sgPedNorthSouth = k1:newSignalGroup("sgPedNorthSouth"):addPedestrianSignals(F5, F6)
local sgPedEastWest = k1:newSignalGroup("sgPedEastWest"):addPedestrianSignals(F11, F12)

--- Tutorial 1: Phase 1
local phase1 = k1:newPhase("P1")
phase1:addSignalGroup(sgNorthStraightRight, sgSouthStraightRight, sgPedNorthSouth, sgPedEastWest)

--- Tutorial 1: Phase 2
local phase2 = k1:newPhase("P2")
phase2:addSignalGroup(sgNorthLeft, sgSouthLeft, sgPedEast, sgPedNorthSouth, sgPedEastWest, sgPedWest)

--- Tutorial 1: Phase 3
local phase3 = k1:newPhase("P3")
phase3:addSignalGroup(sgEastStraightRight, sgWestStraightRight, sgPedNorth, sgPedEast, sgPedSouth, sgPedWest)

--- Tutorial 1: Phase 4
local phase4 = k1:newPhase("P4")
phase4:addSignalGroup(sgEastLeft, sgWestLeft, sgPedNorth, sgPedSouth)

-- k1:setSwitchInStrictOrder(true)
```

- Klicke in EEP auf _"Skript neu laden"_ und wechsle in den 3D-Modus. <br>😀 **Wenn Du alles richtig gemacht hast**, siehst Du plötzlich, dass die Phasen zum Leben erwachen.

  ![BILD](../../assets/tutorial/kreuzung/zum-leben-erweckt.jpg)

**Was ist grade passiert?**

- Du hast soeben die Fahrspuren zu Ampelgruppen und Phasen zusammengefasst und diese einer Kreuzung zugewiesen. Durch die Aufrufe in `EEPMain()` plant die Kreuzung automatisch ihre Phasen, der Planer führt sie aus.

## Schalte die Hilfsfunktionen wieder aus

Erinnerst Du Dich den Code, der die Tipp-Texte zu den Signalen hinzugefügt hat?

- Wenn Du möchtest, kannst Du die Tipp-Texte wieder abschalten. Entferne nicht die Zeilen, sondern setze die Werte von `true` auf `false`.

  ```lua
  -- Hier kommt der Code
  IntersectionSettings.showSignalIdOnSignal = false
  IntersectionSettings.showPhaseOnSignal = false
  ```

- Klicke danach auf Skript neu laden und wechsle in den 3D-Modus.<br>😀 **Wenn Du alles richtig gemacht hast**, verschwinden die Tipp-Texte von den Signalen.

**Tipp**: Setze die Werte wieder auf `true`, wenn Du denkst, dass Du die Signale falsch gesetzt hast.

## Vergleiche Deine Phasen in EEP-Web

![BILD](../../assets/tutorial/kreuzung/eep-web.png)

Funktioniert nicht? [EEP-Web einrichten](../anleitungen-installation/einrichten-von-eep-web)

# Geschafft

Du hast diese Anleitung abgeschlossen 🍀

**So kannst Du weitermachen**:

- Füge noch fehlende Fahrspuren zu Ampelgruppen und Phasen hinzu. Können noch weitere Fußgänger-Ampeln geschaltet werden?

- Reihenfolge der Phasen ändern:

  Nachdem Du die Kreuzung mit `k1 = Intersection:new("Tutorial 1")` angegeben hast, kannst Du entscheiden, ob die Phasen in Reihenfolge ablaufen sollen oder nicht:
  - `k1:setSwitchInStrictOrder(true)` sorgt dafür, dass die Phasen in der Reihenfolge durchgeschaltet werden, in der sie mit `newPhase()` eingeführt wurden.
  - `k1:setSwitchInStrictOrder(false)` sorgt dafür, dass die Priorisierung der Phasen anhand der Wartezeit der einzelnen Fahrspuren und des anliegenden Verkehrs erfolgt.

**Tipps**:

- [Ampeln aufstellen](Ampel-aufstellen)

**Weitere Themen**:

- Füge Kontaktpunkte und Zähler hinzu
- Füge Fahrspuren hinzu, die nur auf Anforderung geschaltet werden
