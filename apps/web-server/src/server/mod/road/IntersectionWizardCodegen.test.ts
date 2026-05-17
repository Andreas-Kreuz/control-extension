import * as assert from 'node:assert/strict';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import * as os from 'node:os';
import * as path from 'node:path';
import { createDraftFromCurrentIntersection, generateIntersectionWizardLua } from './IntersectionWizardCodegen';
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
        signalId: '101',
        turnDirections: ['STRAIGHT'],
      },
      {
        id: 'lane-2',
        name: 'FS2',
        signalId: '-1',
        turnDirections: ['LEFT'],
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
        signalId: '-1',
        use: 'VEHICLE_ONLY',
        trafficType: 'TRAM',
        modelName: 'MA1_STRAB_3er_2_gruen',
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
        name: 'SG Geradeaus',
        laneIds: ['lane-1'],
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        ampelIds: ['ampel-101'],
      },
      {
        id: 'sg-2',
        name: 'SG Tram Links',
        laneIds: ['lane-2'],
        turnDirections: ['LEFT'],
        trafficType: 'TRAM',
        ampelIds: ['ampel-102'],
      },
    ],
    phases: [{ id: 'phase-1', name: 'P1', signalGroupIds: ['sg-1', 'sg-2'] }],
    generatedLua: '',
  };
}

function testCodegenCreatesIntersectionSetup(): void {
  const { lua, warnings } = generateIntersectionWizardLua(makeDraft());

  assert.equal(warnings.length, 0);
  assert.match(lua, /\n-- START Kreuzung bahnhofHaupt \(Bahnhofstraße - Hauptstraße\)\ndo\n/);
  assert.match(lua, /TrafficLight:new\("K1", 101, TrafficLightModel\.JS2_3er_mit_FG\)/);
  assert.match(lua, /local K1 = TrafficLight:new\("K1", 101, TrafficLightModel\.JS2_3er_mit_FG\)/);
  assert.match(
    lua,
    /local S1 = TrafficLight:newPlainLightStructure\("S1", "#2_Rot", "#2_Gruen", "#2_Gelb", "#2_Anforderung"\)/,
  );
  assert.match(lua, /:addLightStructure\("#1_Rot",\n\s+"#1_Gruen",\n\s+"#1_Gelb",\n\s+"#1_Anforderung"\n\s+\)/);
  assert.match(
    lua,
    /bahnhofHauptLane1 = Lane:new\("FS1", K1\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.STRAIGHT\)/,
  );
  assert.match(
    lua,
    /Intersection:new\("Bahnhofstraße - Hauptstraße"\)\n\s+:scriptVariableName\("bahnhofHaupt"\)\n\s+:withStorage\(42\)/,
  );
  assert.match(lua, /:setSwitchInStrictOrder\(true\)/);
  assert.match(lua, /newSignalGroup\("SG Geradeaus"\)\n\s+:addVehicleSignals\(K1\)/);
  assert.match(lua, /newSignalGroup\("SG Tram Links"\)\n\s+:addTramSignals\(S1\)/);
  assert.match(lua, /bahnhofHaupt:addStaticCam\("K1 Verkehrsueberwachung"\)/);
  assert.match(lua, /bahnhofHaupt:newPhase\("P1"\)\n\s+:addSignalGroup\(\n\s+SG_Geradeaus,\n\s+SG_Tram_Links\n\s+\)/);
  assert.match(lua, /\nend\n-- END Kreuzung bahnhofHaupt \(Bahnhofstraße - Hauptstraße\)$/);
}

function testCodegenKeepsPositiveSignalIdForLightStructureAmpel(): void {
  const draft = makeDraft();
  draft.ampeln = [
    {
      id: 'ampel-108',
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
    },
  ];
  draft.lanes = [
    {
      id: 'lane-1',
      name: 'FS1',
      signalId: '108',
      turnDirections: ['LEFT'],
    },
  ];
  draft.signalGroups = [
    {
      id: 'sg-1',
      name: 'SG Tram',
      laneIds: ['lane-1'],
      turnDirections: ['LEFT'],
      trafficType: 'TRAM',
      ampelIds: ['ampel-108'],
    },
  ];

  const { lua } = generateIntersectionWizardLua(draft);

  assert.match(lua, /local S1 = TrafficLight:new\("S1", 108, TrafficLightModel\.Unsichtbar_2er\)/);
  assert.match(lua, /:addLightStructure\("#5537_Straba Signal Halt",/);
  assert.doesNotMatch(lua, /newPlainLightStructure\("S1"/);
  assert.match(
    lua,
    /Lane:new\("FS1", S1\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.LEFT\)\n\s+:setTrafficType\(Lane\.Type\.TRAM\)/,
  );
}

function testCodegenWarnsForMultipleGroupsOnOneLane(): void {
  const draft = makeDraft();
  draft.signalGroups.push({
    id: 'sg-3',
    name: 'SG Rechts',
    laneIds: ['lane-1'],
    turnDirections: ['RIGHT'],
    trafficType: 'CAR',
    ampelIds: ['ampel-101'],
  });

  const { warnings } = generateIntersectionWizardLua(draft);

  assert.deepEqual(warnings, [
    'FS1: Mehrere Signalgruppen erfordern eine eigene unsichtbare Ampel als Fahrspur-Ampel.',
  ]);
}

function testCodegenCreatesMultipleDefaultSignalGroupsOnOneLane(): void {
  const draft = makeDraft();
  draft.signalGroups.push({
    id: 'sg-3',
    name: 'SG Rechts',
    laneIds: ['lane-1'],
    turnDirections: ['RIGHT'],
    trafficType: 'CAR',
    ampelIds: ['ampel-101'],
  });

  const { lua } = generateIntersectionWizardLua(draft);

  assert.match(lua, /bahnhofHauptLane1:driveOnDefaultSignalGroups\(SG_Geradeaus, SG_Rechts\)/);
}

function testCodegenCreatesRouteSpecificSignalGroupRules(): void {
  const draft = makeDraft();
  draft.signalGroups[1]!.laneIds = [];
  draft.routeRules = [
    {
      id: 'route-rule-1',
      laneId: 'lane-2',
      routeNames: ['Tram 11 Heiderand', 'Tram 11 Rehfeld'],
      signalGroupIds: ['sg-2'],
      mode: 'ONLY',
      showRequests: true,
    },
  ];

  const { lua } = generateIntersectionWizardLua(draft);

  assert.match(
    lua,
    /bahnhofHauptLane2:routes\("Tram 11 Heiderand", "Tram 11 Rehfeld"\)\n\s+:driveOnlyOnSignalGroups\(SG_Tram_Links\)\n\s+:showRequestsOnSignalGroups\(SG_Tram_Links\)/,
  );
}

function testCodegenCreatesAlsoDriveRouteSpecificSignalGroupRules(): void {
  const draft = makeDraft();
  draft.signalGroups[1]!.laneIds = [];
  draft.routeRules = [
    {
      id: 'route-rule-1',
      laneId: 'lane-2',
      routeNames: ['Tram 11 Heiderand'],
      signalGroupIds: ['sg-2'],
      mode: 'ALSO',
      showRequests: true,
    },
  ];

  const { lua } = generateIntersectionWizardLua(draft);

  assert.match(
    lua,
    /bahnhofHauptLane2:routes\("Tram 11 Heiderand"\)\n\s+:driveAlsoOnSignalGroups\(SG_Tram_Links\)\n\s+:showRequestsOnSignalGroups\(SG_Tram_Links\)/,
  );
}

function testCodegenCreatesCompleteLaneSignalFromLaneSignalId(): void {
  const draft = makeDraft();
  draft.ampeln = [];
  draft.lanes = [
    {
      id: 'lane-1',
      name: 'FS1',
      signalId: '101',
      turnDirections: ['STRAIGHT'],
    },
  ];
  draft.signalGroups = [];
  draft.phases = [];

  const { lua } = generateIntersectionWizardLua(draft);

  assert.match(
    lua,
    /local FS1Signal = TrafficLight:new\("FS1Signal", 101, TrafficLightModel\.Unsichtbar_2er\)/,
  );
  assert.match(
    lua,
    /bahnhofHauptLane1 = Lane:new\("FS1", FS1Signal\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.STRAIGHT\)/,
  );
  assert.doesNotMatch(lua, /Lane:new\("FS1", nil/);
}

function testCodegenCreatesPedestrianCrossings(): void {
  const draft = makeDraft();
  draft.ampeln.push({
    id: 'ampel-ped-1',
    name: 'F1',
    signalId: '201',
    use: 'PEDESTRIAN_ONLY',
    trafficType: 'PEDESTRIAN',
    modelName: 'JS2_2er_nur_FG',
    modelConstant: 'JS2_2er_nur_FG',
  });
  draft.signalGroups.push({
    id: 'sg-ped-1',
    name: 'sgPedCrossingNorth1',
    laneIds: [],
    turnDirections: ['STRAIGHT'],
    trafficType: 'PEDESTRIAN',
    ampelIds: ['ampel-ped-1'],
  });
  draft.pedestrianCrossings = [
    {
      id: 'ped-crossing-1',
      name: 'pedCrossingNorth1',
      luaVariableName: 'c1PedCrossingNorth1',
      approach: 'SOUTH',
      signalGroupId: 'sg-ped-1',
    },
  ];

  const { lua } = generateIntersectionWizardLua(draft);

  assert.match(lua, /local PedestrianCrossing = require\("ce\.mods\.road\.PedestrianCrossing"\)/);
  assert.match(
    lua,
    /c1PedCrossingNorth1 = PedestrianCrossing:new\("pedCrossingNorth1"\)\n\s+:scriptVariableName\("c1PedCrossingNorth1"\)\n\s+:setApproach\(PedestrianCrossing\.Approach\.SOUTH\)/,
  );
  assert.match(
    lua,
    /newSignalGroup\("sgPedCrossingNorth1"\)\n\s+:addPedestrianCrossing\(c1PedCrossingNorth1\)\n\s+:addPedestrianSignals\(F1\)/,
  );
}

function testCurrentIntersectionDraftKeepsLaneSignalIds(): void {
  const intersection: IntersectionAppDto = {
    id: 1,
    name: 'Bahnhofstraße - Hauptstraße',
    scriptVariableName: 'c1',
    eepSaveId: 77,
    currentPhase: 'P1',
    manualPhase: '',
    nextPhase: '',
    ready: true,
    greenTimeSeconds: 12,
    tippStructure: '#5573_Schaltschrank-Ampel2_SK2',
    staticCams: [],
    switchInStrictOrder: true,
    signalGroupDefinitions: [{ name: 'SG Spur 4 Rechts', trafficType: 'CAR', signalIds: [89] }],
    phases: [
      {
        id: '1-P1',
        name: 'P1',
        order: 1,
        prio: 0,
        greenTimeSeconds: 12,
        signalGroups: ['SG Spur 4 Rechts'],
        signalHeads: [
          {
            signalId: 89,
            signalHeadKind: 'VEHICLE',
            signalHeadKey: '89:VEHICLE',
            signalHeadName: 'lane4Sig',
            type: 'CAR',
            vehicleSignalHeadName: 'lane4Sig',
            use: 'VEHICLE_ONLY',
          },
        ],
      },
    ],
  };
  const lanes: IntersectionLaneAppDto[] = [
    {
      id: '1-Spur 4',
      intersectionId: 1,
      name: 'Spur 4',
      currentIndication: 'RED',
      vehicleMultiplier: 15,
      laneSignalId: 89,
      type: 'NORMAL',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['STRAIGHT', 'RIGHT'],
      phases: ['P1'],
      defaultSignalGroups: ['SG Spur 4 Rechts'],
      tracks: [],
    },
  ];
  const ampeln: IntersectionTrafficLightAppDto[] = [
    {
      id: 89,
      signalId: 89,
      vehicleSignalName: 'lane4Sig',
      use: 'VEHICLE_ONLY',
      modelId: 'Unsichtbar_2er',
      currentIndication: 'RED',
      intersectionId: 1,
      lightStructures: {},
      axisStructures: [],
    },
  ];

  const draft = createDraftFromCurrentIntersection(intersection, lanes, ampeln);
  const importedLane = draft.lanes[0];

  assert.ok(importedLane);
  assert.equal(importedLane.signalId, '89');
  assert.equal(importedLane.vehicleMultiplier, 15);
  assert.equal(draft.luaVariableName, 'c1');
  assert.equal(draft.intersectionEepSaveId, 77);
  assert.equal(draft.switchInStrictOrder, true);
  assert.match(
    draft.generatedLua,
    /local c1 = Intersection:new\("Bahnhofstraße - Hauptstraße"\)\n\s+:setTippStructure\("#5573_Schaltschrank-Ampel2_SK2"\)\n\s+:scriptVariableName\("c1"\)\n\s+:withStorage\(77\)\n\s+:setSwitchInStrictOrder\(true\)/,
  );
  assert.match(
    draft.generatedLua,
    /Lane:new\("Spur 4", lane4Sig\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.STRAIGHT, Lane\.Directions\.RIGHT\)\n\s+:setFahrzeugMultiplikator\(15\)/,
  );
}

function testCurrentIntersectionDraftLoadsC1StyleSignalGroups(): void {
  const intersection: IntersectionAppDto = {
    id: 1,
    name: 'Bahnhofstraße - Hauptstraße',
    currentPhase: 'P2',
    manualPhase: '',
    nextPhase: '',
    ready: true,
    greenTimeSeconds: 15,
    tippStructure: '#5573_Schaltschrank-Ampel2_SK2',
    staticCams: [],
    signalGroupDefinitions: [
      { name: 'sgLane4Straight', trafficType: 'CAR', signalIds: [142] },
      { name: 'sgLane4Right', trafficType: 'CAR', signalIds: [140] },
      {
        name: 'sgPedNorthSouth',
        trafficType: 'PEDESTRIAN',
        signalIds: [86, 142],
        pedestrianCrossingNames: ['Furt Nord-Sued'],
      },
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
      tracks: [],
      routeRules: [
        {
          routeNames: ['Tram 11 Heiderand', 'Tram 11 Rehfeld'],
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
      lightStructures: {},
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
      lightStructures: {},
      axisStructures: [],
    },
  ];

  const draft = createDraftFromCurrentIntersection(intersection, lanes, ampeln);

  assert.equal(draft.supportPedestrianSignals, true);
  assert.equal(draft.supportMultipleLaneSignals, true);
  assert.deepEqual(draft.pedestrianCrossings, [
    {
      id: 'ped-crossing-1',
      name: 'Furt Nord-Sued',
      luaVariableName: 'c1PedNorthSouth',
      approach: 'SOUTH',
      signalGroupId: 'sg-3',
    },
  ]);
  assert.deepEqual(
    draft.signalGroups.map((group) => ({ name: group.name, ampelIds: group.ampelIds })),
    [
      { name: 'sgLane4Straight', ampelIds: ['ampel-142'] },
      { name: 'sgLane4Right', ampelIds: ['ampel-140'] },
      { name: 'sgPedNorthSouth', ampelIds: ['ampel-142', 'ampel-86'] },
      { name: 'sgLane8Left', ampelIds: ['ampel--2'] },
    ],
  );
  assert.match(draft.generatedLua, /newSignalGroup\("sgPedNorthSouth"\)\n\s+:addPedestrianCrossing\([^)]*\)\n\s+:addPedestrianSignals\(/);
  assert.match(draft.generatedLua, /c1PedNorthSouth = PedestrianCrossing:new\("Furt Nord-Sued"\)/);
  assert.match(draft.generatedLua, /local F2 = K4:withPedestrian\("F2"\)/);
  assert.match(draft.generatedLua, /local F1 = K7:withPedestrian\("F1"\)/);
  assert.match(draft.generatedLua, /newSignalGroup\("sgPedNorthSouth"\).*:addPedestrianSignals\([^)]*F2[^)]*F1/s);
  assert.match(
    draft.generatedLua,
    /bahnhofstra_e_Hauptstra_eLane4:driveOnDefaultSignalGroups\(.*sgLane4Straight.*sgLane4Right/s,
  );
  assert.deepEqual(draft.routeRules, [
    {
      id: 'route-rule-1-1',
      laneId: 'lane-1',
      routeNames: ['Tram 11 Heiderand', 'Tram 11 Rehfeld'],
      signalGroupIds: ['sg-4'],
      mode: 'ONLY',
      showRequests: true,
    },
  ]);
  assert.match(
    draft.generatedLua,
    /bahnhofstra_e_Hauptstra_eLane4:routes\("Tram 11 Heiderand", "Tram 11 Rehfeld"\)\n\s+:driveOnlyOnSignalGroups\(sgLane8Left\)\n\s+:showRequestsOnSignalGroups\(sgLane8Left\)/,
  );
  assert.match(draft.generatedLua, /newPhase\("P2"\)\n\s+:addSignalGroup\(.*sgLane4Right.*sgLane8Left/s);
}

function testCurrentIntersectionDraftLoadsC2StyleSignalGroups(): void {
  const intersection: IntersectionAppDto = {
    id: 2,
    name: 'Bahnhofstraße - Schlossallee',
    currentPhase: 'P2a',
    manualPhase: '',
    nextPhase: '',
    ready: true,
    greenTimeSeconds: 15,
    tippStructure: '#609_Schaltschrank-Ampel2_SK2',
    staticCams: ['K2 Verkehrsüberwachung'],
    signalGroupDefinitions: [
      { name: 'sgLane3and4Straight', trafficType: 'CAR', signalIds: [106, 107, 109] },
      { name: 'sgLane5Left', trafficType: 'TRAM', signalIds: [108] },
      { name: 'sgPedDiagonal', trafficType: 'PEDESTRIAN', signalIds: [111, 112] },
    ],
    phases: [
      {
        id: '2-P2a',
        name: 'P2a',
        order: 1,
        prio: 0,
        greenTimeSeconds: 15,
        signalGroups: ['sgLane3and4Straight', 'sgPedDiagonal'],
        signalHeads: [],
      },
    ],
  };
  const lanes: IntersectionLaneAppDto[] = [
    {
      id: '2-Spur 3',
      intersectionId: 2,
      name: 'Spur 3',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 107,
      type: 'NORMAL',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['STRAIGHT', 'RIGHT'],
      phases: ['P2a'],
      defaultSignalGroups: ['sgLane3and4Straight'],
      tracks: [],
    },
    {
      id: '2-Spur 4',
      intersectionId: 2,
      name: 'Spur 4',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 106,
      type: 'NORMAL',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['STRAIGHT'],
      phases: ['P2a'],
      defaultSignalGroups: ['sgLane3and4Straight'],
      tracks: [],
    },
    {
      id: '2-Spur 5',
      intersectionId: 2,
      name: 'Spur 5',
      currentIndication: 'RED',
      vehicleMultiplier: 15,
      laneSignalId: 108,
      type: 'TRAM',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['LEFT'],
      phases: ['P2a'],
      defaultSignalGroups: ['sgLane5Left'],
      tracks: [],
    },
  ];
  const ampeln: IntersectionTrafficLightAppDto[] = [
    ...[106, 107, 109, 108].map((signalId) => ({
      id: signalId,
      signalId,
      vehicleSignalName: `K${signalId}`,
      use: 'VEHICLE_ONLY' as const,
      modelId: signalId === 108 ? 'Unsichtbar_2er' : 'JS2_3er_mit_FG',
      currentIndication: 'RED',
      intersectionId: 2,
      lightStructures: {},
      axisStructures: [],
    })),
    ...[111, 112].map((signalId) => ({
      id: signalId,
      signalId,
      pedestrianSignalName: `F${signalId}`,
      use: 'PEDESTRIAN_ONLY' as const,
      modelId: 'JS2_2er_nur_FG',
      currentIndication: 'RED',
      intersectionId: 2,
      lightStructures: {},
      axisStructures: [
        {
          structureName: `#${signalId}_Warnblink`,
          axisName: 'Blinklicht',
          positionDefault: 0,
          positionRedYellow: 50,
        },
      ],
    })),
  ];

  const draft = createDraftFromCurrentIntersection(intersection, lanes, ampeln);
  const straightGroup = draft.signalGroups.find((group) => group.name === 'sgLane3and4Straight');

  assert.equal(draft.supportPedestrianSignals, true);
  assert.equal(draft.supportMultipleLaneSignals, false);
  assert.ok(straightGroup);
  assert.deepEqual(straightGroup.laneIds, ['lane-1', 'lane-2']);
  assert.match(
    draft.generatedLua,
    /newSignalGroup\("sgLane3and4Straight"\)\n\s+:addVehicleSignals\([^)]*K106[^)]*K107[^)]*K109/s,
  );
  assert.match(draft.generatedLua, /bahnhofstra_e_SchlossalleeLane3:driveOnDefaultSignalGroups\(.*sgLane3and4Straight/s);
  assert.match(draft.generatedLua, /bahnhofstra_e_SchlossalleeLane4:driveOnDefaultSignalGroups\(.*sgLane3and4Straight/s);
  assert.match(draft.generatedLua, /newSignalGroup\("sgPedDiagonal"\)\n\s+:addPedestrianCrossing\([^)]*\)\n\s+:addPedestrianSignals\(/);
  assert.match(draft.generatedLua, /:addStaticCam\("K2 Verkehrsüberwachung"\)/);
  assert.match(
    draft.generatedLua,
    /TrafficLight:newPedestrianOnly\("F111", 111, TrafficLightModel\.JS2_2er_nur_FG\)\n\s+:addAxisStructure/,
  );
  assert.match(
    draft.generatedLua,
    /Lane:new\("Spur 5", K108\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.LEFT\)\n\s+:setTrafficType\(Lane\.Type\.TRAM\)\n\s+:setFahrzeugMultiplikator\(15\)/,
  );
  assert.match(draft.generatedLua, /newPhase\("P2a"\)\n\s+:addSignalGroup\(.*sgLane3and4Straight.*sgPedDiagonal/s);
}

function testCurrentIntersectionFallbackGroupsSignalGroupsByApproachAndTurnDirections(): void {
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
    {
      id: '3-Spur 2',
      intersectionId: 3,
      name: 'Spur 2',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 102,
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
    {
      id: '3-Spur 3',
      intersectionId: 3,
      name: 'Spur 3',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 103,
      approach: 'EAST',
      type: 'NORMAL',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['STRAIGHT'],
      phases: [],
      defaultSignalGroups: [],
      tracks: [],
    },
    {
      id: '3-Spur 4',
      intersectionId: 3,
      name: 'Spur 4',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 104,
      approach: 'NORTH_EAST',
      type: 'NORMAL',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['LEFT', 'HALF_LEFT', 'STRAIGHT'],
      phases: [],
      defaultSignalGroups: [],
      tracks: [],
    },
  ];

  const draft = createDraftFromCurrentIntersection(intersection, lanes, []);

  assert.deepEqual(
    draft.signalGroups.map((group) => ({
      name: group.name,
      laneIds: group.laneIds,
      turnDirections: group.turnDirections,
    })),
    [
      { name: 'nStraight', laneIds: ['lane-1', 'lane-2'], turnDirections: ['STRAIGHT'] },
      { name: 'eStraight', laneIds: ['lane-3'], turnDirections: ['STRAIGHT'] },
      {
        name: 'neLeftHalfLeftStraight',
        laneIds: ['lane-4'],
        turnDirections: ['LEFT', 'HALF_LEFT', 'STRAIGHT'],
      },
    ],
  );
}

function testCurrentIntersectionImportConvertsLegacyHeadingToApproach(): void {
  const intersection: IntersectionAppDto = {
    id: 4,
    name: 'Legacy Kreuzung',
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
      id: '4-Spur 1',
      intersectionId: 4,
      name: 'Spur 1',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 101,
      heading: 'NORTH',
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

  assert.equal(draft.lanes[0]?.approach, 'SOUTH');
  assert.match(draft.generatedLua, /:setApproach\(Lane\.Approach\.SOUTH\)/);
  assert.equal(draft.signalGroups[0]?.name, 'sStraight');
}

function testCurrentIntersectionImportKeepsApproachWithoutInversion(): void {
  const intersection: IntersectionAppDto = {
    id: 5,
    name: 'Approach Kreuzung',
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
      id: '5-Spur 1',
      intersectionId: 5,
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

  assert.equal(draft.lanes[0]?.approach, 'NORTH');
  assert.match(draft.generatedLua, /:setApproach\(Lane\.Approach\.NORTH\)/);
  assert.equal(draft.signalGroups[0]?.name, 'nStraight');
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
    'intersection wizard codegen keeps positive signal id for light structure Ampel',
    testCodegenKeepsPositiveSignalIdForLightStructureAmpel,
  );
  await runTest('intersection wizard codegen warns for multi-group lanes', testCodegenWarnsForMultipleGroupsOnOneLane);
  await runTest(
    'intersection wizard codegen creates multiple default signal groups on one lane',
    testCodegenCreatesMultipleDefaultSignalGroupsOnOneLane,
  );
  await runTest(
    'intersection wizard codegen creates route-specific signal group rules',
    testCodegenCreatesRouteSpecificSignalGroupRules,
  );
  await runTest(
    'intersection wizard codegen creates ALSO route-specific signal group rules',
    testCodegenCreatesAlsoDriveRouteSpecificSignalGroupRules,
  );
  await runTest(
    'intersection wizard codegen creates complete lane signal from lane signal id',
    testCodegenCreatesCompleteLaneSignalFromLaneSignalId,
  );
  await runTest(
    'intersection wizard codegen creates pedestrian crossings',
    testCodegenCreatesPedestrianCrossings,
  );
  await runTest(
    'current intersection import keeps lane signal ids',
    testCurrentIntersectionDraftKeepsLaneSignalIds,
  );
  await runTest(
    'current intersection import loads c1-style signal groups',
    testCurrentIntersectionDraftLoadsC1StyleSignalGroups,
  );
  await runTest(
    'current intersection import loads c2-style signal groups',
    testCurrentIntersectionDraftLoadsC2StyleSignalGroups,
  );
  await runTest(
    'current intersection fallback groups signal groups by approach and turn directions',
    testCurrentIntersectionFallbackGroupsSignalGroupsByApproachAndTurnDirections,
  );
  await runTest(
    'current intersection import converts legacy heading to approach',
    testCurrentIntersectionImportConvertsLegacyHeadingToApproach,
  );
  await runTest(
    'current intersection import keeps approach without inversion',
    testCurrentIntersectionImportKeepsApproachWithoutInversion,
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

