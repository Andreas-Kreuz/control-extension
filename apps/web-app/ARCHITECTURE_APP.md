# Web-App-Architektur der Control Extension

Dieses Dokument beschreibt die Architektur der Control Extension Web App.
Für die übergreifende Architektur aller Bausteine siehe [ARCHITECTURE.md](../../project-docs/ARCHITECTURE.md).

## Rolle der Web App

Die Web App ist Baustein 4 der Control Extension. Sie setzt den Server (Baustein 3) voraus
und ist der einzige Baustein ohne eigene Unabhängigkeit — sie ist reiner Konsument.

---

## Datenfluss in der Web App

```text
Control Extension Server
    | Socket.IO-Events / REST-API
    v
*Dto (aus apps/web-shared)         stabiler Eingangsvertrag
    |
    | ggf. lokale Transformation
    v
View Models  [src/.../model/]      view-spezifische Datenstruktur
    |
    v
React-Komponenten                  Anzeige und Bedienung
```

---

## Eingangsvertrag

Die Web App empfängt ausschließlich `*Dto`-Objekte, die in `apps/web-shared` definiert sind.
Dieser Vertrag ist stabil: Lua-interne Änderungen werden durch Server-Selectors abgefangen
und erreichen die Web App nicht direkt.

Für das gemeinsame Datenmodell siehe
[apps/web-shared/ARCHITECTURE_SHARED.md](../web-shared/ARCHITECTURE_SHARED.md).

---

## Lokale Datenhaltung (View Models)

Die Web App kann empfangene DTOs für Views lokal halten, wenn eine weitere Reduktion
oder Umstrukturierung für die Darstellung sinnvoll ist.

- View Models liegen in `src/.../model/`.
- Ziel: minimale Re-Renders und minimaler Speicherbedarf.
- View Models sind nur für die Web App relevant und werden nicht an den Server zurückgemeldet.

---

## Datenhaltungsregel

Die Web App hält Daten lokal nur dann vor, wenn eine view-spezifische Transformation
gegenüber dem empfangenen `*Dto` notwendig ist. Andernfalls werden `*Dto`-Objekte
direkt in den Komponenten verwendet.

---

## Befehle senden

Die Web App kann Befehle an das EEP-Programm senden. Der Rückkanal läuft über den Server.

```text
Web App  --Socket.IO CommandEvent-->  Server  -->  commands-to-ce  -->  EEP (Lua)
```

- Befehle werden als Socket.IO-Events vom Typ `CommandEvent` gesendet.
- Der Server nimmt diese entgegen, reiht sie ein (`queueCommand`) und schreibt sie
  in die Datei `commands-to-ce`.
- Die Lua-seitige Data Bridge liest die Datei und führt erlaubte Befehle aus.
- Die Web App sendet keine Befehle direkt an Lua — der Server ist der einzige Vermittler.
