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

function testSetRollingStockAxisQueuesClampedCommand(): void {
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
  handlers.get(CommandEvent.SetRollingStockAxis)?.({
    rollingStockName: 'RS-1',
    axisNumber: 2.2,
    value: 101.7,
  });

  assert.deepEqual(commands, ['EEPRollingstockSetAxisByNumber|RS-1|2|100']);
}

export async function run(): Promise<void> {
  await runTest('set rolling stock axis queues clamped command', testSetRollingStockAxisQueuesClampedCommand);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
