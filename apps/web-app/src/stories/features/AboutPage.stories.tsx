import type { Meta, StoryObj } from '@storybook/react';
import { AboutPageContent } from '../../features/about/components/AboutPage';

const changelog004 = `### Neu

- ⭐ Haltestellenanzeige für Linien
- ⭐ Neue Seite mit Einblicken in die App

### Dokumentation

- 📖 Neue App Ansicht auf der Dokumentationsseite

## Installationspakete (siehe Assests)
- **\`control-extension-for-eep-0.0.4-installer.zip\`** – Haupt-Installationspaket der Control Extension für EEP. Enthält Server, Lua-Hub, Data Bridge und Web-App. - Wird benötigt.
- \`ak-compat-layer-for-control-extension-0.0.4-installer.zip\` – Kompatibilitätsschicht für bestehende Anlagen, die auf der Lua-Bibliothek von Andreas Kreuz basieren - nur installieren, wenn du weißt, was du tust.

Weitere Informationen und Dokumentation: https://andreas-kreuz.github.io/control-extension/`;

const changelog005 = `## **Control Extension v0.0.5** Vorschauversion

## Neu

- ⭐ Anzeige nächster Halte pro Fahrzeug
- ⭐ Filter für Fahrzeuge mit Linieninformationen
- ⭐ Neue Tooltips für Ampeln, die nur den Kurznamen und die Schaltung anzeigen

## Bugfixes

- 🐞 Installer enthält keine doppelten Dateien mehr


## Installationspakete (siehe Assests)
- **\`control-extension-0.0.5.zip\`** – Haupt-Installationspaket der Control Extension für EEP. Enthält Server, Lua-Hub, Data Bridge und Web-App. - Wird benötigt.
- \`control-extension-0.0.5-ak-compat.zip\` – Kompatibilitätsschicht für bestehende Anlagen, die auf der Lua-Bibliothek von Andreas Kreuz basieren - nur installieren, wenn du weißt, was du tust.

Weitere Informationen und Dokumentation: https://andreas-kreuz.github.io/control-extension/`;

const meta = {
  title: 'Features/About/AboutPage',
  component: AboutPageContent,
} satisfies Meta<typeof AboutPageContent>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Version005GitHubUpdate: Story = {
  args: {
    updateStatus: {
      state: 'prerelease-available',
      currentVersion: '0.0.4',
      checkedAt: '2026-04-21T14:54:46Z',
      currentRelease: {
        version: '0.0.4',
        name: 'v0.0.4-alpha',
        url: 'https://github.com/Andreas-Kreuz/control-extension/releases/tag/v0.0.4',
        prerelease: true,
        publishedAt: '2026-04-19T14:19:00Z',
        changelog: changelog004,
      },
      availableRelease: {
        version: '0.0.5',
        name: 'v0.0.5-alpha',
        url: 'https://github.com/Andreas-Kreuz/control-extension/releases/tag/v0.0.5',
        downloadUrl: 'https://github.com/Andreas-Kreuz/control-extension/releases/download/v0.0.5/control-extension-0.0.5.zip',
        prerelease: true,
        publishedAt: '2026-04-21T14:54:46Z',
        changelog: changelog005,
      },
      availablePrereleaseRelease: {
        version: '0.0.5',
        name: 'v0.0.5-alpha',
        url: 'https://github.com/Andreas-Kreuz/control-extension/releases/tag/v0.0.5',
        downloadUrl: 'https://github.com/Andreas-Kreuz/control-extension/releases/download/v0.0.5/control-extension-0.0.5.zip',
        prerelease: true,
        publishedAt: '2026-04-21T14:54:46Z',
        changelog: changelog005,
      },
      latestPrereleaseRelease: {
        version: '0.0.5',
        name: 'v0.0.5-alpha',
        url: 'https://github.com/Andreas-Kreuz/control-extension/releases/tag/v0.0.5',
        downloadUrl: 'https://github.com/Andreas-Kreuz/control-extension/releases/download/v0.0.5/control-extension-0.0.5.zip',
        prerelease: true,
        publishedAt: '2026-04-21T14:54:46Z',
        changelog: changelog005,
      },
    },
  },
};

export const NoUpdateAvailable: Story = {
  args: {
    updateStatus: {
      state: 'current',
      currentVersion: '0.0.5',
      checkedAt: '2026-04-21T14:54:46Z',
      currentRelease: {
        version: '0.0.5',
        name: 'v0.0.5-alpha',
        url: 'https://github.com/Andreas-Kreuz/control-extension/releases/tag/v0.0.5',
        downloadUrl: 'https://github.com/Andreas-Kreuz/control-extension/releases/download/v0.0.5/control-extension-0.0.5.zip',
        prerelease: true,
        publishedAt: '2026-04-21T14:54:46Z',
        changelog: changelog005,
      },
      latestPrereleaseRelease: {
        version: '0.0.5',
        name: 'v0.0.5-alpha',
        url: 'https://github.com/Andreas-Kreuz/control-extension/releases/tag/v0.0.5',
        downloadUrl: 'https://github.com/Andreas-Kreuz/control-extension/releases/download/v0.0.5/control-extension-0.0.5.zip',
        prerelease: true,
        publishedAt: '2026-04-21T14:54:46Z',
        changelog: changelog005,
      },
    },
  },
};

export const VersionInfoFallback: Story = {
  args: {
    installedAppVersion: '0.0.6',
    updateStatus: {
      state: 'unknown',
      currentVersion: '?',
    },
  },
};
