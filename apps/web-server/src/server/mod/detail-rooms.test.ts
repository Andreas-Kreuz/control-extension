import * as assert from 'node:assert/strict';
import EepDataService from './eepdata/EepDataService';
import RoadDataService from './road/RoadDataService';
import TransitService from './transit/TransitService';
import {
  AuxiliaryTrackRoom,
  CeTypes,
  ContactRoom,
  IntersectionRoom,
  IntersectionLaneRoom,
  IntersectionTrafficLightRoom,
  RoadModuleSettingRoom,
  SignalRoom,
  TransitLineDetailsRoom,
  TransitLineNameRoom,
  TransitModuleSettingRoom,
  TransitStationDetailsRoom,
  TransitTrainRoom,
  detailRoomForCeType,
} from '@ce/web-shared';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function providerById(service: { getDataProviders: () => Array<{ id: string; jsonCreator: (roomName: string) => string }> }, id: string) {
  const provider = service.getDataProviders().find((entry) => entry.id === id);
  assert.ok(provider, `Expected provider ${id}`);
  return provider;
}

function testDetailRoomMappings(): void {
  assert.equal(detailRoomForCeType(CeTypes.HubSignal), SignalRoom);
  assert.equal(detailRoomForCeType(CeTypes.HubContact), ContactRoom);
  assert.equal(detailRoomForCeType(CeTypes.HubAuxiliaryTrack), AuxiliaryTrackRoom);
  assert.equal(detailRoomForCeType(CeTypes.RoadIntersection), IntersectionRoom);
  assert.equal(detailRoomForCeType(CeTypes.RoadModuleSetting), RoadModuleSettingRoom);
  assert.equal(detailRoomForCeType(CeTypes.TransitLine), TransitLineDetailsRoom);
  assert.equal(detailRoomForCeType(CeTypes.TransitLineName), TransitLineNameRoom);
  assert.equal(detailRoomForCeType(CeTypes.TransitStation), TransitStationDetailsRoom);
  assert.equal(detailRoomForCeType(CeTypes.TransitTrain), TransitTrainRoom);
  assert.equal(detailRoomForCeType(CeTypes.TransitModuleSetting), TransitModuleSettingRoom);
}

function testEepDataServiceDetailProvidersReturnSingleEntries(): void {
  const service = new EepDataService({} as never);
  service.getUpdaters()[0]?.updateFromState({
    ceTypes: {
      [CeTypes.HubSignal]: {
        S1: { id: 'S1', position: 'P1', tag: 'Tag 1', waitingVehiclesCount: 0 },
      },
      [CeTypes.HubContact]: {
        C1: { id: 'C1', luaFn: 'fn' },
      },
      [CeTypes.HubAuxiliaryTrack]: {
        T1: { id: 'T1', reserved: true },
      },
    },
  } as never);

  const signalProvider = providerById(service, 'SignalRoom');
  const contactProvider = providerById(service, 'ContactRoom');
  const auxiliaryTrackProvider = providerById(service, 'AuxiliaryTrackRoom');

  assert.deepEqual(JSON.parse(signalProvider.jsonCreator(SignalRoom.roomId('S1'))), {
    id: 'S1',
    position: 'P1',
    tag: 'Tag 1',
    waitingVehiclesCount: 0,
  });
  assert.deepEqual(JSON.parse(contactProvider.jsonCreator(ContactRoom.roomId('C1'))), {
    id: 'C1',
    luaFn: 'fn',
  });
  assert.deepEqual(JSON.parse(auxiliaryTrackProvider.jsonCreator(AuxiliaryTrackRoom.roomId('T1'))), {
    id: 'T1',
    reserved: true,
  });
}

function testRoadAndTransitDetailProvidersReturnSingleEntries(): void {
  const roadService = new RoadDataService({} as never);
  roadService.getUpdaters()[0]?.updateFromState({
    ceTypes: {
      [CeTypes.RoadIntersection]: {
        I1: { id: 1, name: 'Crossing 1' },
      },
      [CeTypes.RoadIntersectionLane]: {
        L1: {
          id: '1-L1',
          intersectionId: 1,
          name: 'Lane 1',
          phase: 'GREEN',
          vehicleMultiplier: 2,
          eepSaveId: 5,
          type: 'NORMAL',
          countType: 'TRACKS',
          waitingTrains: ['Train 1'],
          waitingForGreenCyclesCount: 4,
          directions: ['LEFT'],
          switchings: ['S1'],
          tracks: [10],
        },
      },
      [CeTypes.RoadIntersectionTrafficLight]: {
        TL1: {
          id: 2,
          signalId: 2,
          modelId: 'road',
          currentPhase: 'GREEN',
          intersectionId: 1,
          lightStructures: {
            '0': {
              structureRed: 'Red',
              structureGreen: 'Green',
              structureYellow: 'Yellow',
              structureRequest: 'Request',
            },
          },
          axisStructures: [
            {
              structureName: 'Axis',
              axisName: 'Signal',
              positionDefault: 0,
              positionRed: 1,
              positionGreen: 2,
              positionYellow: 3,
              positionPedestrian: 4,
              positionRedYellow: 5,
            },
          ],
        },
      },
      [CeTypes.RoadModuleSetting]: {
        Show: { name: 'Show', category: 'Display', description: 'Show', eepFunction: 'fn', type: 'boolean', value: true },
      },
    },
  } as never);

  const transitService = new TransitService({} as never);
  transitService.getUpdaters()[0]?.updateFromState({
    ceTypes: {
      [CeTypes.TransitLine]: {
        L1: { id: 'L1', nr: '1', trafficType: 'BUS', lineSegments: [] },
      },
      [CeTypes.TransitLineName]: {
        L1: { id: 'L1', nr: '1', trafficType: 'BUS', lineSegments: [] },
      },
      [CeTypes.TransitStation]: {
        StationA: {
          id: 'StationA',
          name: 'Station A',
          platforms: [{ nr: 1, routes: ['10'] }],
          queue: [{ trainName: 'Bus 1', line: '10', destination: 'Central', timeInMinutes: 3, platform: 1 }],
        },
      },
      [CeTypes.TransitTrain]: {
        TT1: { id: 'TT1', line: '1', destination: 'Central' },
      },
      [CeTypes.TransitModuleSetting]: {
        Next: { name: 'Next', category: 'Display', description: 'Next departures', eepFunction: 'fn', type: 'boolean', value: true },
      },
    },
  } as never);

  const intersectionProvider = providerById(roadService, 'IntersectionRoom');
  const laneProvider = providerById(roadService, 'IntersectionLaneRoom');
  const trafficLightProvider = providerById(roadService, 'IntersectionTrafficLightRoom');
  const roadModuleSettingProvider = providerById(roadService, 'RoadModuleSettingRoom');
  const lineProvider = providerById(transitService, 'TransitLineDetailsRoom');
  const lineNameProvider = providerById(transitService, 'TransitLineNameRoom');
  const stationProvider = providerById(transitService, 'TransitStationDetailsRoom');
  const trainProvider = providerById(transitService, 'TransitTrainRoom');
  const transitModuleSettingProvider = providerById(transitService, 'TransitModuleSettingRoom');

  assert.deepEqual(JSON.parse(intersectionProvider.jsonCreator(IntersectionRoom.roomId('1'))), {
    id: 1,
    name: 'Crossing 1',
    staticCams: [],
  });
  assert.deepEqual(JSON.parse(laneProvider.jsonCreator(IntersectionLaneRoom.roomId('1-L1'))), {
    id: '1-L1',
    intersectionId: 1,
    name: 'Lane 1',
    phase: 'GREEN',
    vehicleMultiplier: 2,
    eepSaveId: 5,
    type: 'NORMAL',
    countType: 'TRACKS',
    waitingTrains: ['Train 1'],
    waitingForGreenCyclesCount: 4,
    directions: ['LEFT'],
    switchings: ['S1'],
    tracks: [10],
  });
  assert.deepEqual(JSON.parse(trafficLightProvider.jsonCreator(IntersectionTrafficLightRoom.roomId('2'))), {
    id: 2,
    signalId: 2,
    modelId: 'road',
    currentPhase: 'GREEN',
    intersectionId: 1,
    lightStructures: {
      '0': {
        structureRed: 'Red',
        structureGreen: 'Green',
        structureYellow: 'Yellow',
        structureRequest: 'Request',
      },
    },
    axisStructures: [
      {
        structureName: 'Axis',
        axisName: 'Signal',
        positionDefault: 0,
        positionRed: 1,
        positionGreen: 2,
        positionYellow: 3,
        positionPedestrian: 4,
        positionRedYellow: 5,
      },
    ],
  });
  assert.deepEqual(JSON.parse(roadModuleSettingProvider.jsonCreator(RoadModuleSettingRoom.roomId('Show'))), {
    name: 'Show',
    category: 'Display',
    description: 'Show',
    eepFunction: 'fn',
    type: 'boolean',
    value: true,
  });
  assert.deepEqual(JSON.parse(lineProvider.jsonCreator(TransitLineDetailsRoom.roomId('L1'))), {
    id: 'L1',
    nr: '1',
    trafficType: 'BUS',
    lineSegments: [],
  });
  assert.deepEqual(JSON.parse(lineNameProvider.jsonCreator(TransitLineNameRoom.roomId('L1'))), {
    id: 'L1',
    nr: '1',
    trafficType: 'BUS',
    lineSegments: [],
  });
  assert.deepEqual(JSON.parse(stationProvider.jsonCreator(TransitStationDetailsRoom.roomId('StationA'))), {
    id: 'StationA',
    name: 'Station A',
    platforms: [{ nr: 1, routes: ['10'] }],
    queue: [{ trainName: 'Bus 1', line: '10', destination: 'Central', timeInMinutes: 3, platform: 1 }],
  });
  assert.deepEqual(JSON.parse(trainProvider.jsonCreator(TransitTrainRoom.roomId('TT1'))), {
    id: 'TT1',
    line: '1',
    destination: 'Central',
  });
  assert.deepEqual(JSON.parse(transitModuleSettingProvider.jsonCreator(TransitModuleSettingRoom.roomId('Next'))), {
    name: 'Next',
    category: 'Display',
    description: 'Next departures',
    eepFunction: 'fn',
    type: 'boolean',
    value: true,
  });
}

export async function run(): Promise<void> {
  await runTest('detail room mapping covers all supported ceTypes', testDetailRoomMappings);
  await runTest('eep data detail rooms return single entries', testEepDataServiceDetailProvidersReturnSingleEntries);
  await runTest('road and transit detail rooms return single entries', testRoadAndTransitDetailProvidersReturnSingleEntries);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
