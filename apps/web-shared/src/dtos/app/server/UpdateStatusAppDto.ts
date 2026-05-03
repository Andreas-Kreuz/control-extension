// App contract populated by:
// apps/web-server/src/server/app/update/UpdateCheckService.ts
export type UpdateStatusState =
  | 'unknown'
  | 'current'
  | 'stable-available'
  | 'prerelease-available'
  | 'unavailable';

export interface UpdateReleaseAppDto {
  version: string;
  name: string;
  url: string;
  downloadUrl?: string;
  prerelease: boolean;
  publishedAt?: string;
  changelog?: string;
}

export interface UpdateStatusAppDto {
  state: UpdateStatusState;
  currentVersion: string;
  checkedAt?: string;
  currentRelease?: UpdateReleaseAppDto;
  availableRelease?: UpdateReleaseAppDto;
  availablePrereleaseRelease?: UpdateReleaseAppDto;
  latestStableRelease?: UpdateReleaseAppDto;
  latestPrereleaseRelease?: UpdateReleaseAppDto;
}
