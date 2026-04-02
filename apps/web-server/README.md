<p align="center">
  <img src="/docs/assets/img/ce-logo-72@2x.png" alt="" width=72 height=72>
  <h3 align="center">Control Extension Server</h3>
  <p align="center">
    Anwendungsserver der Control Extension für EEP.
  </p>
</p>
<br>
<hr>

# Verwendung

Dieses Projekt enthält den optionalen Server der Control Extension für EEP.

Mehr Informationen zur Control Extension für EEP:
<https://github.com/Andreas-Kreuz/control-extension>

## Wichtige Skripte

- `yarn workspace @ak/web-server run lint`
  Prüft den TypeScript-Code des Servers mit ESLint.

- `yarn workspace @ak/web-server run run:headless`
  Startet den Server ohne Electron-Oberfläche im Headless-Modus.

## Pairing und Zugriff

Im regulären Betrieb gelten für Web-Clients folgende Regeln:

- Beim ersten Start ist die Einstellung `Andere Geräte erst freigeben (empfohlen)` standardmäßig aktiviert.
- Greift ein Web-Client vom Server-Rechner selbst auf den Server zu, ist keine Freigabe erforderlich. Das gilt auch für Zugriffe über dieselbe Geräteadresse oder dieselbe Server-IP. In diesem Fall ist auch `/server` verfügbar.
- Greift ein Web-Client von einem anderen Rechner auf den Server zu, gilt die Einstellung für andere Geräte:
  - aktiviert: Andere Geräte können erst nach Freigabe zugreifen.
  - deaktiviert: Alle Geräte im Netzwerk dürfen auf den Server zugreifen.
- Für Zugriffe von anderen Rechnern ist `/server` niemals verfügbar, unabhängig davon, ob andere Geräte erst freigegeben werden müssen oder nicht.

Hinweis:
Die Regeln oben beschreiben den normalen Betrieb. Explizite Entwicklungs- und Testpfade wie `--testmode` sind davon ausgenommen.
