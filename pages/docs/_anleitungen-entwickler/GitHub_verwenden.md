---
layout: page_with_toc
title: GitHub verwenden
type: Anleitung
subtitle: Hier erfährst Du, wie Du die Control Extension direkt aus GitHub holst und lokal startest.
img: '/assets/thumbnails/GitHub.png'
feature-img: '/assets/headers/GitHub.png'
date: 2017-09-03
permalink: docs/anleitungen-entwickler/github-verwenden
tags: [Fortgeschrittene, Entwickler]
published: false
---

# Control Extension aus GitHub nutzen

Wenn Du die Control Extension direkt aus GitHub holen und ausprobieren willst, bist Du hier richtig.

⭐ Wenn Dir Git und die Kommandozeile noch nicht so vertraut sind, ist das kein Problem. Du kannst fast alles Schritt für Schritt machen.

## 1. Control Extension mit GitHub Desktop klonen

- Lade Dir zuerst das Programm [GitHub Desktop](https://desktop.github.com/) herunter und installiere es.

- Öffne GitHub Desktop.

- Klicke oben auf _File_ → _Clone repository_.

- Wähle das Projekt [Andreas-Kreuz/control-extension](https://github.com/Andreas-Kreuz/control-extension) aus.

- Als lokales Verzeichnis verwendest Du am besten `C:\GitHub\control-extension`.

- Du kannst das Projekt direkt herunterladen.

## 2. Control Extension lokal starten

Nach dem Herunterladen kannst Du die Control Extension inklusive Web-Server und Web-App direkt lokal starten.

Öffne dazu ein Terminal oder eine Konsole im Ordner `C:\GitHub\control-extension`.

Wenn Du nicht weißt, wie das geht, ist PowerShell ein guter Start:

- Öffne den Ordner `C:\GitHub\control-extension` im Explorer.
- Klicke in die Adresszeile.
- Tippe `powershell` ein und drücke `<Enter>`.

Führe danach diese Befehle nacheinander aus:

```bash
corepack enable
yarn install
yarn tools:check
yarn dev:app
```

Wenn `yarn` in PowerShell nicht funktioniert, probiere stattdessen einfach `yarn.cmd`.

Wenn alles passt, startet der Web-Server im Hintergrund und die Web-App läuft meistens unter <http://localhost:5173/>.

## 3. Optional: direkt in EEP verwenden

Für die lokale Web-App brauchst Du diesen Schritt nicht zwingend.

Praktisch ist er trotzdem, wenn EEP immer direkt mit Deinem Git-Ordner arbeiten soll. Dann musst Du nach Änderungen nichts von Hand kopieren.

Wichtig: Das Repository sollte dafür auf derselben Festplatte liegen wie Deine EEP-Installation, also zum Beispiel in `C:\GitHub\control-extension`.

Starte dafür die Eingabeaufforderung als Administrator:

- Drücke die `<Windows>`-Taste.
- Tippe `cmd` ein.
- Mache einen Rechtsklick auf `Eingabeaufforderung`.
- Klicke auf _Als Administrator ausführen_.

Gib dann diesen Befehl ein. Damit wird der Ordner `ce` aus Deinem Git-Ordner direkt mit EEP verbunden:

```powershell
mklink /D C:\Trend\EEP18\LUA\ce C:\GitHub\control-extension\lua\LUA\ce\
```

Danach ist die Control Extension in EEP direkt unter `ce` verfügbar.

Wenn Du das gleich ausprobieren willst, kannst Du danach eine Demo-Anlage aus `C:\GitHub\control-extension\lua\Resourcen\Anlagen\` öffnen. Wenn alles geklappt hat, läuft die automatische Steuerung der Demo-Anlage wie erwartet.

## Noch mehr Infos

Wenn Du später tiefer einsteigen willst, findest Du in [Aufbau des Projektes](aufbau-des-projektes) weitere Kommandos, Werkzeuge und typische Arbeitsabläufe.
