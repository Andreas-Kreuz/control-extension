import * as assert from 'node:assert/strict';
import DynamicInterestRegistry from './DynamicInterestRegistry';

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
  const registry = new DynamicInterestRegistry((command) => {
    commands.push(command);
  });

  registry.retainToken('socket:a|room:TrainDynamic/ICE-1', 'ce.hub.TrainDynamic', 'ICE-1');
  registry.retainToken('socket:b|room:TrainDynamic/ICE-1', 'ce.hub.TrainDynamic', 'ICE-1');

  assert.deepEqual(commands, ['HubDynamicData.startUpdatesFor|ce.hub.TrainDynamic|ICE-1']);

  registry.releaseToken('socket:a|room:TrainDynamic/ICE-1');
  assert.deepEqual(commands, ['HubDynamicData.startUpdatesFor|ce.hub.TrainDynamic|ICE-1']);

  registry.releaseToken('socket:b|room:TrainDynamic/ICE-1');
  assert.deepEqual(commands, [
    'HubDynamicData.startUpdatesFor|ce.hub.TrainDynamic|ICE-1',
    'HubDynamicData.stopUpdatesFor|ce.hub.TrainDynamic|ICE-1',
  ]);
}

async function testLeasedTokenRefreshesUntilTtlExpires(): Promise<void> {
  const commands: string[] = [];
  const registry = new DynamicInterestRegistry((command) => {
    commands.push(command);
  });

  registry.touchLeasedToken('json:ce.hub.RollingStockDynamic:RS-1', 'ce.hub.RollingStockDynamic', 'RS-1', 40);
  await new Promise((resolve) => setTimeout(resolve, 20));
  registry.touchLeasedToken('json:ce.hub.RollingStockDynamic:RS-1', 'ce.hub.RollingStockDynamic', 'RS-1', 40);
  await new Promise((resolve) => setTimeout(resolve, 20));

  assert.deepEqual(commands, ['HubDynamicData.startUpdatesFor|ce.hub.RollingStockDynamic|RS-1']);

  await new Promise((resolve) => setTimeout(resolve, 60));

  assert.deepEqual(commands, [
    'HubDynamicData.startUpdatesFor|ce.hub.RollingStockDynamic|RS-1',
    'HubDynamicData.stopUpdatesFor|ce.hub.RollingStockDynamic|RS-1',
  ]);
}

function testRetainPerRoomOnlyStopsAfterLastRoomSubscription(): void {
  const commands: string[] = [];
  const registry = new DynamicInterestRegistry((command) => {
    commands.push(command);
  });

  registry.retainToken('socket:a|room:train-details|ICE-1', 'ce.hub.Train', 'ICE-1');
  registry.retainToken('socket:b|room:train-details|ICE-1', 'ce.hub.Train', 'ICE-1');
  registry.retainToken('socket:a|room:sidebar|ICE-1', 'ce.hub.Train', 'ICE-1');

  assert.deepEqual(commands, ['HubDynamicData.startUpdatesFor|ce.hub.Train|ICE-1']);

  registry.releaseToken('socket:a|room:train-details|ICE-1');
  registry.releaseToken('socket:b|room:train-details|ICE-1');

  assert.deepEqual(commands, ['HubDynamicData.startUpdatesFor|ce.hub.Train|ICE-1']);

  registry.releaseToken('socket:a|room:sidebar|ICE-1');

  assert.deepEqual(commands, [
    'HubDynamicData.startUpdatesFor|ce.hub.Train|ICE-1',
    'HubDynamicData.stopUpdatesFor|ce.hub.Train|ICE-1',
  ]);
}

export async function run(): Promise<void> {
  await runTest('retainToken starts updates once and stops after last release', testRetainOnlyStartsOnceForSameInterest);
  await runTest('touchLeasedToken keeps interest alive until ttl expires', testLeasedTokenRefreshesUntilTtlExpires);
  await runTest(
    'retainToken keeps an entry selected until the last room subscription is released',
    testRetainPerRoomOnlyStopsAfterLastRoomSubscription,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
