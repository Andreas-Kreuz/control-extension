import * as assert from 'node:assert/strict';
import { CommandEvent } from '@ce/web-shared';
import { registerCommandMod } from './registerCommandMod';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function testSetRollingStockAxisQueuesNumberCommandWhenAxisNamesAreUnknown(): void {
  const { commands, handlers } = setupCommandHandlers();

  handlers.get(CommandEvent.SetRollingStockAxis)?.({
    rollingStockName: 'RS-1',
    axisNumber: 2.2,
    value: 101.7,
  });

  assert.deepEqual(commands, ['EEPRollingstockSetAxisByNumber|RS-1|2|100']);
}

function testSetRollingStockAxisQueuesNameCommandWhenAxisNamesAreKnown(): void {
  const { commands, handlers } = setupCommandHandlers();

  handlers.get(CommandEvent.SetRollingStockAxis)?.({
    rollingStockName: 'RS-1',
    axisNumber: 8,
    axisName: 'Heckfluegel',
    axisNamesKnown: true,
    value: 55.4,
  });

  assert.deepEqual(commands, ['EEPRollingstockSetAxis|RS-1|Heckfluegel|55']);
}

function testSetTrainSpeedQueuesClampedTargetSpeedCommand(): void {
  const { commands, handlers } = setupCommandHandlers();

  handlers.get(CommandEvent.SetTrainSpeed)?.({
    trainName: '#Train-1',
    speed: 260.2,
  });

  assert.deepEqual(commands, ['EEPSetTrainSpeed|#Train-1|250|true']);
}

function testSetTrainCouplingQueuesFrontAndRearCommands(): void {
  const { commands, handlers } = setupCommandHandlers();

  handlers.get(CommandEvent.SetTrainCoupling)?.({
    trainName: '#Train-1',
    position: 'front',
    enabled: true,
  });
  handlers.get(CommandEvent.SetTrainCoupling)?.({
    trainName: '#Train-1',
    position: 'rear',
    enabled: false,
  });

  assert.deepEqual(commands, ['EEPSetTrainCouplingFront|#Train-1|true', 'EEPSetTrainCouplingRear|#Train-1|false']);
}

function testSetTrainLightQueuesValidatedLightCommand(): void {
  const { commands, handlers } = setupCommandHandlers();

  handlers.get(CommandEvent.SetTrainLight)?.({
    trainName: '#Train-1',
    source: 2.1,
    enabled: true,
  });
  handlers.get(CommandEvent.SetTrainLight)?.({
    trainName: '#Train-1',
    source: 4,
    enabled: false,
  });

  assert.deepEqual(commands, ['EEPSetTrainLight|#Train-1|true|2']);
}

function setupCommandHandlers() {
  const commands: string[] = [];
  const handlers = new Map<string, (action: unknown) => void>();
  const socket = {
    on: (eventName: string, handler: (action: unknown) => void) => {
      handlers.set(eventName, handler);
    },
  };
  const socketService = {
    addOnSocketConnectedCallback: (callback: (connectedSocket: typeof socket) => void) => callback(socket),
    ensureApprovedSocket: () => true,
  };
  const eepService = {
    queueCommand: (command: string) => commands.push(command),
  };

  registerCommandMod({} as never, socketService as never, eepService as never, false);
  return { commands, handlers };
}

export async function run(): Promise<void> {
  await runTest(
    'set rolling stock axis queues number command when axis names are unknown',
    testSetRollingStockAxisQueuesNumberCommandWhenAxisNamesAreUnknown,
  );
  await runTest(
    'set rolling stock axis queues name command when axis names are known',
    testSetRollingStockAxisQueuesNameCommandWhenAxisNamesAreKnown,
  );
  await runTest(
    'set train speed queues clamped target-speed command',
    testSetTrainSpeedQueuesClampedTargetSpeedCommand,
  );
  await runTest('set train coupling queues front and rear commands', testSetTrainCouplingQueuesFrontAndRearCommands);
  await runTest('set train light queues validated light command', testSetTrainLightQueuesValidatedLightCommand);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
