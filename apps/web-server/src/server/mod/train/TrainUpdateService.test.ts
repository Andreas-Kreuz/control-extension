import * as assert from 'node:assert/strict';
import * as express from 'express';
import TrainUpdateService from './TrainUpdateService';
import { CeTypes } from '@ce/web-shared';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function testJsonRoutesLeaseDynamicInterest(): void {
  const touches: Array<{ token: string; ceType: string; id: string; ttlMs: number }> = [];
  const router = express.Router();
  const service = new TrainUpdateService(
    {} as never,
    router,
    {
      touchLeasedToken: (token: string, ceType: string, id: string, ttlMs: number) => {
        touches.push({ token, ceType, id, ttlMs });
      },
    } as never,
  );

  (service as unknown as { trainSelector: { getTrain: (id: string) => { id: string } | undefined } }).trainSelector = {
    getTrain: (id: string) => ({ id }),
  };
  (
    service as unknown as { rollingStockSelector: { getRollingStock: (id: string) => { id: string } | undefined } }
  ).rollingStockSelector = {
    getRollingStock: (id: string) => ({ id }),
  };

  const routerStack = router.stack as unknown as Array<{
    route?: { path: string; stack: Array<{ handle: (req: unknown, res: unknown) => unknown }> };
  }>;
  const trainRoute = routerStack.find((layer) => layer.route?.path === '/train-dynamic/:id');
  const rollingStockRoute = routerStack.find((layer) => layer.route?.path === '/rollingstock-dynamic/:id');

  assert.ok(trainRoute?.route?.stack[0]?.handle);
  assert.ok(rollingStockRoute?.route?.stack[0]?.handle);

  const trainRes = { status: () => trainRes, json: () => undefined };
  const rollingStockRes = { status: () => rollingStockRes, json: () => undefined };

  void trainRoute?.route?.stack[0]?.handle({ params: { id: 'ICE-1' } }, trainRes);
  void rollingStockRoute?.route?.stack[0]?.handle({ params: { id: 'RS-1' } }, rollingStockRes);

  assert.deepEqual(touches, [
    {
      token: 'json:' + CeTypes.HubTrain + ':ICE-1',
      ceType: CeTypes.HubTrain,
      id: 'ICE-1',
      ttlMs: 5000,
    },
    {
      token: 'json:' + CeTypes.HubRollingStock + ':RS-1',
      ceType: CeTypes.HubRollingStock,
      id: 'RS-1',
      ttlMs: 5000,
    },
  ]);
}

export async function run(): Promise<void> {
  await runTest('train update service leases train and rolling stock dynamic interest via shared service', testJsonRoutesLeaseDynamicInterest);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
