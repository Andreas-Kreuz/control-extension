import { strict as assert } from 'assert';
import { compareVersions, createUpdateStatus } from './UpdateCheckService';
import type { UpdateReleaseAppDto } from '@ce/web-shared';

function release(version: string, prerelease = false): UpdateReleaseAppDto {
  return {
    version,
    name: 'Control Extension ' + version,
    url: 'https://example.test/' + version,
    prerelease,
  };
}

async function testCompareVersions(): Promise<void> {
  assert.equal(compareVersions('0.0.7', '0.0.6'), 1);
  assert.equal(compareVersions('v0.0.7', '0.0.7'), 0);
  assert.equal(compareVersions('0.0.7-beta.2', '0.0.7-beta.1'), 1);
  assert.equal(compareVersions('0.0.7', '0.0.7-beta.1'), 1);
  assert.equal(compareVersions('not-a-version', '0.0.7'), undefined);
}

async function testStableUpdateWinsOverPrerelease(): Promise<void> {
  const status = createUpdateStatus('0.0.6', [release('0.0.7'), release('0.0.8-beta.1', true)], '2026-05-03T00:00:00.000Z');

  assert.equal(status.state, 'stable-available');
  assert.equal(status.availableRelease?.version, '0.0.7');
  assert.equal(status.availablePrereleaseRelease?.version, '0.0.8-beta.1');
  assert.equal(status.latestPrereleaseRelease?.version, '0.0.8-beta.1');
}

async function testPrereleaseUpdateWhenNoStableUpdateExists(): Promise<void> {
  const status = createUpdateStatus('0.0.6', [release('0.0.6'), release('0.0.7-beta.1', true)], '2026-05-03T00:00:00.000Z');

  assert.equal(status.state, 'prerelease-available');
  assert.equal(status.availableRelease?.version, '0.0.7-beta.1');
  assert.equal(status.currentRelease?.version, '0.0.6');
}

async function testCurrentWhenNothingNewerExists(): Promise<void> {
  const status = createUpdateStatus('0.0.7', [release('0.0.7'), release('0.0.7-beta.1', true)], '2026-05-03T00:00:00.000Z');

  assert.equal(status.state, 'current');
  assert.equal(status.availableRelease, undefined);
}

async function testCurrentReleaseKeepsPrereleaseInfo(): Promise<void> {
  const status = createUpdateStatus(
    '0.0.4',
    [release('0.0.4', true), release('0.0.5', true)],
    '2026-05-03T00:00:00.000Z',
  );

  assert.equal(status.currentRelease?.version, '0.0.4');
  assert.equal(status.currentRelease?.prerelease, true);
}

export async function run(): Promise<void> {
  await testCompareVersions();
  await testStableUpdateWinsOverPrerelease();
  await testPrereleaseUpdateWhenNoStableUpdateExists();
  await testCurrentWhenNothingNewerExists();
  await testCurrentReleaseKeepsPrereleaseInfo();
}
