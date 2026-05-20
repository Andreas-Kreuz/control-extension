import * as assert from 'node:assert/strict';
import InterestSyncRegistry from './InterestSyncRegistry';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function testRetainOnlyStartsOnceForSameInterest(): void {
  const commands: string[] = [];
  const registry = new InterestSyncRegistry((command) => {
    commands.push(command);
  });

  registry.retainToken('socket:a|room:Train/ICE-1', 'ce.hub.Train', 'ICE-1');
  registry.retainToken('socket:b|room:Train/ICE-1', 'ce.hub.Train', 'ICE-1');

  assert.deepEqual(commands, ['HubInterestSync.startSyncFor|ce.hub.Train|ICE-1']);

  registry.releaseToken('socket:a|room:Train/ICE-1');
  assert.deepEqual(commands, ['HubInterestSync.startSyncFor|ce.hub.Train|ICE-1']);

  registry.releaseToken('socket:b|room:Train/ICE-1');
  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.hub.Train|ICE-1',
    'HubInterestSync.stopSyncFor|ce.hub.Train|ICE-1',
  ]);
}

async function testLeasedTokenRefreshesUntilTtlExpires(): Promise<void> {
  const commands: string[] = [];
  const registry = new InterestSyncRegistry((command) => {
    commands.push(command);
  });

  registry.touchLeasedToken('json:ce.hub.RollingStock:RS-1', 'ce.hub.RollingStock', 'RS-1', 40);
  await new Promise((resolve) => setTimeout(resolve, 20));
  registry.touchLeasedToken('json:ce.hub.RollingStock:RS-1', 'ce.hub.RollingStock', 'RS-1', 40);
  await new Promise((resolve) => setTimeout(resolve, 20));

  assert.deepEqual(commands, ['HubInterestSync.startSyncFor|ce.hub.RollingStock|RS-1']);

  await new Promise((resolve) => setTimeout(resolve, 60));

  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.hub.RollingStock|RS-1',
    'HubInterestSync.stopSyncFor|ce.hub.RollingStock|RS-1',
  ]);
}

function testRetainPerRoomOnlyStopsAfterLastRoomSubscription(): void {
  const commands: string[] = [];
  const registry = new InterestSyncRegistry((command) => {
    commands.push(command);
  });

  registry.retainToken('socket:a|room:train-details|ICE-1', 'ce.hub.Train', 'ICE-1');
  registry.retainToken('socket:b|room:train-details|ICE-1', 'ce.hub.Train', 'ICE-1');
  registry.retainToken('socket:a|room:sidebar|ICE-1', 'ce.hub.Train', 'ICE-1');

  assert.deepEqual(commands, ['HubInterestSync.startSyncFor|ce.hub.Train|ICE-1']);

  registry.releaseToken('socket:a|room:train-details|ICE-1');
  registry.releaseToken('socket:b|room:train-details|ICE-1');

  assert.deepEqual(commands, ['HubInterestSync.startSyncFor|ce.hub.Train|ICE-1']);

  registry.releaseToken('socket:a|room:sidebar|ICE-1');

  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.hub.Train|ICE-1',
    'HubInterestSync.stopSyncFor|ce.hub.Train|ICE-1',
  ]);
}

function testReplayRetainedInterestsRestartsCurrentSelections(): void {
  const commands: string[] = [];
  const registry = new InterestSyncRegistry((command) => {
    commands.push(command);
  });

  registry.retainToken('socket:a|room:train-details|Train-A', 'ce.hub.Train', 'Train-A');
  registry.retainToken('socket:b|room:train-details|Train-A', 'ce.hub.Train', 'Train-A');
  registry.retainToken('socket:a|room:rolling-stock|RS-A', 'ce.hub.RollingStock', 'RS-A');
  registry.replayRetainedInterests();
  registry.releaseToken('socket:a|room:train-details|Train-A');
  registry.releaseToken('socket:b|room:train-details|Train-A');

  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.hub.Train|Train-A',
    'HubInterestSync.startSyncFor|ce.hub.RollingStock|RS-A',
    'HubInterestSync.startSyncFor|ce.hub.Train|Train-A',
    'HubInterestSync.startSyncFor|ce.hub.RollingStock|RS-A',
    'HubInterestSync.stopSyncFor|ce.hub.Train|Train-A',
  ]);
}

export async function run(): Promise<void> {
  await runTest(
    'retainToken starts updates once and stops after last release',
    testRetainOnlyStartsOnceForSameInterest,
  );
  await runTest('touchLeasedToken keeps interest alive until ttl expires', testLeasedTokenRefreshesUntilTtlExpires);
  await runTest(
    'retainToken keeps an entry selected until the last room subscription is released',
    testRetainPerRoomOnlyStopsAfterLastRoomSubscription,
  );
  await runTest(
    'replayRetainedInterests restarts current selections',
    testReplayRetainedInterestsRestartsCurrentSelections,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
