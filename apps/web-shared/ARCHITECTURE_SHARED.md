# Gemeinsames Datenmodell — web-shared

Dieses Dokument beschreibt die Rolle von `apps/web-shared` in der Control Extension Architektur.
Für die übergreifende Architektur aller Bausteine siehe [ARCHITECTURE.md](../../ARCHITECTURE.md).

## Zweck

`apps/web-shared` enthält alle TypeScript-Typen und Event-Definitionen, die sowohl der Server
(`apps/web-server`) als auch die Web App (`apps/web-app`) verwenden.

**Kernprinzip:** Datenmodelle, die von Server und Web App gleichermaßen benötigt werden, werden
einmalig in `web-shared` definiert. Dadurch entfällt eine Doppelimplementierung auf beiden Seiten,
und Änderungen am gemeinsamen Modell wirken sich automatisch auf beide Konsumenten aus.

---

## Inhalte

### DTOs (Data Transfer Objects)

```text
src/dtos/server/       *Dto-Interfaces — stabiler Vertrag zwischen Server und Web App
```

Diese `*Dto`-Typen sind der **stabile Client-Vertrag**: Der Server befüllt sie über Selectors
aus internen LuaDtos; die Web App empfängt sie über Socket.IO oder REST.

Lua-interne Änderungen (neue Felder, umbenannte Schlüssel) werden durch die Server-Selectors
abgefangen — der `*Dto`-Vertrag in `web-shared` bleibt davon entkoppelt und damit stabil.

### Events und Räume

```text
src/rooms/             Event-Definitionen (Socket.IO-Räume, keyIds, Ereignistypen)
src/data/model/        Gemeinsame Datenmodelle (z.B. Enums, Hilfswerte)
```

---

## Abhängigkeitsregel

```text
apps/web-server  --nutzt-->  apps/web-shared  <--nutzt--  apps/web-app
```

`web-shared` selbst hat keine Abhängigkeit zu Server oder Web App.
Es ist eine reine Typen- und Vertragsbibliothek ohne Laufzeitlogik.

---

## Änderungsregel

Wenn sich ein exportierter Raum, ein `keyId` oder DTO-Felder ändern, müssen
Server und Web App gemeinsam geprüft und synchron gehalten werden.

Lua-seitige Änderungen an DtoFactories erfordern keine Anpassung in `web-shared`,
solange der Selector die Transformation korrekt abbildet.
