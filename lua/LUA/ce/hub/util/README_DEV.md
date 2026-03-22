---
layout: page_with_toc
title: Util — Entwickler
subtitle: Interner Aufbau und Design-Entscheidungen des util-Pakets
permalink: lua/ce/hub/util/dev/
feature-img: "/docs/assets/headers/SourceCode.png"
img: "/docs/assets/headers/SourceCode.png"
---

# Util — Entwickler

## Zweck

Das `util`-Paket enthält generische Hilfsfunktionen, die keine Fachdomäne kennen.
Es darf von beliebigen Paketen der Bibliothek genutzt werden.

## StorageUtility

`StorageUtility.lua` kapselt das Lesen und Schreiben von EEP-Datenslots und Rollingstock-Tags.

### Internes Format

Daten werden als kommaseparierter String im Format `key=value,` gespeichert.

Daher gelten diese Einschränkungen:

- Schlüssel und Werte dürfen keine Kommata enthalten.
- Zahlen und Boolean-Werte müssen mit `tostring(...)` serialisiert und nach dem Laden mit `tonumber(...)` bzw. `StorageUtility.toboolean(...)` zurückgewandelt werden.
- Für `EEPSaveData` begrenzt `StorageUtility` die Länge auf 999 Zeichen.
- Für Rollingstock-Tags liegt die Grenze bei 1024 Zeichen.

### ID-Konflikt-Erkennung

`StorageUtility.registerId(eepSaveId, name)` reserviert einen Slot und löst absichtlich einen Fehler aus, wenn dieselbe ID doppelt belegt wird.
Das verhindert stille Datenverluste durch Konflikte zwischen Paketen.

## Design-Entscheidung

`util` ist generisch und kennt keine Fachdomäne.
Neue Hilfsfunktionen kommen nur dann hierher, wenn sie von mindestens zwei unabhängigen Paketen genutzt werden und keinen fachlichen Zustand enthalten.

---

Informationen für Anwender: [README.md](README.md)
