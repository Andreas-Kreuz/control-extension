# Server-Architektur der Control Extension

Dieses Dokument beschreibt die Architektur des Control Extension Servers.
Für die übergreifende Architektur aller Bausteine siehe [ARCHITECTURE.md](../../ARCHITECTURE.md).

## Rolle des Servers

Der Server ist Baustein 3 der Control Extension. Er setzt die Data Bridge (Baustein 2) voraus,
ist aber unabhängig von der Web App (Baustein 4).

**Unabhängigkeit von der Web App:** Der Server stellt REST-API und Socket.IO-Events bereit,
auch wenn keine Web App verbunden ist. Nutzende können die API direkt konsumieren oder
Socket.IO-Events in eigene Anwendungen integrieren.

---

## Datenfluss im Server

```text
Data Bridge
    | events-from-ce (newline-delimited JSON, Kodierung: latin1)
    v
LuaDto-Empfang
    | Parsing + Typisierung
    v
*LuaDto   [src/server/ce/dto/]          server-intern, nie direkt an Clients
    |
    | Selector.ts (Transformation / Stabilitätsschicht)
    v
*Dto      [apps/web-shared/src/dtos/]   stabiler Client-Vertrag
    |
    | Socket.IO-Events / REST-API
    v
Konsumenten (Web App, externe Clients)
```

---

## LuaDtos — Server-interne Verträge

Die LuaDtos in `src/server/ce/dto/` sind die TypeScript-Entsprechungen der Lua-DtoFactories.
Sie sind **ausschließlich server-intern** und werden nie direkt an Clients weitergegeben.

Jede LuaDto-Datei enthält einen Querverweis auf die zugehörige Lua-DtoFactory:

```typescript
// Lua DtoFactory: lua/LUA/ce/hub/data/trains/TrainDtoFactory.lua
export interface TrainLuaDto { ... }
```

Für das vollständige Verzeichnis aller LuaDtos und deren Lua-Entsprechungen
siehe [`src/server/ce/dto/README.md`](src/server/ce/dto/README.md).

---

## Selectors — Stabilitätsschicht

Selectors sind die **einzige Brücke** zwischen LuaDto und dem Client-Vertrag (`*Dto` in `web-shared`).

Ändert sich das Lua-Ausgabeformat, wird nur der Selector angepasst — der Client-Vertrag
in `apps/web-shared` bleibt stabil. Die Web App muss nicht bei jeder Lua-Änderung
angepasst werden.

---

## Tailoring — Daten für Konsumenten anpassen

Tailoring bezeichnet die Reduktion und Filterung von Daten für Clients, die auf Serverseite
stattfindet. Ziele:

- Datenverkehr zwischen Server und Clients minimieren.
- Update-Ereignisse für die Web App reduzieren, damit Client-Updates minimal bleiben.
- Clients können sich auf einen Teilbereich der Daten registrieren.

**Regel:** Tailoring darf die reine Lua-API (`LuaDto`) nicht verändern oder kompromittieren.
LuaDtos bleiben unverändert; die Transformation findet ausschließlich im Selector statt.

---

## Befehlsweiterleitung an EEP

Der Server nimmt Befehle von der Web App über Socket.IO entgegen und schreibt sie in die
Datei `commands-to-ce`, aus der die Lua-seitige Data Bridge liest.

```text
Web App  --Socket.IO CommandEvent-->  registerCommandMod.ts
                                             |
                                      eepService.queueCommand()
                                             |
                                      commands-to-ce  (Datei)
                                             |
                                      Data Bridge (Lua)
```

Der Server ist dabei **eine Quelle unter mehreren** — `commands-to-ce` ist ein allgemeiner
Eingangskanal, in den auch Nutzer oder externe Tools direkt schreiben können.

---

## Bereitgestellte Schnittstellen

- **REST-API** — synchroner Datenzugriff (aktueller Zustand)
- **Socket.IO-Events** — asynchrone Benachrichtigungen bei Zustandsänderungen

Beide Schnittstellen sind auch ohne Web App nutzbar.
