import * as assert from 'node:assert/strict';
import { CeTypes } from '@ce/web-shared';
import type EepDataStore from '../EepDataStore';
import type { CacheService } from '../CacheService';
import type { State } from '../EepDataStore';
import JsonApiUpdateService from './JsonApiUpdateService';

// ---- Fakes ----

interface TestRequest {
  params: { room: string };
}

type TestNext = () => void;

interface TestResponseResult {
  status: number;
  headers: Record<string, string>;
  body: unknown;
}

interface TestResponse {
  status(code: number): TestResponse;
  json(data: unknown): TestResponse;
  send(data: unknown): TestResponse;
  setHeader(key: string, value: string): void;
  getResult(): TestResponseResult;
}

interface TestRouter {
  get(path: string, handler: (req: TestRequest, res: TestResponse, next?: TestNext) => void): void;
}

interface TestServer {
  to(room: string): { emit(event: string, payload?: unknown): void };
}

type TestStore = Pick<EepDataStore, 'currentState' | 'hasInitialState'>;
type JsonApiUpdateServiceArgs = ConstructorParameters<typeof JsonApiUpdateService>;

function makeRouter() {
  const handlers: Record<string, (req: TestRequest, res: TestResponse, next?: TestNext) => void> = {};

  const router: TestRouter = {
    get(path: string, handler: (req: TestRequest, res: TestResponse, next?: TestNext) => void) {
      handlers[path] = handler;
    },
  };

  function makeRes(): TestResponse {
    let statusCode = 200;
    const headers: Record<string, string> = {};
    let body: unknown;
    const res: TestResponse = {
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
      getResult() {
        return { status: statusCode, headers, body };
      },
    };
    return res;
  }

  return {
    router,
    callIndex() {
      const res = makeRes();
      const handler = handlers['/'];
      assert.ok(handler);
      handler({ params: { room: '' } }, res);
      return res.getResult();
    },
    callRoom(room: string) {
      const res = makeRes();
      const handler = handlers['/:room'];
      assert.ok(handler);
      handler({ params: { room } }, res);
      return res.getResult();
    },
    callRoomWithNext(room: string) {
      const res = makeRes();
      const handler = handlers['/:room'];
      assert.ok(handler);
      let nextCalled = false;
      handler({ params: { room } }, res, () => {
        nextCalled = true;
      });
      return { nextCalled, result: res.getResult() };
    },
  };
}

const fakeIo: TestServer = { to: () => ({ emit: () => {} }) };
const fakeCacheService: CacheService = { writeCache: () => {}, readCache: () => null };

function makeStore(ceTypes: State['ceTypes'], eventCounter = 1): TestStore {
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
  new JsonApiUpdateService(
    router as unknown as JsonApiUpdateServiceArgs[0],
    fakeIo as unknown as JsonApiUpdateServiceArgs[1],
    fakeCacheService,
  );

  const { headers, body } = callIndex();
  assert.equal(headers['content-type'], 'text/html');
  assert.ok((body as string).includes('<ul></ul>'));
}

function testIndexListsRoomsAfterStateChange(): void {
  const { router, callIndex } = makeRouter();
  const svc = new JsonApiUpdateService(
    router as unknown as JsonApiUpdateServiceArgs[0],
    fakeIo as unknown as JsonApiUpdateServiceArgs[1],
    fakeCacheService,
  );

  svc.onStateChange(makeStore({ [CeTypes.HubSignal]: { 1: { id: 1 } } }) as unknown as Readonly<EepDataStore>);

  const { body } = callIndex();
  const html = body as string;
  assert.ok(html.includes(`href="/api/v1/${CeTypes.HubSignal}"`));
  assert.ok(html.includes(`href="/api/v1/${CeTypes.ServerApiEntries}"`));
  assert.ok(html.includes(`href="/api/v1/${CeTypes.ServerStats}"`));
}

function testRoomReturns404WhenUnknown(): void {
  const { router, callRoom } = makeRouter();
  new JsonApiUpdateService(
    router as unknown as JsonApiUpdateServiceArgs[0],
    fakeIo as unknown as JsonApiUpdateServiceArgs[1],
    fakeCacheService,
  );

  const { status, body } = callRoom('nonexistent');
  assert.equal(status, 404);
  assert.deepEqual(body, { error: 'not found' });
}

function testRoomDelegatesToNextWhenUnknownAndNextProvided(): void {
  const { router, callRoomWithNext } = makeRouter();
  new JsonApiUpdateService(
    router as unknown as JsonApiUpdateServiceArgs[0],
    fakeIo as unknown as JsonApiUpdateServiceArgs[1],
    fakeCacheService,
  );

  const { nextCalled, result } = callRoomWithNext('nonexistent');
  assert.equal(nextCalled, true);
  assert.equal(result.status, 200);
  assert.equal(result.body, undefined);
}

function testRoomReturnsJsonAfterStateChange(): void {
  const { router, callRoom } = makeRouter();
  const svc = new JsonApiUpdateService(
    router as unknown as JsonApiUpdateServiceArgs[0],
    fakeIo as unknown as JsonApiUpdateServiceArgs[1],
    fakeCacheService,
  );

  svc.onStateChange(makeStore({ [CeTypes.HubSignal]: { 1: { id: 1 } } }) as unknown as Readonly<EepDataStore>);

  const { status, headers, body } = callRoom(CeTypes.HubSignal);
  assert.equal(status, 200);
  assert.equal(headers['content-type'], 'application/json');
  assert.deepEqual(JSON.parse(body as string), { 1: { id: 1 } });
}

function testRoomReturns404AfterRoomIsRemoved(): void {
  const { router, callRoom } = makeRouter();
  const svc = new JsonApiUpdateService(
    router as unknown as JsonApiUpdateServiceArgs[0],
    fakeIo as unknown as JsonApiUpdateServiceArgs[1],
    fakeCacheService,
  );

  svc.onStateChange(makeStore({ [CeTypes.HubSignal]: { 1: { id: 1 } } }) as unknown as Readonly<EepDataStore>);
  svc.onStateChange(makeStore({}) as unknown as Readonly<EepDataStore>);

  const { status } = callRoom(CeTypes.HubSignal);
  assert.equal(status, 404);
}

export async function run(): Promise<void> {
  await runTest('index returns empty list when no rooms registered', testIndexReturnsEmptyListWithNoRooms);
  await runTest('index lists room links after state change', testIndexListsRoomsAfterStateChange);
  await runTest('/:room returns 404 for unknown room', testRoomReturns404WhenUnknown);
  await runTest(
    '/:room delegates to next for unknown room when provided',
    testRoomDelegatesToNextWhenUnknownAndNextProvided,
  );
  await runTest('/:room returns JSON data for known room', testRoomReturnsJsonAfterStateChange);
  await runTest('/:room returns 404 after room is removed', testRoomReturns404AfterRoomIsRemoved);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
