# Aktualisieren der Control Extension

Diese Anleitung beschreibt das Update der Control Extension.

1. Beenden von EEP und Control Extension Server
2. Löschen der vorhandenen ce-Verzeichnisse aus dem EEP-Verzeichnis
3. Herunterladen
4. Installation des Installationspaketes mit EEP

## 1. Programme beenden

Vor der Aktualisierung bitte diese Programme beenden:

- EEP
- `control-extension-server.exe`, falls der Server läuft

## 2. Alte Version entfernen

Da das Installationspaket nur neue Dateien anlegt, lösche zur Sicherheit die folgenden beiden `ce`-Verzeichnisse aus deiner EEP-Installation, z.B.

- `C:\Trend\EEP17\LUA\ce`
- `C:\Trend\EEP17\Resourcen\Anlagen\ce`

Danach ist die bisherige Control Extension entfernt.

## 3. Herunterladen

Lade die ZIP-Datei aus den GitHub Releases hier herunter [Control Extension ](https://github.com/Andreas-Kreuz/control-extension/releases/latest)

## 4. Installieren

Starte EEP und klicke auf Modell-Installer.
Wähle dann die ZIP-Datei aus.
