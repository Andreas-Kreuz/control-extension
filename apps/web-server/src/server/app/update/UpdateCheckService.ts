import type { UpdateReleaseAppDto, UpdateStatusAppDto } from '@ce/web-shared';
import * as fs from 'fs';
import * as path from 'path';

const GITHUB_RELEASES_URL = 'https://api.github.com/repos/Andreas-Kreuz/control-extension/releases?per_page=100';
const CHECK_INTERVAL_MS = 12 * 60 * 60 * 1000;
const CACHE_FILE = 'update-status-cache.json';
const ROOM_ELEMENT = 'UpdateStatus';

export const UpdateStatusRoomElement = ROOM_ELEMENT;

interface GitHubRelease {
  tag_name?: unknown;
  name?: unknown;
  html_url?: unknown;
  assets?: unknown;
  prerelease?: unknown;
  draft?: unknown;
  published_at?: unknown;
  body?: unknown;
}

interface GitHubReleaseAsset {
  name?: unknown;
  browser_download_url?: unknown;
}

interface CachedUpdateStatus {
  etag?: string;
  status?: UpdateStatusAppDto;
}

interface ParsedVersion {
  major: number;
  minor: number;
  patch: number;
  prerelease?: string;
}

interface UpdateCheckServiceOptions {
  cacheDirectory: string;
  currentVersion?: string;
  fetchImpl?: typeof fetch;
  now?: () => Date;
}

function normalizeVersion(version: string): string {
  return version.trim().replace(/^v/i, '');
}

function parseVersion(version: string): ParsedVersion | undefined {
  const match = normalizeVersion(version).match(/^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?$/);
  if (!match) {
    return undefined;
  }

  const [, major, minor, patch, prerelease] = match;
  if (major === undefined || minor === undefined || patch === undefined) {
    return undefined;
  }

  return {
    major: Number.parseInt(major, 10),
    minor: Number.parseInt(minor, 10),
    patch: Number.parseInt(patch, 10),
    ...(prerelease !== undefined ? { prerelease } : {}),
  };
}

function comparePrerelease(left: string, right: string): number {
  const leftParts = left.split('.');
  const rightParts = right.split('.');
  const maxLength = Math.max(leftParts.length, rightParts.length);

  for (let index = 0; index < maxLength; index += 1) {
    const leftPart = leftParts[index];
    const rightPart = rightParts[index];
    if (leftPart === undefined) return -1;
    if (rightPart === undefined) return 1;
    if (leftPart === rightPart) continue;

    const leftNumber = /^\d+$/.test(leftPart) ? Number.parseInt(leftPart, 10) : undefined;
    const rightNumber = /^\d+$/.test(rightPart) ? Number.parseInt(rightPart, 10) : undefined;
    if (leftNumber !== undefined && rightNumber !== undefined) return leftNumber - rightNumber;
    if (leftNumber !== undefined) return -1;
    if (rightNumber !== undefined) return 1;
    return leftPart.localeCompare(rightPart);
  }

  return 0;
}

export function compareVersions(leftVersion: string, rightVersion: string): number | undefined {
  const left = parseVersion(leftVersion);
  const right = parseVersion(rightVersion);
  if (!left || !right) {
    return undefined;
  }

  const numericCompare = left.major - right.major || left.minor - right.minor || left.patch - right.patch;
  if (numericCompare !== 0) {
    return numericCompare;
  }

  if (left.prerelease === undefined && right.prerelease === undefined) return 0;
  if (left.prerelease === undefined) return 1;
  if (right.prerelease === undefined) return -1;
  return comparePrerelease(left.prerelease, right.prerelease);
}

function releaseVersion(release: GitHubRelease): string | undefined {
  return typeof release.tag_name === 'string' && parseVersion(release.tag_name)
    ? normalizeVersion(release.tag_name)
    : undefined;
}

function mainDownloadUrl(release: GitHubRelease, version: string): string | undefined {
  if (!Array.isArray(release.assets)) {
    return undefined;
  }

  const normalizedVersion = normalizeVersion(version);
  const mainAssetName = 'control-extension-' + normalizedVersion + '.zip';
  const assets = release.assets.filter(
    (asset): asset is GitHubReleaseAsset => typeof asset === 'object' && asset !== null,
  );
  const mainAsset = assets.find((asset) => asset.name === mainAssetName);
  const fallbackAsset = assets.find(
    (asset) =>
      typeof asset.name === 'string' &&
      asset.name.startsWith('control-extension') &&
      asset.name.endsWith('.zip') &&
      !asset.name.includes('ak-compat'),
  );
  const downloadUrl = mainAsset?.browser_download_url ?? fallbackAsset?.browser_download_url;

  return typeof downloadUrl === 'string' ? downloadUrl : undefined;
}

function toAppRelease(release: GitHubRelease): UpdateReleaseAppDto | undefined {
  const version = releaseVersion(release);
  if (!version || typeof release.html_url !== 'string') {
    return undefined;
  }
  const downloadUrl = mainDownloadUrl(release, version);

  return {
    version,
    name: typeof release.name === 'string' && release.name.length > 0 ? release.name : 'Control Extension ' + version,
    url: release.html_url,
    ...(downloadUrl !== undefined ? { downloadUrl } : {}),
    prerelease: release.prerelease === true,
    ...(typeof release.published_at === 'string' ? { publishedAt: release.published_at } : {}),
    ...(typeof release.body === 'string' && release.body.length > 0 ? { changelog: release.body } : {}),
  };
}

function latestRelease(releases: UpdateReleaseAppDto[]): UpdateReleaseAppDto | undefined {
  return releases.slice().sort((left, right) => {
    const compared = compareVersions(right.version, left.version);
    if (compared !== undefined && compared !== 0) {
      return compared;
    }
    return (right.publishedAt ?? '').localeCompare(left.publishedAt ?? '');
  })[0];
}

function readCurrentVersion(): string {
  const candidates = [
    path.resolve(process.cwd(), 'package.json'),
    path.resolve(process.cwd(), 'apps/web-server/package.json'),
    path.resolve(__dirname, '../../../../package.json'),
    path.resolve(__dirname, '../../../../../apps/web-server/package.json'),
  ];

  for (const candidate of candidates) {
    try {
      const packageJson = JSON.parse(fs.readFileSync(candidate, 'utf8')) as { version?: unknown };
      if (typeof packageJson.version === 'string') {
        return packageJson.version;
      }
    } catch (_error) {
      // Try the next candidate.
    }
  }

  return '0.0.0';
}

export function createUpdateStatus(
  currentVersion: string,
  releases: UpdateReleaseAppDto[],
  checkedAt: string,
): UpdateStatusAppDto {
  const normalizedCurrentVersion = normalizeVersion(currentVersion);
  const currentRelease = releases.find((release) => normalizeVersion(release.version) === normalizedCurrentVersion);
  const latestStableRelease = latestRelease(releases.filter((release) => !release.prerelease));
  const latestPrereleaseRelease = latestRelease(releases.filter((release) => release.prerelease));
  const stableComparison = latestStableRelease ? compareVersions(latestStableRelease.version, currentVersion) : 0;
  const prereleaseComparison = latestPrereleaseRelease
    ? compareVersions(latestPrereleaseRelease.version, currentVersion)
    : 0;
  const availablePrereleaseRelease =
    prereleaseComparison !== undefined && prereleaseComparison > 0 ? latestPrereleaseRelease : undefined;

  const availableRelease =
    stableComparison !== undefined && stableComparison > 0 ? latestStableRelease : availablePrereleaseRelease;

  const state =
    availableRelease === undefined
      ? 'current'
      : availableRelease.prerelease
        ? 'prerelease-available'
        : 'stable-available';

  return {
    state,
    currentVersion,
    checkedAt,
    ...(currentRelease !== undefined ? { currentRelease } : {}),
    ...(availableRelease !== undefined ? { availableRelease } : {}),
    ...(availablePrereleaseRelease !== undefined ? { availablePrereleaseRelease } : {}),
    ...(latestStableRelease !== undefined ? { latestStableRelease } : {}),
    ...(latestPrereleaseRelease !== undefined ? { latestPrereleaseRelease } : {}),
  };
}

export default class UpdateCheckService {
  private cacheFile: string;
  private currentVersion: string;
  private etag: string | undefined;
  private fetchImpl: typeof fetch;
  private inFlight: Promise<void> | null = null;
  private listeners: Array<(status: UpdateStatusAppDto) => void> = [];
  private now: () => Date;
  private status: UpdateStatusAppDto;
  private timer: NodeJS.Timeout | undefined;

  constructor(options: UpdateCheckServiceOptions) {
    this.cacheFile = path.resolve(options.cacheDirectory, CACHE_FILE);
    this.currentVersion = options.currentVersion ?? readCurrentVersion();
    this.fetchImpl = options.fetchImpl ?? fetch;
    this.now = options.now ?? (() => new Date());
    this.status = { state: 'unknown', currentVersion: this.currentVersion };
    this.loadCache();
  }

  start(): void {
    void this.refresh();
    this.timer = setInterval(() => {
      void this.refresh();
    }, CHECK_INTERVAL_MS);
    this.timer.unref?.();
  }

  stop(): void {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = undefined;
    }
  }

  getStatus(): UpdateStatusAppDto {
    return this.status;
  }

  onStatusChanged(listener: (status: UpdateStatusAppDto) => void): void {
    this.listeners.push(listener);
  }

  async refresh(): Promise<void> {
    if (this.inFlight) {
      return this.inFlight;
    }

    this.inFlight = this.refreshInternal().finally(() => {
      this.inFlight = null;
    });
    return this.inFlight;
  }

  private async refreshInternal(): Promise<void> {
    try {
      const headers: Record<string, string> = {
        Accept: 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      };
      if (this.etag) {
        headers['If-None-Match'] = this.etag;
      }

      const response = await this.fetchImpl(GITHUB_RELEASES_URL, { headers });
      const checkedAt = this.now().toISOString();

      if (response.status === 304) {
        this.setStatus({ ...this.status, checkedAt });
        return;
      }

      if (!response.ok) {
        this.setStatus({
          ...this.status,
          state: this.status.state === 'unknown' ? 'unavailable' : this.status.state,
          checkedAt,
        });
        return;
      }

      const nextEtag = response.headers.get('etag') ?? undefined;
      const payload = (await response.json()) as unknown;
      if (!Array.isArray(payload)) {
        this.setStatus({ state: 'unavailable', currentVersion: this.currentVersion, checkedAt });
        return;
      }

      const releases = payload
        .filter((release): release is GitHubRelease => typeof release === 'object' && release !== null)
        .filter((release) => release.draft !== true)
        .map(toAppRelease)
        .filter((release): release is UpdateReleaseAppDto => release !== undefined);
      this.etag = nextEtag;
      this.setStatus(createUpdateStatus(this.currentVersion, releases, checkedAt));
    } catch (_error) {
      const checkedAt = this.now().toISOString();
      this.setStatus({
        ...this.status,
        state: this.status.state === 'unknown' ? 'unavailable' : this.status.state,
        checkedAt,
      });
    }
  }

  private loadCache(): void {
    try {
      const cache = JSON.parse(fs.readFileSync(this.cacheFile, 'utf8')) as CachedUpdateStatus;
      if (cache.status?.currentVersion === this.currentVersion) {
        this.etag = cache.etag;
        this.status = cache.status;
      }
    } catch (_error) {
      // Missing or invalid cache is harmless.
    }
  }

  private saveCache(): void {
    try {
      fs.mkdirSync(path.dirname(this.cacheFile), { recursive: true });
      fs.writeFileSync(this.cacheFile, JSON.stringify({ etag: this.etag, status: this.status }, null, 2));
    } catch (_error) {
      // Update hints must never break the server.
    }
  }

  private setStatus(status: UpdateStatusAppDto): void {
    this.status = status;
    this.saveCache();
    this.listeners.forEach((listener) => listener(status));
  }
}
