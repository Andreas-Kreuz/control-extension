# Manuelle Deinstallation der Control Extension

Diese Anleitung beschreibt die manuelle Deinstallation der Control Extension aus dem EEP-Verzeichnis.

## Vorher beenden

Vor der Deinstallation bitte diese Programme beenden:

- EEP
- `control-extension-server.exe`, falls der Server laeuft

## Standard-Deinstallation

Lösche nun diese beiden `ce`-Verzeichnisse aus deiner EEP-Installation, z.B.

- `C:\Trend\EEP17\LUA\ce`
- `C:\Trend\EEP17\Resourcen\Anlagen\ce`

Danach ist die manuell installierte Control Extension entfernt.

## Zusätzliche Altpfade aus bisherigen Installationen

Falls du Version v0.0.1 installiert hattest wurden in bisherigen Installationspaketen Demo-Anlagen noch direkt unter `Resourcen\Anlagen` angelegt.

Prüfe deshalb zusätzlich, ob diese Verzeichnisse vorhanden sind, und loesche sie bei Bedarf:

- `Resourcen\Anlagen\Andreas_Kreuz-Demo-Ampel`
- `Resourcen\Anlagen\Andreas_Kreuz-Demo-Linien`
- `Resourcen\Anlagen\Andreas_Kreuz-Demo-Testen`
- `Resourcen\Anlagen\Andreas_Kreuz-Tutorial-Ampelkreuzung`

Falls du mit der Control Extension die alte Lua-Bibliothek von Andreas Kreuz ersetzen möchtest, lösche auch das Verzeichnis `ak` im EEP-Ordner, z.B. `C:\Trend\EEP17\LUA\ak`

## Empfohlener Ablauf vor einem Update

Wenn Du die Control Extension aktualisieren willst, ist dieser Ablauf am sichersten:

1. EEP und den optionalen Server beenden.
2. `LUA\ce` loeschen.
3. `Resourcen\Anlagen\ce` loeschen, falls vorhanden.
4. Alte Demo-Anlagen unter `Resourcen\Anlagen\Andreas_Kreuz-*` loeschen, falls sie aus frueheren Installationen stammen.
5. Danach die neue Installationsdatei ausfuehren.

So bleiben keine alten Dateien im EEP-Verzeichnis liegen.
