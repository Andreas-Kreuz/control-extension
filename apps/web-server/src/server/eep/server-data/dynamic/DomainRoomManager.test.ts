import * as assert from 'node:assert/strict';
import InterestSyncRegistry from './InterestSyncRegistry';
import InterestSyncService from './InterestSyncService';
import DomainRoomManager from './DomainRoomManager';
import { DomainDataProvider } from './DomainDataProvider';
import { CeTypeRoom, DomainRoom, RollingStockRoom, TrainRoom } from '@ce/web-shared';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function createManager(
  commands: string[],
  emittedEvents: Array<{ roomName: string; eventName: string; payload: string }> = [],
) {
  const io = {
    to: (roomName: string) => ({
      emit: (eventName: string, payload: string) => emittedEvents.push({ roomName, eventName, payload }),
    }),
  };
  const interestRegistry = new InterestSyncRegistry((command) => commands.push(command));
  const interestService = new InterestSyncService(interestRegistry);
  return new DomainRoomManager(io as never, interestService);
}

function createSocket(id: string) {
  const events: Array<{ eventName: string; payload: string }> = [];
  const joinedRooms: string[] = [];
  const leftRooms: string[] = [];
  return {
    id,
    join: (roomName: string) => {
      joinedRooms.push(roomName);
    },
    leave: (roomName: string) => {
      leftRooms.push(roomName);
    },
    emit: (eventName: string, payload: string) => {
      events.push({ eventName, payload });
    },
    events,
    joinedRooms,
    leftRooms,
  };
}

function registerDetailProvider(manager: DomainRoomManager): DomainRoom {
  const roomType = new DomainRoom('TestDetail');
  const provider: DomainDataProvider = {
    roomType,
    id: 'TestDetailRoom',
    onInterest: [
      {
        ceType: 'ce.test.Detail',
        idOfRoom: (roomName: string) => roomType.idOfRoom(roomName),
      },
    ],
    jsonCreator: (roomName: string) => JSON.stringify({ id: roomType.idOfRoom(roomName) }),
  };
  manager.registerService({
    getUpdaters: () => [],
    getDataProviders: () => [provider],
  });
  return roomType;
}

function registerMultiInterestDetailProvider(manager: DomainRoomManager): DomainRoom {
  const roomType = new DomainRoom('MultiInterestDetail');
  const provider: DomainDataProvider = {
    roomType,
    id: 'MultiInterestDetailRoom',
    onInterest: [
      {
        ceType: 'ce.test.Detail',
        idOfRoom: (roomName: string) => roomType.idOfRoom(roomName),
      },
      {
        ceType: 'ce.test.ExtraDetail',
        idOfRoom: (roomName: string) => roomType.idOfRoom(roomName),
      },
    ],
    jsonCreator: (roomName: string) => JSON.stringify({ id: roomType.idOfRoom(roomName) }),
  };
  manager.registerService({
    getUpdaters: () => [],
    getDataProviders: () => [provider],
  });
  return roomType;
}

function testJoinAndLeaveRetainSharedInterest(): void {
  const commands: string[] = [];
  const manager = createManager(commands);
  const roomType = registerDetailProvider(manager);
  const socketA = createSocket('a');
  const socketB = createSocket('b');
  const roomName = roomType.roomId('Entry-1');

  manager.onJoinRoom(socketA as never, roomName);
  manager.onJoinRoom(socketB as never, roomName);

  assert.deepEqual(commands, ['HubInterestSync.startSyncFor|ce.test.Detail|Entry-1']);

  manager.onLeaveRoom(socketA as never, roomName);
  assert.deepEqual(commands, ['HubInterestSync.startSyncFor|ce.test.Detail|Entry-1']);

  manager.onLeaveRoom(socketB as never, roomName);
  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.test.Detail|Entry-1',
    'HubInterestSync.stopSyncFor|ce.test.Detail|Entry-1',
  ]);
}

function testDisconnectReleasesAllSocketInterests(): void {
  const commands: string[] = [];
  const manager = createManager(commands);
  const roomType = registerDetailProvider(manager);
  const socket = createSocket('socket-1');
  const roomA = roomType.roomId('Entry-A');
  const roomB = roomType.roomId('Entry-B');

  manager.onJoinRoom(socket as never, roomA);
  manager.onJoinRoom(socket as never, roomB);
  manager.onSocketClose(socket as never);

  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.test.Detail|Entry-A',
    'HubInterestSync.startSyncFor|ce.test.Detail|Entry-B',
    'HubInterestSync.stopSyncFor|ce.test.Detail|Entry-A',
    'HubInterestSync.stopSyncFor|ce.test.Detail|Entry-B',
  ]);
}

function testJoinAndLeaveRetainMultipleInterestsForOneRoom(): void {
  const commands: string[] = [];
  const manager = createManager(commands);
  const roomType = registerMultiInterestDetailProvider(manager);
  const socket = createSocket('socket-1');
  const roomName = roomType.roomId('Entry-1');

  manager.onJoinRoom(socket as never, roomName);
  manager.onLeaveRoom(socket as never, roomName);

  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.test.Detail|Entry-1',
    'HubInterestSync.startSyncFor|ce.test.ExtraDetail|Entry-1',
    'HubInterestSync.stopSyncFor|ce.test.Detail|Entry-1',
    'HubInterestSync.stopSyncFor|ce.test.ExtraDetail|Entry-1',
  ]);
}

function testOneSocketReceivesUpdatesForMultipleDomainRooms(): void {
  const commands: string[] = [];
  const emittedEvents: Array<{ roomName: string; eventName: string; payload: string }> = [];
  const manager = createManager(commands, emittedEvents);
  const roomType = registerDetailProvider(manager);
  const socket = createSocket('socket-1');
  const roomA = roomType.roomId('Entry-A');
  const roomB = roomType.roomId('Entry-B');

  manager.onJoinRoom(socket as never, roomA);
  manager.onJoinRoom(socket as never, roomB);

  assert.deepEqual(socket.joinedRooms, [roomA, roomB]);

  manager.onStateChange({
    currentState: () => ({
      eventCounter: 1,
      ceTypes: {},
    }),
  } as never);

  assert.deepEqual(
    emittedEvents.sort((left, right) => left.roomName.localeCompare(right.roomName)),
    [
      {
        roomName: roomA,
        eventName: roomType.eventId('Entry-A'),
        payload: JSON.stringify({ id: 'Entry-A' }),
      },
      {
        roomName: roomB,
        eventName: roomType.eventId('Entry-B'),
        payload: JSON.stringify({ id: 'Entry-B' }),
      },
    ],
  );
}

function testCeTypeRoomServesRawEntriesDynamically(): void {
  const commands: string[] = [];
  const emittedEvents: Array<{ roomName: string; eventName: string; payload: string }> = [];
  const manager = createManager(commands, emittedEvents);
  const socket = createSocket('socket-1');
  const room = new CeTypeRoom('ce.test.Raw');
  const roomName = room.roomId('Entry-1');

  manager.onStateChange({
    currentState: () => ({
      eventCounter: 1,
      ceTypes: { 'ce.test.Raw': { 'Entry-1': { id: 'Entry-1', value: 1 } } },
    }),
  } as never);
  manager.onJoinRoom(socket as never, roomName);

  assert.deepEqual(socket.events, [
    {
      eventName: room.eventId('Entry-1'),
      payload: JSON.stringify({ id: 'Entry-1', value: 1 }),
    },
  ]);
  assert.deepEqual(commands, ['HubInterestSync.startSyncFor|ce.test.Raw|Entry-1']);

  manager.onStateChange({
    currentState: () => ({
      eventCounter: 2,
      ceTypes: { 'ce.test.Raw': { 'Entry-1': { id: 'Entry-1', value: 2 } } },
    }),
  } as never);

  assert.deepEqual(emittedEvents, [
    {
      roomName,
      eventName: room.eventId('Entry-1'),
      payload: JSON.stringify({ id: 'Entry-1', value: 2 }),
    },
  ]);

  manager.onLeaveRoom(socket as never, roomName);
  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.test.Raw|Entry-1',
    'HubInterestSync.stopSyncFor|ce.test.Raw|Entry-1',
  ]);
}

function testAppDomainRoomUsesCentralInterestRegistry(): void {
  const commands: string[] = [];
  const manager = createManager(commands);
  const provider: DomainDataProvider = {
    roomType: TrainRoom,
    id: 'TrainRoom',
    jsonCreator: (roomName: string) => JSON.stringify({ id: TrainRoom.idOfRoom(roomName) }),
  };
  manager.registerService({
    getUpdaters: () => [],
    getDataProviders: () => [provider],
  });

  const socket = createSocket('socket-1');
  const roomName = TrainRoom.roomId('Train-1');
  manager.onJoinRoom(socket as never, roomName);
  manager.onLeaveRoom(socket as never, roomName);

  assert.deepEqual(socket.joinedRooms, [roomName]);
  assert.deepEqual(socket.leftRooms, [roomName]);

  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.hub.Train|Train-1',
    'HubInterestSync.startSyncFor|ce.mods.transit.TransitTrain|Train-1',
    'HubInterestSync.stopSyncFor|ce.hub.Train|Train-1',
    'HubInterestSync.stopSyncFor|ce.mods.transit.TransitTrain|Train-1',
  ]);
}

function testRollingStockRoomUsesRollingStockInterest(): void {
  const commands: string[] = [];
  const manager = createManager(commands);
  const provider: DomainDataProvider = {
    roomType: RollingStockRoom,
    id: 'RollingStockRoom',
    jsonCreator: (roomName: string) => JSON.stringify({ id: RollingStockRoom.idOfRoom(roomName) }),
  };
  manager.registerService({
    getUpdaters: () => [],
    getDataProviders: () => [provider],
  });

  const socket = createSocket('socket-1');
  const roomName = RollingStockRoom.roomId('#AxisStock;001');
  manager.onJoinRoom(socket as never, roomName);
  manager.onLeaveRoom(socket as never, roomName);

  assert.deepEqual(commands, [
    'HubInterestSync.startSyncFor|ce.hub.RollingStock|#AxisStock;001',
    'HubInterestSync.stopSyncFor|ce.hub.RollingStock|#AxisStock;001',
  ]);
}

export async function run(): Promise<void> {
  await runTest('domain room manager shares interest across room subscribers', testJoinAndLeaveRetainSharedInterest);
  await runTest(
    'domain room manager releases socket interests on disconnect',
    testDisconnectReleasesAllSocketInterests,
  );
  await runTest(
    'domain room manager retains multiple interests for one room',
    testJoinAndLeaveRetainMultipleInterestsForOneRoom,
  );
  await runTest(
    'domain room manager updates multiple rooms on one socket',
    testOneSocketReceivesUpdatesForMultipleDomainRooms,
  );
  await runTest('domain room manager serves dynamic ceType rooms', testCeTypeRoomServesRawEntriesDynamically);
  await runTest(
    'domain room manager uses central app room interest registry',
    testAppDomainRoomUsesCentralInterestRegistry,
  );
  await runTest(
    'domain room manager uses rolling stock interest for rolling stock rooms',
    testRollingStockRoomUsesRollingStockInterest,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
