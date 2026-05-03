import CheckCircleOutlineRoundedIcon from '@mui/icons-material/CheckCircleOutlineRounded';
import DownloadRoundedIcon from '@mui/icons-material/DownloadRounded';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import Link from '@mui/material/Link';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import BorderedSimpleCard from '../../../shared/components/cards/BorderedSimpleCard';
import OutlinedCard from '../../../shared/components/cards/OutlinedCard';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import useVersionInfo from '../../statistics/hooks/useVersionInfo';
import useUpdateStatus from '../../update/hooks/useUpdateStatus';
import type { UpdateReleaseAppDto, UpdateStatusAppDto } from '@ce/web-shared';
import type { Components } from 'react-markdown';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';

const markdownComponents: Components = {
  a: ({ children, href }) => (
    <Link href={href} target="_blank" rel="noreferrer">
      {children}
    </Link>
  ),
  code: ({ children }) => (
    <Typography
      component="code"
      variant="body2"
      sx={{ bgcolor: 'action.hover', borderRadius: 0.5, fontFamily: 'monospace', px: 0.5 }}
    >
      {children}
    </Typography>
  ),
  h1: ({ children }) => (
    <Typography variant="h4" sx={{ mt: 2 }}>
      {children}
    </Typography>
  ),
  h2: ({ children }) => (
    <Typography variant="h5" sx={{ mt: 2 }}>
      {children}
    </Typography>
  ),
  h3: ({ children }) => (
    <Typography variant="h6" sx={{ mt: 1.5 }}>
      {children}
    </Typography>
  ),
  li: ({ children }) => (
    <ListItem sx={{ display: 'list-item', py: 0.25 }}>
      <Typography variant="body2">{children}</Typography>
    </ListItem>
  ),
  ol: ({ children }) => (
    <List component="ol" sx={{ listStyleType: 'decimal', pl: 3, py: 0 }}>
      {children}
    </List>
  ),
  p: ({ children }) => (
    <Typography variant="body2" sx={{ my: 1 }}>
      {children}
    </Typography>
  ),
  ul: ({ children }) => (
    <List component="ul" sx={{ listStyleType: 'disc', pl: 3, py: 0 }}>
      {children}
    </List>
  ),
};

function ChangelogText(props: { text?: string }) {
  if (!props.text) {
    return <Typography variant="body2">GitHub enthält für dieses Release keinen Changelog-Text.</Typography>;
  }

  return (
    <ReactMarkdown remarkPlugins={[remarkGfm]} components={markdownComponents}>
      {props.text}
    </ReactMarkdown>
  );
}

function isPrereleaseVersion(version: string): boolean {
  return /-(alpha|beta|rc|preview|pre|dev|\d)/i.test(version);
}

function knownVersion(version: string | undefined): string | undefined {
  return version && version !== '?' ? version : undefined;
}

function AvailableVersionSummary(props: { release: UpdateReleaseAppDto }) {
  const release = props.release;

  return (
    <Stack spacing={1} sx={{ flex: 1, minWidth: 0 }}>
      <Typography variant="subtitle1" color="text.secondary">
        Neue Version verfügbar
      </Typography>
      <Stack direction="row" spacing={1} sx={{ alignItems: 'flex-end', flex: 1, minWidth: 0 }}>
        <Stack direction="row" spacing={1} sx={{ alignItems: 'center', flex: 1, flexWrap: 'wrap', minWidth: 0 }}>
          <Stack sx={{ minWidth: 0 }}>
            <Stack direction="row" spacing={1} sx={{ alignItems: 'center', flexWrap: 'wrap' }}>
              <Typography variant="h6">{release.version}</Typography>
              <Chip size="small" label={release.prerelease ? 'Vorschauversion' : 'Aktuelle Version'} />
            </Stack>
            <Typography variant="body2" color="text.secondary" noWrap>
              {release.name}
            </Typography>
          </Stack>
        </Stack>
        <Button
          aria-label="Installationspaket herunterladen"
          color="success"
          endIcon={<DownloadRoundedIcon />}
          href={release.downloadUrl ?? release.url}
          rel="noreferrer"
          target="_blank"
          variant="contained"
        >
          Download
        </Button>
      </Stack>
    </Stack>
  );
}

export function AboutPageContent(props: { installedAppVersion?: string; updateStatus: UpdateStatusAppDto }) {
  const updateStatus = props.updateStatus;
  const release = updateStatus.availableRelease;
  const previewRelease =
    updateStatus.availablePrereleaseRelease?.version !== release?.version
      ? updateStatus.availablePrereleaseRelease
      : undefined;
  const hasUpdate = updateStatus.state === 'stable-available' || updateStatus.state === 'prerelease-available';
  const currentVersion =
    knownVersion(updateStatus.currentRelease?.version) ??
    knownVersion(updateStatus.currentVersion) ??
    knownVersion(props.installedAppVersion) ??
    '?';
  const currentVersionName =
    updateStatus.currentRelease?.name ??
    (currentVersion !== '?' ? 'Installierte Control Extension Version' : undefined);
  const serverSentCurrentVersionInfo =
    knownVersion(updateStatus.currentRelease?.version) !== undefined ||
    knownVersion(updateStatus.currentVersion) !== undefined;
  const currentVersionIsConfirmed = updateStatus.state === 'current' && serverSentCurrentVersionInfo;
  const currentVersionIsPrerelease =
    updateStatus.currentRelease?.prerelease === true ||
    isPrereleaseVersion(currentVersion) ||
    updateStatus.latestPrereleaseRelease?.version === currentVersion;
  return (
    <PageContainer>
      <PageHeadline>Über diese Version</PageHeadline>
      <Stack spacing={3}>
        <Box
          sx={{
            alignItems: 'stretch',
            display: 'grid',
            gap: 2,
            gridTemplateColumns: '1fr',
          }}
        >
          <BorderedSimpleCard contentSx={{ display: 'flex', height: 1 }}>
            <Stack spacing={1} sx={{ flex: 1, minWidth: 0 }}>
              <Typography variant="subtitle1" color="text.secondary">
                Installierte Version
              </Typography>
              <Stack direction="row" spacing={1} sx={{ alignItems: 'flex-end', flex: 1, minWidth: 0 }}>
                <Stack
                  direction="row"
                  spacing={1}
                  sx={{ alignItems: 'center', flex: 1, flexWrap: 'wrap', minWidth: 0 }}
                >
                  <Stack sx={{ minWidth: 0 }}>
                    <Stack direction="row" spacing={1} sx={{ alignItems: 'center', flexWrap: 'wrap' }}>
                      <Typography variant="h6">{currentVersion}</Typography>
                      {currentVersionIsPrerelease && <Chip size="small" label="Vorschauversion" />}
                    </Stack>
                    {currentVersionName && (
                      <Typography variant="body2" color="text.secondary" noWrap>
                        {currentVersionName}
                      </Typography>
                    )}
                  </Stack>
                </Stack>
                {currentVersionIsConfirmed && (
                  <Stack direction="row" spacing={0.75} sx={{ alignItems: 'center', color: 'success.main' }}>
                    <CheckCircleOutlineRoundedIcon fontSize="small" />
                    <Typography variant="body2" sx={{ fontWeight: 500, whiteSpace: 'nowrap' }}>
                      Version ist aktuell
                    </Typography>
                  </Stack>
                )}
              </Stack>
            </Stack>
          </BorderedSimpleCard>
        </Box>

        {!hasUpdate || !release ? (
          updateStatus.state === 'unavailable' && (
            <Alert severity="warning">Die Suche nach Updates ist gerade nicht verfügbar.</Alert>
          )
        ) : (
          <Stack spacing={2}>
            <OutlinedCard sx={{ bgcolor: 'background.paper' }}>
              <Stack spacing={0.5} sx={{ minWidth: 0 }}>
                <Typography variant="overline" color="text.secondary">
                  Neue Version
                </Typography>
                <Typography variant="h4">Hier ist noch alles in Bewegung</Typography>
                <Typography variant="body1" color="text.secondary">
                  Die App ist gerade noch im Aufbau. Rechne bitte damit, dass sich Funktionen, Ansichten und Abläufe bei
                  jedem Update ändern. Das betrifft Server und Lua-API.
                </Typography>
              </Stack>
              <Divider sx={{ mt: 2, mx: -2 }} />
              <Box
                sx={{
                  bgcolor: 'rgb(237, 247, 237)',
                  mx: -2,
                  px: 2,
                  py: 2,
                }}
              >
                <AvailableVersionSummary release={release} />
              </Box>
              <Divider sx={{ mb: 2, mx: -2 }} />
              <Stack spacing={2}>
                {previewRelease && (
                  <Alert severity="info">
                    <Typography variant="body2">
                      Zusätzlich ist die Vorschauversion {previewRelease.version} verfügbar:{' '}
                      <Link href={previewRelease.url} target="_blank" rel="noreferrer">
                        GitHub Release öffnen
                      </Link>
                    </Typography>
                  </Alert>
                )}
                <ChangelogText text={release.changelog} />
              </Stack>
            </OutlinedCard>
          </Stack>
        )}

        <OutlinedCard
          title="So aktualisierst Du"
          description="Kurzanleitung aus der Update- und Installationsanleitung"
          sx={{ bgcolor: 'background.paper' }}
        >
          <Stack spacing={1.5}>
            <List component="ol" sx={{ listStyleType: 'decimal', pl: 3, py: 0 }}>
              <ListItem sx={{ display: 'list-item', py: 0.5 }}>
                <Typography variant="body1">Beende EEP und den Control Extension Server.</Typography>
              </ListItem>
              <ListItem sx={{ display: 'list-item', py: 0.5 }}>
                <Typography variant="body1">
                  Lösche zur Sicherheit die vorhandenen Verzeichnisse <code>LUA\ce</code> und{' '}
                  <code>Resourcen\Anlagen\ce</code> aus Deiner EEP-Installation.
                </Typography>
              </ListItem>
              <ListItem sx={{ display: 'list-item', py: 0.5 }}>
                <Typography variant="body1">
                  Lade aus dem{' '}
                  <Link
                    href="https://github.com/Andreas-Kreuz/control-extension/releases/latest"
                    target="_blank"
                    rel="noreferrer"
                  >
                    GitHub Release
                  </Link>{' '}
                  die Datei <code>control-extension-*.zip</code> herunter.
                </Typography>
              </ListItem>
              <ListItem sx={{ display: 'list-item', py: 0.5 }}>
                <Typography variant="body1">
                  Starte EEP, öffne den Modell-Installer, wähle die ZIP-Datei aus und starte die Installation.
                </Typography>
              </ListItem>
              <ListItem sx={{ display: 'list-item', py: 0.5 }}>
                <Typography variant="body1">
                  Das Scannen nach neuen Modellen ist nicht notwendig, da die Bibliothek keine 3D-Modelle enthält.
                </Typography>
              </ListItem>
            </List>
          </Stack>
        </OutlinedCard>
      </Stack>
    </PageContainer>
  );
}

function AboutPage() {
  const updateStatus = useUpdateStatus();
  const versions = useVersionInfo();

  return <AboutPageContent installedAppVersion={versions.appVersion} updateStatus={updateStatus} />;
}

export default AboutPage;
