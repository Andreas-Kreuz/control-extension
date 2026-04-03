<div style="background:#fff3cd; border:1px solid #ffec99; padding: 0.5rem 1rem; margin:16px 0; color:#664d03;">
  <strong>Achtung:</strong> Dieses Projekt befindet sich im Aufbau und die Struktur ändert sich noch sehr stark. Von einem produktiven Einsatz wird abgeraten.
</div>

<p align="center">
  <a href="https://andreas-kreuz.github.io/control-extension">
    <img src="pages/assets/img/ce-logo-72@2x.png" alt="" width=72 height=72>
  </a>

  <h3 align="center">Control Extension für EEP</h3>

  <p align="center">
    Eine modulare Steuerungserweiterung für EEP mit<br> 
    <b>Lua Hub</b> | <b>Data Bridge</b> | <b>Web App</b>
    <br>
    <br>
    <a href="https://andreas-kreuz.github.io/control-extension"><strong>Anleitungen und Dokumentation</strong></a>
  </p>
</p>
<br>
<hr>

# Überblick

Die Control Extension für EEP erweitert EEP um einen strukturierten Laufzeitkern für Lua-Module. Damit kannst Du Anlagenlogik in wiederverwendbare Module aufteilen und bei Bedarf Daten und Steuerfunktionen über zusätzliche Werkzeuge nach außen bereitstellen.

Das Paket besteht aus vier Bausteinen:

1. **Lua Hub** in `ce.hub` als Laufzeitkern für registrierte `CeModule`
2. **Data Bridge _(optional)_** in `ce.databridge` für den Datenaustausch mit externen Werkzeugen
3. **Control Extension Server _(optional)_** zur Aufbereitung und Bereitstellung der Daten
4. **Control Extension Web App _(optional)_** als Browser-Oberfläche für Anzeige und Bedienung

## Grundprinzipien

- Für die Anlagensteuerung genügt die Lua-Seite der Control Extension; Server und Web App sind optional.
- Der öffentliche Einstiegspunkt in EEP ist `ce.ControlExtension`.
- Zusätzliche Werkzeuge bauen auf den Daten der Data Bridge auf und sind nicht Voraussetzung für die Lua-Module.

## Ausführliche Dokumentation

- Die Webseite enthält [Anleitungen und Dokumentation](https://andreas-kreuz.github.io/control-extension/lua/LUA/ce/) zur Verwendung der Control Extension für EEP.
- [Architektur und Designprinzipien](project-docs/ARCHITECTURE.md) der Control Extension.

## Beiträge sind Willkommen

- [Fehler gefunden, Verbesserungsvorschläge?](CONTRIBUTING.md) <br>So kannst Du zum Projekt beitragen

- So kannst Du die [Entwicklungsumgebung einrichten](pages/docs/_anleitungen-entwickler/Aufbau_des_Projektes.md)

## Was ist EEP

EEP (Eisenbahn.exe Professional) ist eine [Simulationssoftware des Trendverlags](https://trendverlag.com/was-ist-eep-eisenbahn-exe.html). Seit Version 11 wird eine Integration von Lua angeboten.

## Danke

- [FrankBuchholz](https://github.com/FrankBuchholz)
  für Performance-Optimierungen und kleine Verbesserungen
- [Damian-Rutkowski](https://github.com/Damian-Rutkowski)
  für die Langzeitmotivation
- [EEP-Benny](https://github.com/EEP-Benny)
  für Ideen zur Umsetzung und Modularisierung

## Danksagungen an andere Projekte

Teile der Webseite basieren auf folgenden anderen Projekten:

- Inhaltsverzeichnis: <https://github.com/allejo/jekyll-toc>
- Layout: <https://github.com/Sylhare/Type-on-Strap>
- Layout: <https://github.com/twbs/bootstrap>
- Javascript: <https://github.com/FezVrasta/popper.js>
