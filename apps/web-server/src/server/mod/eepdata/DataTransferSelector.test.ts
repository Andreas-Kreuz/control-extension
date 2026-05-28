import * as assert from 'node:assert/strict';
import { DataTransferFieldsRoom, DataTransferSummaryRoom } from '@ce/web-shared';
import { State } from '../../eep/server-data/EepDataStore';
import EepDataService from './EepDataService';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function makeState(): State {
  return {
    eventCounter: 7,
    ceTypes: {},
    dataTransfer: {
      seenCeTypes: { 'ce.test': true },
      totals: {
        'ce.test': {
          updateCount: 3,
          initialUpdateCount: 1,
          fields: { id: 3, value: 2, other: 1 },
        },
      },
      last: {
        eventCounter: 7,
        eventType: 'DataChanged',
        ceTypes: {
          'ce.test': {
            updateCount: 1,
            initialUpdateCount: 0,
            fields: { id: 1, value: 1 },
          },
        },
      },
    },
  };
}

function testEepDataServiceProvidesDataTransferRooms(): void {
  const service = new EepDataService({} as never);
  const updater = service.getUpdaters()[0];
  assert.ok(updater);
  updater.updateFromState(makeState());

  const providers = service.getDataProviders();
  const summaryProvider = providers.find((provider) => provider.roomType === DataTransferSummaryRoom);
  const fieldsProvider = providers.find((provider) => provider.roomType === DataTransferFieldsRoom);

  assert.ok(summaryProvider);
  assert.ok(fieldsProvider);

  assert.deepEqual(JSON.parse(summaryProvider.jsonCreator(DataTransferSummaryRoom.roomId('DataTransferSummary'))), {
    eventCounter: 7,
    lastEventCounter: 7,
    lastEventType: 'DataChanged',
    ceTypes: [
      {
        ceType: 'ce.test',
        totalUpdateCount: 3,
        initialUpdateCount: 1,
        lastUpdateCount: 1,
        totalFieldUpdateCount: 6,
        lastFieldUpdateCount: 2,
      },
    ],
  });
  assert.deepEqual(JSON.parse(fieldsProvider.jsonCreator(DataTransferFieldsRoom.roomId('ce.test'))), {
    ceType: 'ce.test',
    fields: [
      { field: 'id', totalUpdateCount: 3, lastUpdateCount: 1 },
      { field: 'other', totalUpdateCount: 1, lastUpdateCount: 0 },
      { field: 'value', totalUpdateCount: 2, lastUpdateCount: 1 },
    ],
  });
}

export async function run(): Promise<void> {
  await runTest(
    'EepDataService provides data transfer summary and field rooms',
    testEepDataServiceProvidesDataTransferRooms,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
