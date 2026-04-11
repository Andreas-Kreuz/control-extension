# Plan fuer `ce`-Unterverzeichnisse in der EEP-Installation

Dieses Dokument beschreibt, wie die Installation der Control Extension so vereinheitlicht werden soll, dass alle von der Installationsdatei erzeugten Inhalte in `ce`-Unterverzeichnissen der jeweiligen EEP-Installation liegen.

Ziel ist eine einfache manuelle Deinstallation und ein sauberes Update ohne liegengebliebene Altdateien.

## Ausgangslage laut `ModellInstallation.lua`

Die Installationsdatei erzeugt aktuell diese Zielpfade:

- `LUA\ce`
- `LUA\ce\demo-anlagen\ampel`
- `LUA\ce\demo-anlagen\demo-linien`
- `LUA\ce\demo-anlagen\testen`
- `LUA\ce\demo-anlagen\tutorial-ampel`
- `Resourcen\Anlagen\Andreas_Kreuz-Demo-Ampel`
- `Resourcen\Anlagen\Andreas_Kreuz-Demo-Linien`
- `Resourcen\Anlagen\Andreas_Kreuz-Demo-Testen`
- `Resourcen\Anlagen\Andreas_Kreuz-Tutorial-Ampelkreuzung`

Damit liegt der Lua-Teil bereits unter `ce`, die installierten Anlagenverzeichnisse jedoch noch nicht.

## Zielbild

Alle durch den Installer erzeugten Daten sollen nur noch in `ce`-Unterverzeichnissen liegen:

- `LUA\ce`
- `Resourcen\Anlagen\ce`

Empfohlene Zielstruktur:

- `LUA\ce`
- `LUA\ce\demo-anlagen\ampel`
- `LUA\ce\demo-anlagen\demo-linien`
- `LUA\ce\demo-anlagen\testen`
- `LUA\ce\demo-anlagen\tutorial-ampel`
- `Resourcen\Anlagen\ce\Control_Extension-Demo-Ampel`
- `Resourcen\Anlagen\ce\Control_Extension-Demo-Linien`
- `Resourcen\Anlagen\ce\Control_Extension-Demo-Testen`
- `Resourcen\Anlagen\ce\Control_Extension-Tutorial-Ampelkreuzung`

Damit reichen fuer eine manuelle Entfernung im Regelfall diese beiden Verzeichnisse:

- `LUA\ce`
- `Resourcen\Anlagen\ce`

## Umsetzungsplan

### 1. Installer-Zielpfade auf `ce`-Unterverzeichnisse umstellen

In `lua/LUA/ModellInstallation.lua` sollen alle Demo-Anlagen unter `Resourcen\Anlagen\ce\...` statt direkt unter `Resourcen\Anlagen\...` installiert werden.

Konkret betrifft das:

- `Control_Extension-Demo-Ampel`
- `Control_Extension-Demo-Linien`
- `Control_Extension-Demo-Testen`
- `Control_Extension-Tutorial-Ampelkreuzung`

### 2. Paketbeschreibung auf das neue Zielbild abstimmen

Die Pakettexte und die Anwenderdokumentation sollten klar sagen:

- Lua-Dateien liegen unter `LUA\ce`
- Beispielanlagen liegen unter `Resourcen\Anlagen\ce`
- fuer Updates koennen die `ce`-Unterverzeichnisse vorab geloescht werden

### 3. Bestehende Altpfade dokumentieren

Da fruehere Installer noch nach `Resourcen\Anlagen\Andreas_Kreuz-*` installiert haben, muss die Deinstallationsanleitung diese Altpfade explizit nennen.

Ohne diesen Hinweis blieben bei bestehenden Installationen Demo-Anlagen ausserhalb von `ce` liegen.

### 4. Update-Ablauf vereinfachen

Empfohlener Ablauf vor einer Neuinstallation:

1. EEP und den optionalen Control-Extension-Server beenden.
2. `LUA\ce` loeschen.
3. `Resourcen\Anlagen\ce` loeschen.
4. Bei alten Installationen zusaetzlich die bisherigen Demo-Anlagen unter `Resourcen\Anlagen\Andreas_Kreuz-*` pruefen und entfernen.
5. Neue Installationsdatei ausfuehren.

So wird sichergestellt, dass keine alten Dateien aus frueheren Versionen erhalten bleiben.

## Offene Punkte vor der Umstellung

- Pruefen, ob EEP oder bestehende Dokumentation feste Pfade ohne `ce` erwarten.
- Pruefen, ob Demo-Anlagen interne Verweise auf ihre Anlagenordner enthalten, die an den neuen Zielpfad angepasst werden muessen.
- Pruefen, ob die erzeugten Modellpakete oder ihre Anzeigenamen einen Hinweis auf den neuen Anlagenpfad enthalten sollen.

## Akzeptanzkriterien

Die Umstellung ist erfolgreich, wenn diese Punkte erfuellt sind:

- Alle neu installierten Dateien liegen nur noch unter `LUA\ce` oder `Resourcen\Anlagen\ce`.
- Eine manuelle Deinstallation ist durch Loeschen der `ce`-Unterverzeichnisse moeglich.
- Die Deinstallationsanleitung nennt sowohl das neue Zielbild als auch die zu entfernenden Altpfade aus frueheren Installationen.
- Vor einem Update kann der Nutzer die `ce`-Unterverzeichnisse entfernen, ohne weitere einzelne Dateien zusammensuchen zu muessen.
