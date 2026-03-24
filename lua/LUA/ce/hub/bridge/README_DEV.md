---
layout: page_with_toc
title: Bridge-Anbindung — Entwickler
subtitle: Interne Architektur und Design-Entscheidungen der Hub-Bridge-Kopplung
permalink: lua/ce/hub/bridge/dev/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Architektur der Bridge-Anbindung

## Zweck

Der `HubBridgeConnector` registriert die StatePublisher des Hubs an der `StatePublisherRegistry`, damit diese ihre Daten über den `DataChangeBus` bereitstellen.

## Dateien

- `HubBridgeConnector.lua` — verbindet Hub-StatePublisher mit der StatePublisherRegistry

## Design-Entscheidung

Der BridgeConnector trennt Domänenlogik und Web-Export:

- Fachmodule kennen den BridgeConnector nicht.
- Der BridgeConnector kennt die StatePublisher und meldet sie an.
- Dadurch bleibt die Kopplung zwischen Fachlogik und Datenexport minimal.

---

Informationen für Anwender: [README.md](README.md)
