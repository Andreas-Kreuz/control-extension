import * as assert from 'node:assert/strict';
import { RoadEvent } from '@ce/web-shared';
import { registerRoadMod } from './registerRoadMod';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function setupRoadHandlers() {
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

  registerRoadMod({} as never, socketService as never, eepService as never, false);
  return { commands, handlers };
}

function testAlignStructureSignalInstallerQueuesPositionRotationAndTagCommands(): void {
  const { commands, handlers } = setupRoadHandlers();

  handlers.get(RoadEvent.AlignStructureSignalInstaller)?.({
    blendName: '#3_Straba Signal Gehäuse Blendschutz 2',
    housingKind: 'MAST_2',
    housingName: '#3026_Straba Signal Gehäuse Mast 2',
    housingTag: 'F0=#1_Straba Signal Halt,F1=#2_Straba Signal geradeaus,g=#2_Straba Signal geradeaus,',
    signals: ['#1_Straba Signal Halt', '#2_Straba Signal geradeaus'],
    targets: [
      {
        name: '#1_Straba Signal Halt',
        posX: 10,
        posY: 20,
        posZ: 5.15,
        rotX: 0,
        rotY: 0,
        rotZ: 90,
      },
      {
        name: '#2_Straba Signal geradeaus',
        posX: 10,
        posY: 20,
        posZ: 4.88,
        rotX: 0,
        rotY: 0,
        rotZ: 90,
      },
    ],
  });

  assert.deepEqual(commands, [
    'Structure.setPositionByName|#1_Straba Signal Halt|10|20|5.15',
    'Structure.setRotationByName|#1_Straba Signal Halt|0|0|90',
    'Structure.setPositionByName|#2_Straba Signal geradeaus|10|20|4.88',
    'Structure.setRotationByName|#2_Straba Signal geradeaus|0|0|90',
    'Structure.setLightByName|#1_Straba Signal Halt|true',
    'Structure.setLightByName|#2_Straba Signal geradeaus|true',
    'Structure.setTagTextByName|#1_Straba Signal Halt|F0=#1_Straba Signal Halt,F1=#2_Straba Signal geradeaus,g=#2_Straba Signal geradeaus,',
    'Structure.setTagTextByName|#2_Straba Signal geradeaus|F0=#1_Straba Signal Halt,F1=#2_Straba Signal geradeaus,g=#2_Straba Signal geradeaus,',
    'Structure.setTagTextByName|#3026_Straba Signal Gehäuse Mast 2|F0=#1_Straba Signal Halt,F1=#2_Straba Signal geradeaus,g=#2_Straba Signal geradeaus,',
  ]);
}

function testAlignStructureSignalInstallerRejectsUnsafePayloads(): void {
  const { commands, handlers } = setupRoadHandlers();

  handlers.get(RoadEvent.AlignStructureSignalInstaller)?.({
    housingKind: 'MAST_1',
    housingName: '#3026|bad',
    housingTag: 'F1=#1,',
    signals: ['#1_Straba Signal geradeaus'],
    targets: [
      {
        name: '#1_Straba Signal geradeaus',
        posX: 10,
        posY: 20,
        posZ: 5.15,
        rotX: 0,
        rotY: 0,
        rotZ: 90,
      },
    ],
  });

  handlers.get(RoadEvent.AlignStructureSignalInstaller)?.({
    housingKind: 'MAST_1',
    housingName: '#3026_Straba Signal Gehäuse Mast 1',
    housingTag: 'F1=#1,',
    signals: ['#1_Straba Signal geradeaus'],
    targets: new Array(7).fill({
      name: '#1_Straba Signal geradeaus',
      posX: 10,
      posY: 20,
      posZ: 5.15,
      rotX: 0,
      rotY: 0,
      rotZ: 90,
    }),
  });

  handlers.get(RoadEvent.AlignStructureSignalInstaller)?.({
    housingKind: 'MAST_1',
    housingName: '#3026_Straba Signal Gehäuse Mast 1',
    housingTag: 'F1=#1,',
    signals: [
      '#1_Straba Signal geradeaus',
      '#2_Straba Signal geradeaus',
      '#3_Straba Signal geradeaus',
      '#4_Straba Signal geradeaus',
      '#5_Straba Signal geradeaus',
      '#6_Straba Signal geradeaus',
    ],
    targets: [
      {
        name: '#1_Straba Signal geradeaus',
        posX: 10,
        posY: 20,
        posZ: 5.15,
        rotX: 0,
        rotY: 0,
        rotZ: 90,
      },
    ],
  });

  assert.deepEqual(commands, []);
}

function testFocusStructureSignalInstallerCameraQueuesCameraCommands(): void {
  const { commands, handlers } = setupRoadHandlers();

  handlers.get(RoadEvent.FocusStructureSignalInstallerCamera)?.({
    posX: 10,
    posY: 20,
    posZ: 3,
    rotX: -5.711,
    rotY: 0,
    rotZ: 90,
  });

  assert.deepEqual(commands, ['EEPSetCameraPosition|10|20|3', 'EEPSetCameraRotation|-5.711|0|90']);
}

function testFocusStructureSignalInstallerCameraRejectsUnsafePayloads(): void {
  const { commands, handlers } = setupRoadHandlers();

  handlers.get(RoadEvent.FocusStructureSignalInstallerCamera)?.({
    posX: 10,
    posY: 20,
    posZ: Number.NaN,
    rotX: -5.711,
    rotY: 0,
    rotZ: 90,
  });

  assert.deepEqual(commands, []);
}

export async function run(): Promise<void> {
  await runTest(
    'align structure signal installer queues position rotation and tag commands',
    testAlignStructureSignalInstallerQueuesPositionRotationAndTagCommands,
  );
  await runTest(
    'align structure signal installer rejects unsafe payloads',
    testAlignStructureSignalInstallerRejectsUnsafePayloads,
  );
  await runTest(
    'focus structure signal installer camera queues camera commands',
    testFocusStructureSignalInstallerCameraQueuesCameraCommands,
  );
  await runTest(
    'focus structure signal installer camera rejects unsafe payloads',
    testFocusStructureSignalInstallerCameraRejectsUnsafePayloads,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
