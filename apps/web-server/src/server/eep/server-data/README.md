# json-data Observer

Dieser Observer stellt rohe Lua-`ceType`-Daten für den generischen Explorer bereit.
Stabile Web-App-Features verwenden eigene `DomainRoom`s mit `*AppDto`-Formen.

ℹ Je nach geladenem Lua-Modul gibt es mehr oder weniger Einträge.

## Bereitgestellte Daten

- **`/server.api-entries`** enthält alle bekannten rohen `ceType`-API-Einträge.
  Dies ist ein zusätzlicher Knoten, der vom Server erzeugt wird und eine Übersicht über die API-Einträge enthält.

- **`/xxx`** enthält für den generischen Explorer zusätzlich rohe von EEP eingesammelte Einträge,
  z.B. `ce.hub.Structure` oder `ce.hub.Signal`. Der Inhalt hängt vom geladenen Lua-Modul ab.

- App-Features wie Status, ÖPNV, Straße und Züge verwenden keine App-API-Namen in dieser REST-Sicht,
  sondern stabile `DomainRoom`s mit `*AppDto`-Payloads.

- Der öffentliche Lua-Vertrag für diese CeTypes ist aktuell in den bereichsspezifischen Dateien `lua/LUA/ce/hub/data/**/*DtoTypes.d.lua` und `lua/LUA/ce/hub/data/**/*DtoTypes.d.md` dokumentiert.
  Diese Dateien werden vom Server derzeit noch nicht zur Laufzeit eingelesen, sind aber die Soll-Quelle für CeType-Namen, `keyId` und DTO-Formen.

### Zugriff über API

Die API wird auf dem Webserver unter `/api/v1/` bereitgestellt.

**Bitte beachten:** Die API ist noch nicht versioniert. Auch bei Änderungen wird hier `v1` angezeigt.

### Zugriff über socket.io

Der Zugriff über socket.io kann durch die Registrierung an den Datenräumen erfolgen. Bei jedem Update werden die Daten automatisch an diese Räume gesendet.

Um über Änderungen an Daten informiert zu werden, kann man sich an dem jeweiligen Raum **`[Data 'xxx']`** anmelden:

```typescript
// Raum betreten - für Daten vom Typ xxx
socket.emit('[Room] Join', { "[Data 'xxx']" });

// Raum verlassen - für Daten vom Typ xxx
socket.emit('[Room] Leave', { "[Data 'xxx']" });
```
