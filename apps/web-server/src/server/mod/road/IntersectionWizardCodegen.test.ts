import * as assert from 'node:assert/strict';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import * as os from 'node:os';
import * as path from 'node:path';
import {
  createDraftFromCurrentIntersection,
  generateIntersectionWizardLua,
  signalGroupName,
} from './IntersectionWizardCodegen';
import PersistentServerStateService from './PersistentServerStateService';
import { FileNames } from '../../eep/service/FileNames';
import type {
  IntersectionAppDto,
  IntersectionLaneAppDto,
  IntersectionTrafficLightAppDto,
  IntersectionWizardDraftAppDto,
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

function makeDraft(): IntersectionWizardDraftAppDto {
  return {
    id: 'draft-1',
    name: 'Bahnhofstraße - Hauptstraße',
    luaVariableName: 'bahnhofHaupt',
    intersectionEepSaveId: 42,
    switchInStrictOrder: true,
    staticCams: ['K1 Verkehrsueberwachung'],
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
    lanes: [
      {
        id: 'lane-1',
        name: 'FS1',
        approach: 'SOUTH',
        signalSource: 'OWN',
        signal: {
          name: 'lane1Sig',
          signalId: '101',
          modelName: 'Unsichtbar_2er',
          modelConstant: 'Unsichtbar_2er',
        },
        signalGroupAssignments: [{ signalGroupId: 'sg-1', mode: 'DEFAULT' }],
      },
      {
        id: 'lane-2',
        name: 'FS2',
        approach: 'SOUTH',
        signalSource: 'SIGNAL_GROUP',
        signalGroupSignalId: 'sg-2',
        signal: {
          name: 'lane2Sig',
          modelName: 'Unsichtbar_2er',
          modelConstant: 'Unsichtbar_2er',
        },
        signalGroupAssignments: [
          { signalGroupId: 'sg-1', mode: 'DEFAULT' },
          { signalGroupId: 'sg-2', mode: 'ONLY', routeNames: ['Tram 11 Heiderand'] },
        ],
      },
    ],
    ampeln: [
      {
        id: 'ampel-101',
        name: 'K1',
        signalId: '101',
        use: 'VEHICLE_ONLY',
        trafficType: 'CAR',
        modelName: 'Ampel_3er_XXX_mit_FG',
        modelConstant: 'JS2_3er_mit_FG',
        lightStructures: [
          {
            structureRed: '#1_Rot',
            structureGreen: '#1_Gruen',
            structureYellow: '#1_Gelb',
            structureRequest: '#1_Anforderung',
          },
        ],
      },
      {
        id: 'ampel-102',
        name: 'S1',
        use: 'VEHICLE_ONLY',
        trafficType: 'TRAM',
        modelName: 'NONE',
        modelConstant: 'NONE',
        lightStructures: [
          {
            structureRed: '#2_Rot',
            structureGreen: '#2_Gruen',
            structureYellow: '#2_Gelb',
            structureRequest: '#2_Anforderung',
          },
        ],
      },
    ],
    signalGroups: [
      {
        id: 'sg-1',
        name: 'sgSouthCarStraight',
        approach: 'SOUTH',
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        showRequests: true,
        ampelIds: ['ampel-101'],
      },
      {
        id: 'sg-2',
        name: 'sgSouthTramLeft',
        approach: 'SOUTH',
        turnDirections: ['LEFT'],
        trafficType: 'TRAM',
        showRequests: true,
        ampelIds: ['ampel-102'],
      },
    ],
    phases: [{ id: 'phase-1', name: 'P1', signalGroupIds: ['sg-1', 'sg-2'] }],
    generatedLua: '',
  };
}

function testCodegenCreatesIntersectionSetup(): void {
  const { lua, warnings } = generateIntersectionWizardLua(makeDraft());
  const kreuzungIndex = lua.indexOf('-- Kreuzung');
  const ampelnIndex = lua.indexOf('-- Ampeln');

  assert.equal(warnings.length, 0);
  assert.ok(kreuzungIndex > 0 && ampelnIndex > kreuzungIndex);
  assert.match(lua, /\n-- START Kreuzung bahnhofHaupt \(Bahnhofstraße - Hauptstraße\)\ndo\n/);
  assert.match(
    lua,
    /local bahnhofHaupt = Intersection:new\("Bahnhofstraße - Hauptstraße"\)\n\s+:scriptVariableName\("bahnhofHaupt"\)\n\s+:withStorage\(42\)/,
  );
  assert.match(lua, /:setSwitchInStrictOrder\(true\)/);
  assert.match(lua, /local K1 = TrafficLight:new\("K1", 101, TrafficLightModel\.JS2_3er_mit_FG\)/);
  assert.match(
    lua,
    /local K1Light1 = TrafficLight:newPlainLightStructure\("K1Light1",\n\s+"#1_Rot",\n\s+"#1_Gruen",\n\s+"#1_Gelb",\n\s+"#1_Anforderung"\n\s+\)/,
  );
  assert.match(
    lua,
    /local S1 = TrafficLight:newPlainLightStructure\("S1",\n\s+"#2_Rot",\n\s+"#2_Gruen",\n\s+"#2_Gelb",\n\s+"#2_Anforderung"\n\s+\)/,
  );
  assert.match(lua, /local lane1Sig = TrafficLight:new\("lane1Sig", 101, TrafficLightModel\.Unsichtbar_2er\)/);
  assert.match(lua, /local sgSouthCarStraight = bahnhofHaupt\n\s+:newSignalGroup\("sgSouthCarStraight"\)\n\s+:addVehicleSignals\(K1, K1Light1\)/);
  assert.match(lua, /local sgSouthTramLeft = bahnhofHaupt\n\s+:newSignalGroup\("sgSouthTramLeft"\)\n\s+:addTramSignals\(S1\)/);
  assert.match(
    lua,
    /bahnhofHauptLane1 = Lane:new\("FS1", lane1Sig\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.STRAIGHT\)/,
  );
  assert.match(
    lua,
    /bahnhofHauptLane2 = Lane:new\("FS2", S1\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.STRAIGHT, Lane\.Directions\.LEFT\)\n\s+:setTrafficType\(Lane\.Type\.TRAM\)/,
  );
  assert.match(
    lua,
    /bahnhofHauptLane1:driveOnDefaultSignalGroups\(sgSouthCarStraight\)\n\s+:showRequestsOnSignalGroups\(sgSouthCarStraight\)/,
  );
  assert.match(
    lua,
    /bahnhofHauptLane2:routes\("Tram 11 Heiderand"\)\n\s+:driveOnlyOnSignalGroups\(sgSouthTramLeft\)\n\s+:showRequestsOnSignalGroups\(sgSouthTramLeft\)/,
  );
  assert.match(lua, /bahnhofHaupt:addStaticCam\("K1 Verkehrsueberwachung"\)/);
  assert.match(lua, /bahnhofHaupt:newPhase\("P1"\)\n\s+:addSignalGroup\(\n\s+sgSouthCarStraight,\n\s+sgSouthTramLeft/);
}

function testSignalGroupNameOrdersDirectionsLeftToRight(): void {
  assert.equal(
    signalGroupName('SOUTH', 'CAR', ['RIGHT', 'LEFT', 'HALF_RIGHT', 'STRAIGHT', 'HALF_LEFT']),
    'sgSouthCarLeftHalfLeftStraightHalfRightRight',
  );
}

function testCodegenCreatesDedicatedPlainLightForAttachedLightStructure(): void {
  const draft = makeDraft();
  draft.ampeln[1] = {
    id: 'ampel-102',
    name: 'S1',
    signalId: '108',
    use: 'VEHICLE_ONLY',
    trafficType: 'TRAM',
    modelName: 'Unsichtbar_2er',
    modelConstant: 'Unsichtbar_2er',
    lightStructures: [
      {
        structureRed: '#5537_Straba Signal Halt',
        structureGreen: '#5538_Straba Signal links',
        structureYellow: '#5539_Straba Signal anhalten',
        structureRequest: '#5540_Straba Signal A',
      },
    ],
  };

  const { lua } = generateIntersectionWizardLua(draft);

  assert.match(lua, /local S1 = TrafficLight:new\("S1", 108, TrafficLightModel\.Unsichtbar_2er\)/);
  assert.match(
    lua,
    /local S1Light1 = TrafficLight:newPlainLightStructure\("S1Light1",\n\s+"#5537_Straba Signal Halt",\n\s+"#5538_Straba Signal links",\n\s+"#5539_Straba Signal anhalten",\n\s+"#5540_Straba Signal A"\n\s+\)/,
  );
  assert.doesNotMatch(lua, /:addLightStructure\(/);
  assert.match(lua, /bahnhofHaupt\n\s+:newSignalGroup\("sgSouthTramLeft"\)\n\s+:addTramSignals\(S1, S1Light1\)/);
}

function testCodegenWarnsForMultipleGroupsWithoutDefault(): void {
  const draft = makeDraft();
  draft.lanes[1]!.signalGroupAssignments = [
    { signalGroupId: 'sg-1', mode: 'ONLY', routeNames: ['A'] },
    { signalGroupId: 'sg-2', mode: 'ALSO', routeNames: ['B'] },
  ];

  const { warnings } = generateIntersectionWizardLua(draft);

  assert.deepEqual(warnings, ['FS2: Mehrere Signalgruppen erfordern mindestens eine Standard-Signalgruppe.']);
}

function testCodegenCreatesPedestrianCrossings(): void {
  const draft = makeDraft();
  draft.ampeln.push(
    {
      id: 'ampel-ped-1',
      name: 'F1',
      signalId: '201',
      use: 'PEDESTRIAN_ONLY',
      trafficType: 'PEDESTRIAN',
      modelName: 'JS2_2er_nur_FG',
      modelConstant: 'JS2_2er_nur_FG',
    },
    {
      id: 'ampel-ped-2',
      name: 'F2',
      signalId: '202',
      use: 'PEDESTRIAN_ONLY',
      trafficType: 'PEDESTRIAN',
      modelName: 'JS2_2er_nur_FG',
      modelConstant: 'JS2_2er_nur_FG',
    },
  );
  draft.signalGroups.push({
    id: 'sg-ped-1',
    name: 'sgNorthPed',
    approach: 'NORTH',
    turnDirections: [],
    trafficType: 'PEDESTRIAN',
    showRequests: false,
    pedestrianCrossingName: 'Furt Nord',
    pedestrianCrossingLuaVariableName: 'c1PedNorth',
    ampelIds: ['ampel-ped-1', 'ampel-ped-2'],
  });

  const { lua } = generateIntersectionWizardLua(draft);

  assert.match(
    lua,
    /c1PedNorth = PedestrianCrossing:new\("Furt Nord"\)\n\s+:scriptVariableName\("c1PedNorth"\)\n\s+:setApproach\(PedestrianCrossing\.Approach\.NORTH\)/,
  );
  assert.match(
    lua,
    /newSignalGroup\("sgNorthPed"\)\n\s+:addPedestrianCrossing\(c1PedNorth\)\n\s+:addPedestrianSignals\(F1, F2\)/,
  );
}

function testCurrentIntersectionDraftKeepsImportedLanesWithoutFallbackDefaults(): void {
  const intersection: IntersectionAppDto = {
    id: 3,
    name: 'Neue Kreuzung',
    currentPhase: '',
    manualPhase: '',
    nextPhase: '',
    ready: true,
    greenTimeSeconds: 0,
    staticCams: [],
    signalGroupDefinitions: [],
    phases: [],
  };
  const lanes: IntersectionLaneAppDto[] = [
    {
      id: '3-Spur 1',
      intersectionId: 3,
      name: 'Spur 1',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 101,
      approach: 'NORTH',
      type: 'NORMAL',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['STRAIGHT'],
      phases: [],
      defaultSignalGroups: [],
      tracks: [],
    },
  ];

  const draft = createDraftFromCurrentIntersection(intersection, lanes, []);

  assert.equal(draft.lanes.length, 1);
  assert.equal(draft.signalGroups.length, 0);
  assert.deepEqual(draft.lanes[0]?.signalGroupAssignments, []);
}

function testCurrentIntersectionDraftLoadsHohenfurtStyleSignalGroups(): void {
  const intersection: IntersectionAppDto = {
    id: 1,
    name: 'Bahnhofstraße - Hauptstraße',
    currentPhase: 'P2',
    manualPhase: '',
    nextPhase: '',
    ready: true,
    greenTimeSeconds: 15,
    staticCams: [],
    signalGroupDefinitions: [
      { name: 'sgLane4Straight', trafficType: 'CAR', signalIds: [142] },
      { name: 'sgLane4Right', trafficType: 'CAR', signalIds: [140] },
      { name: 'sgPedNorthSouth', trafficType: 'PEDESTRIAN', signalIds: [86, 142] },
      { name: 'sgLane8Left', trafficType: 'TRAM', signalIds: [-2] },
    ],
    pedestrianCrossings: [
      {
        name: 'Furt Nord-Sued',
        scriptVariableName: 'c1PedNorthSouth',
        heading: 'NORTH',
        signalGroups: ['sgPedNorthSouth'],
      },
    ],
    phases: [
      {
        id: '1-P2',
        name: 'P2',
        order: 1,
        prio: 0,
        greenTimeSeconds: 15,
        signalGroups: ['sgLane4Right', 'sgLane8Left'],
        signalHeads: [],
      },
    ],
  };
  const lanes: IntersectionLaneAppDto[] = [
    {
      id: '1-Spur 4',
      intersectionId: 1,
      name: 'Spur 4',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 89,
      type: 'NORMAL',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['STRAIGHT', 'RIGHT'],
      phases: ['P2'],
      defaultSignalGroups: ['sgLane4Straight', 'sgLane4Right'],
      defaultRequestSignalGroups: ['sgLane4Right'],
      tracks: [],
    },
    {
      id: '1-Spur 8',
      intersectionId: 1,
      name: 'Spur 8',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 88,
      type: 'TRAM',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['LEFT'],
      phases: ['P2'],
      defaultSignalGroups: [],
      tracks: [],
      routeRules: [
        {
          routeNames: ['Tram 11 Heiderand'],
          signalGroups: ['sgLane8Left'],
          mode: 'ONLY',
          showRequests: true,
        },
      ],
    },
  ];
  const ampeln: IntersectionTrafficLightAppDto[] = [
    {
      id: 142,
      signalId: 142,
      vehicleSignalName: 'K4',
      pedestrianSignalName: 'F2',
      use: 'VEHICLE_AND_PEDESTRIAN',
      modelId: 'JS2_3er_mit_FG',
      currentIndication: 'RED',
      intersectionId: 1,
      lightStructures: {},
      axisStructures: [],
    },
    {
      id: 140,
      signalId: 140,
      vehicleSignalName: 'K5',
      use: 'VEHICLE_ONLY',
      modelId: 'JS2_2er_OFF_YELLOW_GREEN',
      currentIndication: 'RED',
      intersectionId: 1,
      lightStructures: {
        '0': {
          structureRed: '#140_Rot',
          structureGreen: '#140_Gruen',
          structureYellow: '#140_Gelb',
          structureRequest: '#140_Anforderung',
        },
      },
      axisStructures: [],
    },
    {
      id: 86,
      signalId: 86,
      vehicleSignalName: 'K7',
      pedestrianSignalName: 'F1',
      use: 'VEHICLE_AND_PEDESTRIAN',
      modelId: 'JS2_3er_mit_FG',
      currentIndication: 'RED',
      intersectionId: 1,
      lightStructures: {},
      axisStructures: [],
    },
    {
      id: -2,
      signalId: -2,
      vehicleSignalName: 'S3',
      use: 'VEHICLE_ONLY',
      modelId: 'NONE',
      currentIndication: 'RED',
      intersectionId: 1,
      lightStructures: {
        '0': {
          structureRed: '#2_Rot',
          structureGreen: '#2_Gruen',
          structureYellow: '#2_Gelb',
          structureRequest: '#2_Anforderung',
        },
      },
      axisStructures: [],
    },
  ];

  const draft = createDraftFromCurrentIntersection(intersection, lanes, ampeln);

  assert.equal(draft.supportPedestrianSignals, true);
  assert.equal(draft.supportMultipleLaneSignals, true);
  assert.equal(draft.supportStructureLightSignals, true);
  assert.deepEqual(
    draft.signalGroups.map((group) => ({
      name: group.name,
      ampelIds: group.ampelIds,
      showRequests: group.showRequests,
    })),
    [
      { name: 'sgSouthCarStraightRight', ampelIds: ['ampel-142'], showRequests: false },
      { name: 'sgSouthCarStraightRight2', ampelIds: ['ampel-140', 'ampel-140-light-1'], showRequests: true },
      { name: 'sgSouthPed', ampelIds: ['ampel-86', 'ampel-142'], showRequests: false },
      { name: 'sgSouthTramLeft', ampelIds: ['ampel--2'], showRequests: false },
    ],
  );
  assert.deepEqual(draft.lanes[0]?.signalGroupAssignments, [
    { signalGroupId: 'sg-1', mode: 'DEFAULT' },
    { signalGroupId: 'sg-2', mode: 'DEFAULT' },
  ]);
  assert.deepEqual(draft.lanes[1]?.signalGroupAssignments, [
    { signalGroupId: 'sg-4', mode: 'ONLY', routeNames: ['Tram 11 Heiderand'] },
  ]);
  assert.match(draft.generatedLua, /local S3 = TrafficLight:newPlainLightStructure\("S3"/);
  assert.match(draft.generatedLua, /local K5Light1 = TrafficLight:newPlainLightStructure\("K5Light1"/);
  assert.doesNotMatch(draft.generatedLua, /:addLightStructure\(/);
  assert.match(
    draft.generatedLua,
    /bahnhofstra_e_Hauptstra_eLane8:routes\("Tram 11 Heiderand"\)\n\s+:driveOnlyOnSignalGroups\(sgSouthTramLeft\)/,
  );
  assert.match(draft.generatedLua, /c1PedNorthSouth = PedestrianCrossing:new\("Furt Nord-Sued"\)/);
}

async function testPersistentServerStatePreservesOtherKeys(): Promise<void> {
  const dir = await mkdtemp(path.join(os.tmpdir(), 'ce-wizard-'));
  try {
    const fileName = path.join(dir, FileNames.persistentServerState);
    await writeFile(fileName, JSON.stringify({ other: { keep: true } }), { encoding: 'utf8' });
    const service = new PersistentServerStateService(
      () => dir,
      () => ({ drafts: {} }),
    );

    service.writeWizardState({ drafts: { 'draft-1': makeDraft() } });

    const stored = JSON.parse(await readFile(fileName, { encoding: 'utf8' }));
    assert.deepEqual(stored.other, { keep: true });
    assert.equal(stored.intersectionWizard.drafts['draft-1'].name, 'Bahnhofstraße - Hauptstraße');
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

async function testPersistentServerStateRecoversFromCorruptJson(): Promise<void> {
  const dir = await mkdtemp(path.join(os.tmpdir(), 'ce-wizard-'));
  try {
    await writeFile(path.join(dir, FileNames.persistentServerState), '{ nope', { encoding: 'utf8' });
    const service = new PersistentServerStateService(
      () => dir,
      () => ({ drafts: {} }),
    );

    assert.deepEqual(service.readWizardState(), { drafts: {} });
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

export async function run(): Promise<void> {
  await runTest('intersection wizard codegen creates setup Lua', testCodegenCreatesIntersectionSetup);
  await runTest(
    'intersection wizard signal group names order directions left to right',
    testSignalGroupNameOrdersDirectionsLeftToRight,
  );
  await runTest(
    'intersection wizard codegen creates dedicated plain light for attached light structure',
    testCodegenCreatesDedicatedPlainLightForAttachedLightStructure,
  );
  await runTest(
    'intersection wizard codegen warns for multi-group lanes without default',
    testCodegenWarnsForMultipleGroupsWithoutDefault,
  );
  await runTest('intersection wizard codegen creates pedestrian crossings', testCodegenCreatesPedestrianCrossings);
  await runTest(
    'current intersection import keeps imported lanes without fallback defaults',
    testCurrentIntersectionDraftKeepsImportedLanesWithoutFallbackDefaults,
  );
  await runTest(
    'current intersection import loads Hohenfurt-style signal groups',
    testCurrentIntersectionDraftLoadsHohenfurtStyleSignalGroups,
  );
  await runTest('persistent server state preserves other keys', testPersistentServerStatePreservesOtherKeys);
  await runTest('persistent server state recovers from corrupt JSON', testPersistentServerStateRecoversFromCorruptJson);
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
