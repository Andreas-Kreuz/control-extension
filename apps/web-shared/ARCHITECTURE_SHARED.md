# Gemeinsames Datenmodell — web-shared

Dieses Dokument beschreibt die Rolle von `apps/web-shared` in der Control Extension Architektur.
Für die übergreifende Architektur aller Bausteine siehe [ARCHITECTURE.md](../../project-docs/ARCHITECTURE.md).

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
src/dtos/app/          *AppDto-Interfaces — stabiler Vertrag zwischen Server und Web App
src/rooms/             stabile App-Räume und dynamische CeTypeRoom-Unterstützung
```

Diese `*AppDto`-Typen sind der **stabile Client-Vertrag**: Der Server befüllt sie über Selectors
aus internen `*LuaDto`-Typen; die Web App empfängt sie über Socket.IO oder REST.

Lua-interne Änderungen (neue Felder, umbenannte Schlüssel) werden durch die Server-Selectors
abgefangen — der `*AppDto`-Vertrag und die wenigen App-`DomainRoom`s in `web-shared` bleiben davon
entkoppelt und damit stabil. Rohe Lua-`ceType`-Daten werden nur über `CeTypeRoom` im generischen
Daten-Explorer verwendet.

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

Wenn sich ein exportierter App-Room, ein `keyId` oder `*AppDto`-Felder ändern, müssen
Server und Web App gemeinsam geprüft und synchron gehalten werden.

Lua-seitige Änderungen an DtoFactories erfordern keine Anpassung in `web-shared`,
solange der Selector die Transformation korrekt abbildet.
