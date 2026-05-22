import * as assert from 'node:assert/strict';
import * as fs from 'node:fs';
import * as path from 'node:path';
import RoadDataService from './road/RoadDataService';
import TransitService from './transit/TransitService';
import {
  CeTypes,
  CeTypeRoom,
  IntersectionListRoom,
  RoadTrafficLightModelsRoom,
  TransitLineListRoom,
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

function providerById(
  service: { getDataProviders: () => Array<{ id: string; jsonCreator: (roomName: string) => string }> },
  id: string,
) {
  const provider = service.getDataProviders().find((entry) => entry.id === id);
  assert.ok(provider, `Expected provider ${id}`);
  return provider;
}

function getFilesRecursive(dir: string): string[] {
  const files: string[] = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...getFilesRecursive(fullPath));
    } else if (/\.(ts|tsx)$/.test(entry.name)) {
      files.push(fullPath);
    }
  }
  return files;
}

function testCeTypeRoomIsDynamic(): void {
  const room = new CeTypeRoom(CeTypes.TransitStation);
  const roomId = room.roomId('StationA');

  assert.deepEqual(CeTypeRoom.parseRoomId(roomId), {
    ceType: CeTypes.TransitStation,
    entryId: 'StationA',
  });
  assert.equal(room.eventId('StationA'), "[DataChange - ce.mods.transit.Station: 'StationA']");
}

function testDomainRoomRegistryIsMinimal(): void {
  const registryPath = path.resolve(process.cwd(), 'apps/web-shared/src/rooms/DomainRoomRegistry.ts');
  const source = fs.readFileSync(registryPath, 'utf8');

  assert.equal(source.includes('CeTypes'), false, 'DomainRoomRegistry must not statically map CeTypes');
  assert.equal(source.includes('ApiNames'), false, 'DomainRoomRegistry must not wrap CeTypes via API name aliases');
  assert.equal(
    source.includes('detailRoomForCeType'),
    false,
    'DomainRoomRegistry must not expose static ceType mapping',
  );
}

function testApiNameAliasesRemoved(): void {
  const removedFileName = 'App' + 'ApiNames.ts';
  assert.equal(fs.existsSync(path.resolve(process.cwd(), 'apps/web-shared/src', removedFileName)), false);
}

function testCeTypeRoomIsDataFeatureOnlyInWebApp(): void {
  const appSrc = path.resolve(process.cwd(), 'apps/web-app/src');
  const allowedRoot = path.resolve(appSrc, 'features/data') + path.sep;
  const offenders = getFilesRecursive(appSrc).filter((file) => {
    const source = fs.readFileSync(file, 'utf8');
    return source.includes('CeTypeRoom') && !file.startsWith(allowedRoot);
  });

  assert.deepEqual(
    offenders.map((file) => path.relative(process.cwd(), file)),
    [],
    'CeTypeRoom may only be used by apps/web-app/src/features/data/**',
  );
}

function testAppDtoProvenanceIsServerSelectorOnly(): void {
  const appDtoRoot = path.resolve(process.cwd(), 'apps/web-shared/src/dtos/app');
  const forbiddenTerms = ['lua/LUA/', 'DtoFactory.lua', 'Produced by: lua'];
  const maxProvenanceLineLength = 120;
  const offenders: string[] = [];

  getFilesRecursive(appDtoRoot)
    .filter((file) => file.endsWith('AppDto.ts'))
    .forEach((file) => {
      const relativePath = path.relative(process.cwd(), file);
      const source = fs.readFileSync(file, 'utf8');
      const lines = source.split(/\r?\n/);

      forbiddenTerms.forEach((term) => {
        if (source.includes(term)) {
          offenders.push(`${relativePath} contains ${term}`);
        }
      });

      if (lines[0] !== '// App contract populated by:') {
        offenders.push(`${relativePath} is missing the App contract provenance header`);
      }

      if (!lines[1]?.startsWith('// apps/web-server/')) {
        offenders.push(`${relativePath} must point AppDto provenance to server code`);
      }

      for (let i = 0; i < lines.length; i += 1) {
        const line = lines[i];
        if (!line?.startsWith('//')) {
          break;
        }
        if (line.length > maxProvenanceLineLength) {
          offenders.push(`${relativePath}:${i + 1} provenance line is too long`);
        }
      }
    });

  assert.deepEqual(offenders, []);
}

function testRoadAndTransitFeatureRoomsReturnAppDtoCollections(): void {
  const roadService = new RoadDataService({} as never);
  roadService.getUpdaters()[0]?.updateFromState({
    ceTypes: {
      [CeTypes.RoadIntersection]: {
        I1: {
          id: 1,
          name: 'Crossing 1',
          currentPhase: 'P1',
          manualPhase: '',
          nextPhase: 'P2',
          ready: true,
          greenTimeSeconds: 15,
          staticCams: [],
          phases: [],
          signalGroupDefinitions: [],
        },
      },
      [CeTypes.RoadTrafficLightModel]: {
        M1: {
          id: 'Ampel_3er_XXX_mit_FG',
          name: 'Ampel_3er_XXX_mit_FG',
          type: 'road',
          positionRed: 1,
          positionGreen: 3,
          positionYellow: 5,
          positionRedYellow: 2,
          positionPedestrians: 6,
          positionOff: 7,
          positionOffBlinking: 8,
        },
        M2: {
          id: 'Ampel_2er_Aus_Gelb-Grün',
          name: 'Ampel_2er_Aus_Gelb-Grün',
          type: 'road',
          positionRed: 1,
          positionGreen: 3,
          positionYellow: 5,
          positionRedYellow: 1,
          positionPedestrians: 1,
          positionOff: 2,
          positionOffBlinking: 6,
        },
      },
    },
  } as never);

  const transitService = new TransitService({} as never);
  transitService.getUpdaters()[0]?.updateFromState({
    ceTypes: {
      [CeTypes.TransitLine]: {
        L1: { id: 'L1', nr: '1', trafficType: 'BUS', lineSegments: [] },
      },
    },
  } as never);

  const intersectionListProvider = providerById(roadService, 'IntersectionListRoom');
  const trafficLightModelsProvider = providerById(roadService, 'RoadTrafficLightModelsRoom');
  const transitLineListProvider = providerById(transitService, 'TransitLineListRoom');

  assert.deepEqual(JSON.parse(intersectionListProvider.jsonCreator(IntersectionListRoom.roomId('All'))), {
    '1': {
      id: 1,
      name: 'Crossing 1',
      eepSaveId: -1,
      currentPhase: 'P1',
      manualPhase: '',
      nextPhase: 'P2',
      ready: true,
      greenTimeSeconds: 15,
      switchInStrictOrder: false,
      staticCams: [],
      phases: [],
      signalGroupDefinitions: [],
    },
  });
  assert.deepEqual(JSON.parse(transitLineListProvider.jsonCreator(TransitLineListRoom.roomId('All'))), [
    { id: 'L1', nr: '1', trafficType: 'BUS', lineSegments: [] },
  ]);
  assert.deepEqual(JSON.parse(trafficLightModelsProvider.jsonCreator(RoadTrafficLightModelsRoom.roomId('All'))), {
    Ampel_3er_XXX_mit_FG: {
      id: 'Ampel_3er_XXX_mit_FG',
      name: 'Ampel_3er_XXX_mit_FG',
      type: 'road',
      luaConstant: 'JS2_3er_mit_FG',
      positionRed: 1,
      positionGreen: 3,
      positionYellow: 5,
      positionRedYellow: 2,
      positionPedestrians: 6,
      positionOff: 7,
      positionOffBlinking: 8,
    },
    'Ampel_2er_Aus_Gelb-Grün': {
      id: 'Ampel_2er_Aus_Gelb-Grün',
      name: 'Ampel_2er_Aus_Gelb-Grün',
      type: 'road',
      luaConstant: 'JS2_2er_gelb_gruen_aus',
      positionRed: 1,
      positionGreen: 3,
      positionYellow: 5,
      positionRedYellow: 1,
      positionPedestrians: 1,
      positionOff: 2,
      positionOffBlinking: 6,
    },
  });
}

export async function run(): Promise<void> {
  await runTest('ceType rooms are created dynamically', testCeTypeRoomIsDynamic);
  await runTest('domain room registry is minimal', testDomainRoomRegistryIsMinimal);
  await runTest('API name aliases are removed', testApiNameAliasesRemoved);
  await runTest('CeTypeRoom is only used by the Web App data feature', testCeTypeRoomIsDataFeatureOnlyInWebApp);
  await runTest('AppDto provenance points to server selectors only', testAppDtoProvenanceIsServerSelectorOnly);
  await runTest(
    'road and transit feature rooms return AppDto collections',
    testRoadAndTransitFeatureRoomsReturnAppDtoCollections,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
