---
layout: page_with_toc
title: Demo-Anlage öffnen
subtitle: Starte den Server, öffne die Web App auf einem zweiten Gerät und teste die Control Extension mit einer Demo-Anlage.
type: Anleitung
img: '/assets/thumbnails/eep-web-startseite.png'
date: 2026-04-11
permalink: docs/anleitungen-installation/use-demo
tags: [Installation]
published: true
---

# Demo-Anlage nutzen

## Überblick

Diese Anleitung setzt voraus, dass due die Bibliothek schon installiert hast. Falls nicht, führe zuerst die Anleitung [Download und Installation](../anleitungen-installation/installation) aus.

1. Du startest den Server in deinem EEP-Verzeichnis
2. Du öffnest die App in deinem Browser oder besser auf deinem Mobiltelefon oder zweitem Rechner
3. Du öffnest die Demo-Anlage und erkundest die App

## 1. Server starten

1. Starte `control-extension-server.exe` aus dem Installationsverzeichnis `LUA\ce`.

   Beispiel: `C:\Trend\EEP18\LUA\ce\control-extension-server.exe`

2. Prüfe im Server-Fenster, ob das richtige EEP-Verzeichnis ausgewählt ist.

3. Lasse den Server geöffnet, während Du die nächsten Schritte ausführst.

## 2. Web App auf dem Mobiltelefon öffnen

Scanne den Code im Control Extension Server oder rufe die Adresse des Rechners auf, auf dem der Server läuft.

Beispiel: `http://192.168.0.99:3000`

## 3. Demo-Anlage öffnen

1. Starte EEP

2. Öffne eine Demo-Anlage aus dem `ce`-Verzeichnis unter `Ressourcen/Anlagen/ce`

## 4. In den 3D-Modus schalten

1. Wechsle in EEP in den 3D-Modus.

2. Erst im 3D-Modus werden die Anlagendaten in die Data Bridge geschrieben und vom Server bereitgestellt.

3. Nach kurzer Zeit solltest Du die ersten Daten in der Web App auf Deinem Mobiltelefon sehen.

:bulb: **Tipp:** So lange die 3D Simulation läuft, werden die Daten von EEP an den Server gesendet.
Die Datenaktualisierung wird pausiert, sobald 3D Simulation von EEP gestoppt wird.

:bulb: **Tipp:** Wenn du denselben Rechner für EEP und die App nutzt, dann lege dir Browser-Fenster mit der App neben EEP.

## Nächster Schritt

Wenn Du die Control Extension nicht nur mit einer Demo-Anlage, sondern in Deiner eigenen Anlage verwenden möchtest, geht es hier weiter:

- [Control Extension in eigene Anlagen einbinden](../anleitungen-installation/use-own-scenario-01)
