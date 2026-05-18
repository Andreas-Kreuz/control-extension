import * as assert from 'node:assert/strict';
import { ServerStatisticsService } from './ServerStatisticsService';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function timerOf(service: ServerStatisticsService): NodeJS.Timeout | undefined {
  return (service as unknown as { updateTimer?: NodeJS.Timeout }).updateTimer;
}

function testStartIsIdempotent(): void {
  const service = new ServerStatisticsService();

  try {
    service.start();
    const firstTimer = timerOf(service);
    service.start();

    assert.ok(firstTimer);
    assert.equal(timerOf(service), firstTimer);
  } finally {
    service.stop();
  }
}

function testStopClearsTimer(): void {
  const service = new ServerStatisticsService();
  service.start();
  const timer = timerOf(service);

  service.stop();

  assert.ok(timer);
  assert.equal(timerOf(service), undefined);
  assert.equal((timer as unknown as { _destroyed?: boolean })._destroyed, true);
}

export async function run(): Promise<void> {
  await runTest('ServerStatisticsService start is idempotent', testStartIsIdempotent);
  await runTest('ServerStatisticsService stop clears the update timer', testStopClearsTimer);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
