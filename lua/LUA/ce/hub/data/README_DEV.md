---
layout: page_with_toc
title: Hub-Daten — Entwickler
subtitle: Wie DTOs aufgebaut werden und warum die Struktur wichtig ist
permalink: lua/ce/hub/data/dev/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Hub-Daten — Entwickler

## Warum DTOs?

Der Server bekommt die Daten 1:1 so, wie die Lua-Seite sie aufbereitet.
Ein einheitliches Format sorgt dafür, dass Server und Web App dieselbe Struktur erwarten können, unabhängig davon, welche EEP-Daten gerade gemeldet werden.

## DTO-Konvention: CeTypes und Listen

Alle Daten werden in eine dreistufige Map-Struktur einsortiert:

```text
ceType : string
  └─ dtoId : string | number
       └─ dto : table
```

- `ceType` ist die stabile Typkennung des Datenbereichs, z.B. `"ce.hub.TrainStatic"` oder `"ce.hub.Signal"`.
- `dtoId` ist ein eindeutiger Schlüssel innerhalb des CeTypes, z.B. der Zugname oder die Signal-ID.
- `dto` ist eine flache Tabelle mit serialisierbaren Werten — keine Funktionen, keine gemischten Schlüsseltypen.

## Ablauf: Wie kommt ein DTO auf den Bus?

1. Ein `*DataCollector` liest den aktuellen Zustand aus EEP oder einer Registry.
2. Eine `*DtoFactory` wandelt den Zustand in ein DTO um.
3. Das DTO wird unter dem richtigen `ceType` und der richtigen `dtoId` einsortiert.
4. Der zugehörige `*StatePublisher` veröffentlicht Änderungen über `DataChangeBus.fire*()`.

## Vollständige DTO-Strukturen

Alle CeTypes und ihre DTO-Felder sind in [DTO.md](DTO.md) dokumentiert.

---

Informationen für Anwender: [README.md](README.md)
