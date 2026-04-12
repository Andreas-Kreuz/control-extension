import * as assert from 'node:assert/strict';
import DynamicInterestRegistry from './DynamicInterestRegistry';
import DynamicInterestService from './DynamicInterestService';
import DynamicRoomManager from './DynamicRoomManager';
import { DynamicDataProvider } from './DynamicDataProvider';
import { DynamicRoom } from '@ce/web-shared';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function createManager(commands: string[]) {
  const io = {
    to: () => ({
      emit: () => undefined,
    }),
  };
  const interestRegistry = new DynamicInterestRegistry((command) => commands.push(command));
  const interestService = new DynamicInterestService(interestRegistry);
  return new DynamicRoomManager(io as never, interestService);
}

function createSocket(id: string) {
  const events: Array<{ eventName: string; payload: string }> = [];
  return {
    id,
    emit: (eventName: string, payload: string) => {
      events.push({ eventName, payload });
    },
    events,
  };
}

function registerDetailProvider(manager: DynamicRoomManager): DynamicRoom {
  const roomType = new DynamicRoom('TestDetail');
  const provider: DynamicDataProvider = {
    roomType,
    id: 'TestDetailRoom',
    dynamicInterest: {
      ceType: 'ce.test.Detail',
      idOfRoom: (roomName: string) => roomType.idOfRoom(roomName),
    },
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

  assert.deepEqual(commands, ['HubDynamicData.startUpdatesFor|ce.test.Detail|Entry-1']);

  manager.onLeaveRoom(socketA as never, roomName);
  assert.deepEqual(commands, ['HubDynamicData.startUpdatesFor|ce.test.Detail|Entry-1']);

  manager.onLeaveRoom(socketB as never, roomName);
  assert.deepEqual(commands, [
    'HubDynamicData.startUpdatesFor|ce.test.Detail|Entry-1',
    'HubDynamicData.stopUpdatesFor|ce.test.Detail|Entry-1',
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
    'HubDynamicData.startUpdatesFor|ce.test.Detail|Entry-A',
    'HubDynamicData.startUpdatesFor|ce.test.Detail|Entry-B',
    'HubDynamicData.stopUpdatesFor|ce.test.Detail|Entry-A',
    'HubDynamicData.stopUpdatesFor|ce.test.Detail|Entry-B',
  ]);
}

export async function run(): Promise<void> {
  await runTest('dynamic room manager shares interest across room subscribers', testJoinAndLeaveRetainSharedInterest);
  await runTest('dynamic room manager releases socket interests on disconnect', testDisconnectReleasesAllSocketInterests);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
