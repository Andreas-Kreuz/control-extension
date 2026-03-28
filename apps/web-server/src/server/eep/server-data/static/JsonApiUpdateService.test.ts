import * as assert from 'node:assert/strict';
import { CeTypes } from '@ak/web-shared';
import JsonApiUpdateService from './JsonApiUpdateService';

// ---- Fakes ----

function makeRouter() {
  const handlers: Record<string, (req: any, res: any) => void> = {};

  const router = {
    get(path: string, handler: (req: any, res: any) => void) {
      handlers[path] = handler;
    },
  };

  function makeRes() {
    let statusCode = 200;
    const headers: Record<string, string> = {};
    let body: unknown;
    const res: any = {
      status(s: number) {
        statusCode = s;
        return res;
      },
      json(data: unknown) {
        body = data;
        return res;
      },
      send(b: unknown) {
        body = b;
        return res;
      },
      setHeader(k: string, v: string) {
        headers[k.toLowerCase()] = v;
      },
      _result() {
        return { status: statusCode, headers, body };
      },
    };
    return res;
  }

  return {
    router,
    callIndex() {
      const res = makeRes();
      handlers['/']({}, res);
      return res._result();
    },
    callRoom(room: string) {
      const res = makeRes();
      handlers['/:room']({ params: { room } }, res);
      return res._result();
    },
  };
}

const fakeIo: any = { to: () => ({ emit: () => {} }) };
const fakeCacheService: any = { writeCache: () => {}, readCache: () => null };

function makeStore(ceTypes: Record<string, unknown>, eventCounter = 1) {
  return {
    currentState: () => ({ ceTypes, eventCounter }),
    hasInitialState: () => false,
  };
}

// ---- Test helpers ----

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

// ---- Tests ----

function testIndexReturnsEmptyListWithNoRooms(): void {
  const { router, callIndex } = makeRouter();
  new JsonApiUpdateService(router as any, fakeIo, fakeCacheService);

  const { headers, body } = callIndex();
  assert.equal(headers['content-type'], 'text/html');
  assert.ok((body as string).includes('<ul></ul>'));
}

function testIndexListsRoomsAfterStateChange(): void {
  const { router, callIndex } = makeRouter();
  const svc = new JsonApiUpdateService(router as any, fakeIo, fakeCacheService);

  svc.onStateChange(makeStore({ [CeTypes.HubSignal]: { 1: { id: 1 } } }) as any);

  const { body } = callIndex();
  const html = body as string;
  assert.ok(html.includes(`href="/api/v1/${CeTypes.HubSignal}"`));
  assert.ok(html.includes(`href="/api/v1/${CeTypes.ServerApiEntries}"`));
  assert.ok(html.includes(`href="/api/v1/${CeTypes.ServerStats}"`));
}

function testRoomReturns404WhenUnknown(): void {
  const { router, callRoom } = makeRouter();
  new JsonApiUpdateService(router as any, fakeIo, fakeCacheService);

  const { status, body } = callRoom('nonexistent');
  assert.equal(status, 404);
  assert.deepEqual(body, { error: 'not found' });
}

function testRoomReturnsJsonAfterStateChange(): void {
  const { router, callRoom } = makeRouter();
  const svc = new JsonApiUpdateService(router as any, fakeIo, fakeCacheService);

  svc.onStateChange(makeStore({ [CeTypes.HubSignal]: { 1: { id: 1 } } }) as any);

  const { status, headers, body } = callRoom(CeTypes.HubSignal);
  assert.equal(status, 200);
  assert.equal(headers['content-type'], 'application/json');
  assert.deepEqual(JSON.parse(body as string), { 1: { id: 1 } });
}

function testRoomReturns404AfterRoomIsRemoved(): void {
  const { router, callRoom } = makeRouter();
  const svc = new JsonApiUpdateService(router as any, fakeIo, fakeCacheService);

  svc.onStateChange(makeStore({ [CeTypes.HubSignal]: { 1: { id: 1 } } }) as any);
  svc.onStateChange(makeStore({}) as any);

  const { status } = callRoom(CeTypes.HubSignal);
  assert.equal(status, 404);
}

export async function run(): Promise<void> {
  await runTest('index returns empty list when no rooms registered', testIndexReturnsEmptyListWithNoRooms);
  await runTest('index lists room links after state change', testIndexListsRoomsAfterStateChange);
  await runTest('/:room returns 404 for unknown room', testRoomReturns404WhenUnknown);
  await runTest('/:room returns JSON data for known room', testRoomReturnsJsonAfterStateChange);
  await runTest('/:room returns 404 after room is removed', testRoomReturns404AfterRoomIsRemoved);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
