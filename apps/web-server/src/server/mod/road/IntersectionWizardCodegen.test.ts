import * as assert from 'node:assert/strict';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import * as os from 'node:os';
import * as path from 'node:path';
import { CeTypes } from '@ce/web-shared';
import {
  createDraftFromCurrentIntersection,
  generateIntersectionWizardLua,
  signalGroupName,
} from './IntersectionWizardCodegen';
import PersistentServerStateService from './PersistentServerStateService';
import RoadSelector from './RoadSelector';
import type { IntersectionLuaDto } from '../../ce/dto/roads/IntersectionLuaDto';
import type { IntersectionLaneLuaDto } from '../../ce/dto/roads/IntersectionLaneLuaDto';
import type { IntersectionTrafficLightLuaDto } from '../../ce/dto/roads/IntersectionTrafficLightLuaDto';
import { FileNames } from '../../eep/service/FileNames';
import type { State } from '../../eep/server-data/EepDataStore';
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
    manualLuaVariableNames: true,
    staticCams: ['K1 Verkehrsueberwachung', 'K2 Tram-Blick'],
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

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function hohenfurtTrafficLight(
  signalId: number,
  name: string,
  modelId: string,
  options: Partial<IntersectionTrafficLightLuaDto> = {},
): IntersectionTrafficLightLuaDto {
  return {
    id: signalId,
    signalId,
    vehicleSignalName: name,
    use: 'VEHICLE_ONLY',
    modelId,
    currentIndication: 'RED',
    intersectionId: 1,
    lightStructures: {},
    axisStructures: [],
    ...options,
  };
}

function hohenfurtLane(
  name: string,
  laneSignalId: number,
  approach: string,
  directions: string[],
  defaultSignalGroups: string[],
  options: Partial<IntersectionLaneLuaDto> = {},
): IntersectionLaneLuaDto {
  return {
    id: `1-${name}`,
    intersectionId: 1,
    name,
    scriptVariableName: name === 'Spur 5a' ? 'c1Lane5a' : `c1Lane${name.replace('Spur ', '')}`,
    currentIndication: 'RED',
    vehicleMultiplier: 1,
    laneSignalId,
    approach,
    type: 'NORMAL',
    countType: 'SIGNALS',
    waitingTrains: [],
    waitingForGreenCyclesCount: 0,
    directions,
    phases: [],
    defaultSignalGroups,
    tracks: [],
    ...options,
  };
}

function makeHohenfurtC1CurrentLuaDtos(): {
  intersection: IntersectionLuaDto;
  lanes: IntersectionLaneLuaDto[];
  ampeln: IntersectionTrafficLightLuaDto[];
} {
  const intersection: IntersectionLuaDto = {
    id: 1,
    name: 'Bahnhofstraße - Hauptstraße',
    eepSaveId: 3,
    scriptVariableName: 'c1',
    tippStructure: '#5573_Schaltschrank-Ampel2_SK2',
    currentPhase: 'P2',
    manualPhase: '',
    nextPhase: '',
    ready: true,
    greenTimeSeconds: 15,
    staticCams: [
      'Kreuzung 1 - Draufsicht',
      'Kreuzung 1 - Zufahrt Nord',
      'Kreuzung 1 - Zufahrt Ost',
      'Kreuzung 1 - Zufahrt Süd',
      'Kreuzung 1 - Zufahrt West',
    ],
    signalGroupDefinitions: [
      {
        name: 'sgLane1Straight',
        scriptVariableName: 'sgLane1Straight',
        approach: 'WEST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        signalIds: [92],
      },
      {
        name: 'sgLane2Left',
        scriptVariableName: 'sgLane2Left',
        approach: 'WEST',
        turnDirections: ['LEFT'],
        trafficType: 'CAR',
        signalIds: [26, 91],
      },
      {
        name: 'sgLane3Straight',
        scriptVariableName: 'sgLane3Straight',
        approach: 'WEST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'TRAM',
        signalIds: [96],
      },
      {
        name: 'sgLane4Straight',
        scriptVariableName: 'sgLane4Straight',
        approach: 'NORTH',
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        signalIds: [142],
      },
      {
        name: 'sgLane4Right',
        scriptVariableName: 'sgLane4Right',
        approach: 'NORTH',
        turnDirections: ['RIGHT'],
        trafficType: 'CAR',
        signalIds: [140],
      },
      {
        name: 'sgLane5and5aLeft',
        scriptVariableName: 'sgLane5and5aLeft',
        approach: 'NORTH',
        turnDirections: ['LEFT'],
        trafficType: 'CAR',
        signalIds: [86, 87, 88],
      },
      {
        name: 'sgLane6Right',
        scriptVariableName: 'sgLane6Right',
        approach: 'EAST',
        turnDirections: ['RIGHT'],
        trafficType: 'CAR',
        signalIds: [85],
      },
      {
        name: 'sgLane7Straight',
        scriptVariableName: 'sgLane7Straight',
        approach: 'EAST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        signalIds: [83, 84],
      },
      {
        name: 'sgLane8Straight',
        scriptVariableName: 'sgLane8Straight',
        approach: 'EAST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'TRAM',
        signalIds: [-2],
      },
      {
        name: 'sgLane8Left',
        scriptVariableName: 'sgLane8Left',
        approach: 'EAST',
        turnDirections: ['LEFT'],
        trafficType: 'TRAM',
        signalIds: [-3],
      },
      {
        name: 'sgLane10AllDirections',
        scriptVariableName: 'sgLane10AllDirections',
        approach: 'SOUTH',
        turnDirections: ['LEFT', 'STRAIGHT', 'RIGHT'],
        trafficType: 'CAR',
        signalIds: [80, 81, 82],
      },
      {
        name: 'sgLane11Right',
        scriptVariableName: 'sgLane11Right',
        approach: 'SOUTH',
        turnDirections: ['RIGHT'],
        trafficType: 'TRAM',
        signalIds: [95],
      },
      {
        name: 'sgPedNorth',
        scriptVariableName: 'sgPedNorth',
        approach: 'NORTH',
        trafficType: 'PEDESTRIAN',
        signalIds: [86, 142],
        pedestrianCrossingNames: ['Furt Zufahrt Norden'],
      },
      {
        name: 'sgPedSouth',
        scriptVariableName: 'sgPedSouth',
        approach: 'SOUTH',
        trafficType: 'PEDESTRIAN',
        signalIds: [80, 81],
        pedestrianCrossingNames: ['Furt Zufahrt Süden'],
      },
      {
        name: 'sgPedEast',
        scriptVariableName: 'sgPedEast',
        approach: 'EAST',
        trafficType: 'PEDESTRIAN',
        signalIds: [26, 92],
        pedestrianCrossingNames: ['Furt Zufahrt Osten'],
      },
      {
        name: 'sgPedWest',
        scriptVariableName: 'sgPedWest',
        approach: 'WEST',
        trafficType: 'PEDESTRIAN',
        signalIds: [84, 94],
        pedestrianCrossingNames: ['Furt Zufahrt Westen'],
      },
    ],
    pedestrianCrossings: [
      {
        name: 'Furt Zufahrt Norden',
        scriptVariableName: 'c1PedNorth',
        approach: 'NORTH',
        signalGroups: ['sgPedNorth'],
      },
      {
        name: 'Furt Zufahrt Süden',
        scriptVariableName: 'c1PedSouth',
        approach: 'SOUTH',
        signalGroups: ['sgPedSouth'],
      },
      {
        name: 'Furt Zufahrt Osten',
        scriptVariableName: 'c1PedEast',
        approach: 'EAST',
        signalGroups: ['sgPedEast'],
      },
      {
        name: 'Furt Zufahrt Westen',
        scriptVariableName: 'c1PedWest',
        approach: 'WEST',
        signalGroups: ['sgPedWest'],
      },
    ],
    phases: [
      {
        id: '1-P1',
        name: 'P1',
        order: 1,
        prio: 0,
        greenTimeSeconds: 15,
        signalGroups: [
          'sgLane1Straight',
          'sgLane7Straight',
          'sgLane3Straight',
          'sgLane8Straight',
          'sgPedNorth',
          'sgPedSouth',
        ],
        signalHeads: [],
      },
      {
        id: '1-P1a',
        name: 'P1a',
        order: 2,
        prio: 0,
        greenTimeSeconds: 15,
        signalGroups: ['sgLane1Straight', 'sgLane6Right', 'sgLane7Straight', 'sgLane8Straight', 'sgPedSouth'],
        signalHeads: [],
      },
      {
        id: '1-P2',
        name: 'P2',
        order: 3,
        prio: 0,
        greenTimeSeconds: 15,
        signalGroups: ['sgLane2Left', 'sgLane4Right', 'sgLane11Right', 'sgLane8Left'],
        signalHeads: [],
      },
      {
        id: '1-P3',
        name: 'P3',
        order: 4,
        prio: 0,
        greenTimeSeconds: 15,
        signalGroups: ['sgLane4Straight', 'sgLane5and5aLeft', 'sgLane6Right'],
        signalHeads: [],
      },
      {
        id: '1-P3a',
        name: 'P3a',
        order: 5,
        prio: 0,
        greenTimeSeconds: 15,
        signalGroups: ['sgLane4Straight', 'sgLane10AllDirections', 'sgPedEast', 'sgPedWest'],
        signalHeads: [],
      },
      {
        id: '1-P4',
        name: 'P4',
        order: 6,
        prio: 0,
        greenTimeSeconds: 15,
        signalGroups: ['sgLane6Right', 'sgLane7Straight', 'sgLane8Straight', 'sgLane11Right'],
        signalHeads: [],
      },
      {
        id: '1-P4a',
        name: 'P4a',
        order: 7,
        prio: 0,
        greenTimeSeconds: 15,
        signalGroups: ['sgLane6Right', 'sgLane7Straight', 'sgLane8Left', 'sgLane11Right'],
        signalHeads: [],
      },
    ],
  };
  const lanes: IntersectionLaneLuaDto[] = [
    hohenfurtLane('Spur 1', 92, 'WEST', ['STRAIGHT'], ['sgLane1Straight']),
    hohenfurtLane('Spur 2', 91, 'WEST', ['LEFT'], ['sgLane2Left']),
    hohenfurtLane('Spur 3', 96, 'WEST', ['STRAIGHT'], ['sgLane3Straight'], {
      type: 'TRAM',
      defaultRequestSignalGroups: ['sgLane3Straight'],
    }),
    hohenfurtLane('Spur 4', 89, 'NORTH', ['STRAIGHT', 'RIGHT'], ['sgLane4Straight', 'sgLane4Right']),
    hohenfurtLane('Spur 5', 88, 'NORTH', ['LEFT'], ['sgLane5and5aLeft']),
    hohenfurtLane('Spur 5a', 86, 'NORTH', ['LEFT'], ['sgLane5and5aLeft']),
    hohenfurtLane('Spur 6', 85, 'EAST', ['RIGHT'], ['sgLane6Right']),
    hohenfurtLane('Spur 7', 83, 'EAST', ['STRAIGHT'], ['sgLane7Straight']),
    hohenfurtLane('Spur 8', 93, 'EAST', ['LEFT', 'STRAIGHT'], ['sgLane8Straight'], {
      vehicleMultiplier: 15,
      type: 'TRAM',
      defaultRequestSignalGroups: ['sgLane8Straight'],
      routeRules: [
        {
          routeNames: ['Tram 11 Heiderand', 'Tram 11 Rehfeld'],
          signalGroups: ['sgLane8Left'],
          mode: 'ONLY',
          showRequests: true,
        },
      ],
    }),
    hohenfurtLane('Spur 10', 80, 'SOUTH', ['LEFT', 'STRAIGHT', 'RIGHT'], ['sgLane10AllDirections']),
    hohenfurtLane('Spur 11', 95, 'SOUTH', ['RIGHT'], ['sgLane11Right'], {
      type: 'TRAM',
      defaultRequestSignalGroups: ['sgLane11Right'],
    }),
  ];
  const ampeln: IntersectionTrafficLightLuaDto[] = [
    hohenfurtTrafficLight(92, 'K1', 'JS2_3er_mit_FG', { pedestrianSignalName: 'F3', use: 'VEHICLE_AND_PEDESTRIAN' }),
    hohenfurtTrafficLight(91, 'K2', 'JS2_3er_ohne_FG'),
    hohenfurtTrafficLight(26, 'K3', 'JS2_3er_mit_FG', { pedestrianSignalName: 'F4', use: 'VEHICLE_AND_PEDESTRIAN' }),
    hohenfurtTrafficLight(142, 'K4', 'JS2_3er_mit_FG', { pedestrianSignalName: 'F2', use: 'VEHICLE_AND_PEDESTRIAN' }),
    hohenfurtTrafficLight(140, 'K5', 'JS2_2er_OFF_YELLOW_GREEN'),
    hohenfurtTrafficLight(88, 'K6', 'JS2_3er_ohne_FG'),
    hohenfurtTrafficLight(86, 'K7', 'JS2_3er_mit_FG', { pedestrianSignalName: 'F1', use: 'VEHICLE_AND_PEDESTRIAN' }),
    hohenfurtTrafficLight(87, 'K8', 'JS2_3er_ohne_FG'),
    hohenfurtTrafficLight(85, 'K9', 'JS2_3er_ohne_FG'),
    hohenfurtTrafficLight(83, 'K10', 'JS2_3er_ohne_FG'),
    hohenfurtTrafficLight(84, 'K11', 'JS2_3er_mit_FG', { pedestrianSignalName: 'F7', use: 'VEHICLE_AND_PEDESTRIAN' }),
    hohenfurtTrafficLight(80, 'K12', 'JS2_3er_mit_FG', { pedestrianSignalName: 'F5', use: 'VEHICLE_AND_PEDESTRIAN' }),
    hohenfurtTrafficLight(81, 'K13', 'JS2_3er_mit_FG', { pedestrianSignalName: 'F6', use: 'VEHICLE_AND_PEDESTRIAN' }),
    hohenfurtTrafficLight(82, 'K14', 'JS2_3er_ohne_FG'),
    hohenfurtTrafficLight(96, 'S1', 'Unsichtbar_2er', {
      lightStructures: {
        '0': {
          structureRed: '#5528_Straba Signal Halt',
          structureGreen: '#5531_Straba Signal geradeaus',
          structureYellow: '#5529_Straba Signal anhalten',
          structureRequest: '#5530_Straba Signal A',
        },
      },
    }),
    hohenfurtTrafficLight(-2, 'S2', 'NONE', {
      lightStructures: {
        '0': {
          structureRed: '#5435_Straba Signal Halt',
          structureGreen: '#5437_Straba Signal geradeaus',
          structureYellow: '#5436_Straba Signal anhalten',
          structureRequest: '#5438_Straba Signal A',
        },
      },
    }),
    hohenfurtTrafficLight(-3, 'S3', 'NONE', {
      lightStructures: {
        '0': {
          structureRed: '#5525_Straba Signal Halt',
          structureGreen: '#5434_Straba Signal links',
          structureYellow: '#5526_Straba Signal anhalten',
          structureRequest: '#5524_Straba Signal A',
        },
      },
    }),
    hohenfurtTrafficLight(95, 'S4', 'Unsichtbar_2er', {
      lightStructures: {
        '0': {
          structureRed: '#5532_Straba Signal Halt',
          structureGreen: '#5527_Straba Signal rechts',
          structureYellow: '#5533_Straba Signal anhalten',
          structureRequest: '#5534_Straba Signal A',
        },
      },
    }),
    {
      id: 94,
      signalId: 94,
      pedestrianSignalName: 'F8',
      use: 'PEDESTRIAN_ONLY',
      modelId: 'JS2_2er_nur_FG',
      currentIndication: 'RED',
      intersectionId: 1,
      lightStructures: {},
      axisStructures: [],
    },
  ];
  return { intersection, lanes, ampeln };
}

function makeHohenfurtC1CurrentAppDtosFromLuaDtos(): {
  intersection: IntersectionAppDto;
  lanes: IntersectionLaneAppDto[];
  ampeln: IntersectionTrafficLightAppDto[];
} {
  const { intersection, lanes, ampeln } = makeHohenfurtC1CurrentLuaDtos();
  const state: State = {
    eventCounter: 1,
    ceTypes: {
      [CeTypes.RoadIntersection]: { [intersection.id]: intersection },
      [CeTypes.RoadIntersectionLane]: Object.fromEntries(lanes.map((lane) => [lane.id, lane])),
      [CeTypes.RoadIntersectionTrafficLight]: Object.fromEntries(ampeln.map((ampel) => [ampel.id, ampel])),
    },
  };
  const selector = new RoadSelector();

  selector.updateFromState(state);

  const mappedIntersection = selector.getIntersection(String(intersection.id));
  assert.ok(mappedIntersection);

  return {
    intersection: mappedIntersection,
    lanes: Object.values(selector.getIntersectionLanes()).filter((lane) => lane.intersectionId === intersection.id),
    ampeln: Object.values(selector.getIntersectionTrafficLights()).filter(
      (ampel) => ampel.intersectionId === intersection.id,
    ),
  };
}

function testCodegenCreatesIntersectionSetup(): void {
  const { lua, warnings } = generateIntersectionWizardLua(makeDraft());
  const kreuzungIndex = lua.indexOf('-- Kreuzung');
  const ampelnIndex = lua.indexOf('-- Ampeln');
  const laneSignalIndex = lua.indexOf('-- Fahrspur-Ampeln');
  const lanesIndex = lua.indexOf('-- Fahrspuren');
  const pedestrianCrossingsIndex = lua.indexOf('-- Fussgaengerfurten');
  const signalGroupsIndex = lua.indexOf('-- Ampelgruppen');

  assert.equal(warnings.length, 0);
  assert.ok(kreuzungIndex > 0 && ampelnIndex > kreuzungIndex);
  assert.ok(laneSignalIndex > ampelnIndex);
  assert.ok(lanesIndex > laneSignalIndex);
  assert.ok(pedestrianCrossingsIndex === -1 || pedestrianCrossingsIndex > lanesIndex);
  assert.ok(signalGroupsIndex > lanesIndex);
  assert.match(lua, /\n-- START Kreuzung bahnhofHaupt \(Bahnhofstraße - Hauptstraße\)\ndo\n/);
  assert.match(
    lua,
    /local bahnhofHaupt = Intersection:new\("Bahnhofstraße - Hauptstraße"\)\n\s+:setScriptVariableName\("bahnhofHaupt"\)\n\s+:withStorage\(42\)\n\s+:addStaticCams\(\n\s+"K1 Verkehrsueberwachung",\n\s+"K2 Tram-Blick"\n\s+\)/,
  );
  assert.match(lua, /:setSwitchInStrictOrder\(true\)/);
  assert.match(lua, /local bahnhofHauptK1 = TrafficLight:newForSignal\("K1", 101, TrafficLightModel\.JS2_3er_mit_FG\)/);
  assert.match(
    lua,
    /local bahnhofHauptK1Light1 = TrafficLight:newForLightStructure\("K1Light1",\n\s+"#1_Rot",\n\s+"#1_Gruen",\n\s+"#1_Gelb",\n\s+"#1_Anforderung"\n\s+\)/,
  );
  assert.match(
    lua,
    /local bahnhofHauptS1 = TrafficLight:newForLightStructure\("S1",\n\s+"#2_Rot",\n\s+"#2_Gruen",\n\s+"#2_Gelb",\n\s+"#2_Anforderung"\n\s+\)/,
  );
  assert.match(
    lua,
    /-- Fahrspur-Ampeln\n\s+local bahnhofHauptLane1Signal = TrafficLight:newForSignal\("lane1Sig", 101, TrafficLightModel\.Unsichtbar_2er\)\n\s+local bahnhofHauptLane2Signal = bahnhofHauptS1/,
  );
  assert.match(
    lua,
    /local bahnhofHauptSgSouthCarStraight = bahnhofHaupt\n\s+:newSignalGroup\("sgSouthCarStraight"\)\n\s+:setScriptVariableName\("bahnhofHauptSgSouthCarStraight"\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.STRAIGHT\)\n\s+:addVehicleSignals\(bahnhofHauptK1, bahnhofHauptK1Light1\)/,
  );
  assert.match(
    lua,
    /local bahnhofHauptSgSouthTramLeft = bahnhofHaupt\n\s+:newSignalGroup\("sgSouthTramLeft"\)\n\s+:setScriptVariableName\("bahnhofHauptSgSouthTramLeft"\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.LEFT\)\n\s+:addTramSignals\(bahnhofHauptS1\)/,
  );
  assert.match(
    lua,
    /bahnhofHauptLane1 = bahnhofHaupt:newLane\("FS1", bahnhofHauptLane1Signal\)\n\s+:setScriptVariableName\("bahnhofHauptLane1"\)/,
  );
  assert.match(
    lua,
    /bahnhofHauptLane2 = bahnhofHaupt:newLane\("FS2", bahnhofHauptLane2Signal\)\n\s+:setScriptVariableName\("bahnhofHauptLane2"\)\n\s+:setTrafficType\(Lane\.Type\.TRAM\)/,
  );
  const laneBlock = lua.slice(lanesIndex, signalGroupsIndex);
  assert.doesNotMatch(laneBlock, /:setApproach\(Lane\.Approach/);
  assert.doesNotMatch(laneBlock, /:setTurnDirections\(Lane\.Directions/);
  assert.match(
    lua,
    /bahnhofHauptLane1:driveOnDefaultSignalGroups\(bahnhofHauptSgSouthCarStraight\)\n\s+:showRequestsOnSignalGroups\(bahnhofHauptSgSouthCarStraight\)/,
  );
  assert.match(
    lua,
    /bahnhofHauptLane2:routes\("Tram 11 Heiderand"\)\n\s+:driveOnlyOnSignalGroups\(bahnhofHauptSgSouthTramLeft\)\n\s+:showRequestsOnSignalGroups\(bahnhofHauptSgSouthTramLeft\)/,
  );
  assert.doesNotMatch(lua, /bahnhofHaupt:addStaticCam/);
  assert.match(
    lua,
    /bahnhofHaupt:newPhase\("P1"\)\n\s+:addSignalGroups\(\n\s+bahnhofHauptSgSouthCarStraight,\n\s+bahnhofHauptSgSouthTramLeft/,
  );
}

function testCodegenResetsVariableNamesWhenManualNamesAreDisabled(): void {
  const draft = makeDraft();
  draft.manualLuaVariableNames = false;
  draft.luaVariableName = 'customIntersection';
  draft.lanes[0] = { ...draft.lanes[0]!, luaVariableName: 'customLane1' };
  draft.signalGroups[0] = { ...draft.signalGroups[0]!, luaVariableName: 'customSignalGroup1' };

  const { lua } = generateIntersectionWizardLua(draft);

  assert.doesNotMatch(lua, /customIntersection|customLane1|customSignalGroup1/);
  assert.match(lua, /local c1 = Intersection:new\("Bahnhofstraße - Hauptstraße"\)/);
  assert.match(lua, /c1Lane1 = c1:newLane\("FS1", c1Lane1Signal\)/);
  assert.match(lua, /local c1SgSouthCarStraight = c1\n\s+:newSignalGroup/);
}

function testCodegenUsesLaneSignalIdWhenSignalGroupHasMultipleSignals(): void {
  const draft = makeDraft();
  draft.manualLuaVariableNames = false;
  draft.lanes = [
    {
      id: 'lane-1',
      name: 'Spur 2',
      approach: 'WEST',
      signalSource: 'SIGNAL_GROUP',
      signalGroupSignalId: 'sg-1',
      signal: {
        name: 'Spur 2Signal',
        signalId: '91',
        modelName: 'Unsichtbar_2er',
        modelConstant: 'Unsichtbar_2er',
      },
      signalGroupAssignments: [{ signalGroupId: 'sg-1', mode: 'DEFAULT' }],
    },
  ];
  draft.ampeln = [
    {
      id: 'ampel-91',
      name: 'K2',
      signalId: '91',
      use: 'VEHICLE_ONLY',
      trafficType: 'CAR',
      modelName: 'Ampel_3er_XXX_ohne_FG',
      modelConstant: 'JS2_3er_ohne_FG',
    },
    {
      id: 'ampel-26',
      name: 'K3',
      signalId: '26',
      use: 'VEHICLE_ONLY',
      trafficType: 'CAR',
      modelName: 'Ampel_3er_XXX_mit_FG',
      modelConstant: 'JS2_3er_mit_FG',
    },
  ];
  draft.signalGroups = [
    {
      id: 'sg-1',
      name: 'sgWestCarLeft',
      approach: 'WEST',
      turnDirections: ['LEFT'],
      trafficType: 'CAR',
      showRequests: false,
      ampelIds: ['ampel-91', 'ampel-26'],
    },
  ];
  draft.phases = [{ id: 'phase-1', name: 'P1', signalGroupIds: ['sg-1'] }];

  const { lua } = generateIntersectionWizardLua(draft);

  assert.match(lua, /-- Fahrspur-Ampeln\n\s+local c1Lane1Signal = c1K2/);
  assert.doesNotMatch(lua, /local c1Lane1Signal = nil/);
  assert.match(lua, /c1Lane1 = c1:newLane\("Spur 2", c1Lane1Signal\)/);
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

  assert.match(lua, /local bahnhofHauptS1 = TrafficLight:newForSignal\("S1", 108, TrafficLightModel\.Unsichtbar_2er\)/);
  assert.match(
    lua,
    /local bahnhofHauptS1Light1 = TrafficLight:newForLightStructure\("S1Light1",\n\s+"#5537_Straba Signal Halt",\n\s+"#5538_Straba Signal links",\n\s+"#5539_Straba Signal anhalten",\n\s+"#5540_Straba Signal A"\n\s+\)/,
  );
  assert.doesNotMatch(lua, /:addLightStructure\(/);
  assert.match(
    lua,
    /bahnhofHaupt\n\s+:newSignalGroup\("sgSouthTramLeft"\)\n\s+:setScriptVariableName\("bahnhofHauptSgSouthTramLeft"\)\n\s+:setApproach\(Lane\.Approach\.SOUTH\)\n\s+:setTurnDirections\(Lane\.Directions\.LEFT\)\n\s+:addTramSignals\(bahnhofHauptS1, bahnhofHauptS1Light1\)/,
  );
}

function testCodegenWarnsForMultipleGroupsWithoutDefault(): void {
  const draft = makeDraft();
  draft.lanes[1]!.signalGroupAssignments = [
    { signalGroupId: 'sg-1', mode: 'ONLY', routeNames: ['A'] },
    { signalGroupId: 'sg-2', mode: 'ALSO', routeNames: ['B'] },
  ];

  const { warnings } = generateIntersectionWizardLua(draft);

  assert.deepEqual(warnings, ['FS2: Mehrere Ampelgruppen erfordern mindestens eine Standard-Ampelgruppe.']);
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
    /-- Fussg\.-Ampeln\n\s+local bahnhofHauptF1 = TrafficLight:newForSignal\("F1", 201, TrafficLightModel\.JS2_2er_nur_FG\)\n\s+local bahnhofHauptF2 = TrafficLight:newForSignal\("F2", 202, TrafficLightModel\.JS2_2er_nur_FG\)/,
  );
  assert.match(
    lua,
    /local c1PedNorth = bahnhofHaupt:newPedestrianCrossing\("Furt Nord"\)\n\s+:setScriptVariableName\("c1PedNorth"\)\n\s+:setApproach\(PedestrianCrossing\.Approach\.NORTH\)/,
  );
  assert.match(
    lua,
    /newSignalGroup\("sgNorthPed"\)\n\s+:setScriptVariableName\("bahnhofHauptSgNorthPed"\)\n\s+:setApproach\(Lane\.Approach\.NORTH\)\n\s+:addPedestrianCrossings\(c1PedNorth\)\n\s+:addPedestrianSignals\(bahnhofHauptF1, bahnhofHauptF2\)/,
  );
}

function testCurrentIntersectionDraftUsesSignalGroupMetadataAndReusesLaneSignal(): void {
  const intersection: IntersectionAppDto = {
    id: 9,
    name: 'Metadata Crossing',
    currentPhase: '',
    manualPhase: '',
    nextPhase: '',
    ready: true,
    greenTimeSeconds: 15,
    staticCams: [],
    signalGroupDefinitions: [
      {
        name: 'sgSourceLeft',
        scriptVariableName: 'sgImportedLeft',
        approach: 'WEST',
        turnDirections: ['LEFT'],
        trafficType: 'CAR',
        signalIds: [101],
      },
      {
        name: 'sgSourceStraight',
        approach: 'WEST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        signalIds: [102],
      },
    ],
    phases: [],
  };
  const lanes: IntersectionLaneAppDto[] = [
    {
      id: '9-Spur 1',
      intersectionId: 9,
      name: 'Spur 1',
      scriptVariableName: 'c9Lane1',
      currentIndication: 'RED',
      vehicleMultiplier: 1,
      laneSignalId: 101,
      approach: 'SOUTH',
      type: 'NORMAL',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['LEFT', 'STRAIGHT'],
      phases: [],
      defaultSignalGroups: ['sgSourceLeft', 'sgSourceStraight'],
      tracks: [],
    },
  ];
  const ampeln: IntersectionTrafficLightAppDto[] = [
    {
      id: 101,
      signalId: 101,
      vehicleSignalName: 'K1',
      use: 'VEHICLE_ONLY',
      modelId: 'JS2_3er_mit_FG',
      currentIndication: 'RED',
      intersectionId: 9,
      lightStructures: {
        '0': {
          structureRed: '#101_Rot',
          structureGreen: '#101_Gruen',
        },
      },
      axisStructures: [],
    },
    {
      id: 102,
      signalId: 102,
      vehicleSignalName: 'K2',
      use: 'VEHICLE_ONLY',
      modelId: 'JS2_3er_mit_FG',
      currentIndication: 'RED',
      intersectionId: 9,
      lightStructures: {},
      axisStructures: [],
    },
  ];

  const draft = createDraftFromCurrentIntersection(intersection, lanes, ampeln);

  assert.deepEqual(
    draft.signalGroups.map((group) => ({
      name: group.name,
      approach: group.approach,
      turnDirections: group.turnDirections,
    })),
    [
      { name: 'sgWestCarLeft', approach: 'WEST', turnDirections: ['LEFT'] },
      { name: 'sgWestCarStraight', approach: 'WEST', turnDirections: ['STRAIGHT'] },
    ],
  );
  assert.equal(draft.lanes[0]?.luaVariableName, 'c9Lane1');
  assert.equal(draft.lanes[0]?.approach, 'WEST');
  assert.equal(draft.signalGroups[0]?.luaVariableName, 'sgImportedLeft');
  assert.equal(draft.signalGroups[1]?.luaVariableName, 'sgSourceStraight');
  assert.equal(draft.lanes[0]?.signalSource, 'SIGNAL_GROUP');
  assert.equal(draft.lanes[0]?.signalGroupSignalId, 'sg-1');
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
  assert.equal(draft.lanes[0]?.approach, 'NORTH');
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
      { name: 'sgLane8Straight', trafficType: 'TRAM', signalIds: [-2] },
      { name: 'sgLane8Left', trafficType: 'TRAM', signalIds: [-3] },
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
      laneSignalId: 93,
      approach: 'EAST',
      type: 'TRAM',
      countType: 'SIGNALS',
      waitingTrains: [],
      waitingForGreenCyclesCount: 0,
      directions: ['LEFT'],
      phases: ['P2'],
      defaultSignalGroups: ['sgLane8Straight'],
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
      vehicleSignalName: 'S2',
      use: 'VEHICLE_ONLY',
      modelId: 'NONE',
      currentIndication: 'RED',
      intersectionId: 1,
      lightStructures: {
        '0': {
          structureRed: '#2_Rot',
          structureGreen: '#5521_Straba Signal geradeaus',
          structureYellow: '#2_Gelb',
          structureRequest: '#2_Anforderung',
        },
      },
      axisStructures: [],
    },
    {
      id: -3,
      signalId: -3,
      vehicleSignalName: 'S3',
      use: 'VEHICLE_ONLY',
      modelId: 'NONE',
      currentIndication: 'RED',
      intersectionId: 1,
      lightStructures: {
        '0': {
          structureRed: '#3_Rot',
          structureGreen: '#5434_Straba Signal links',
          structureYellow: '#3_Gelb',
          structureRequest: '#3_Anforderung',
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
      { name: 'sgEastTramStraight', ampelIds: ['ampel--2'], showRequests: false },
      { name: 'sgEastTramLeft', ampelIds: ['ampel--3'], showRequests: true },
    ],
  );
  assert.deepEqual(draft.lanes[0]?.signalGroupAssignments, [
    { signalGroupId: 'sg-1', mode: 'DEFAULT' },
    { signalGroupId: 'sg-2', mode: 'DEFAULT' },
  ]);
  assert.deepEqual(draft.lanes[1]?.signalGroupAssignments, [
    { signalGroupId: 'sg-4', mode: 'DEFAULT' },
    { signalGroupId: 'sg-5', mode: 'ONLY', routeNames: ['Tram 11 Heiderand'] },
  ]);
  assert.equal(draft.lanes[1]?.approach, 'EAST');
  assert.match(draft.generatedLua, /local c1S2 = TrafficLight:newForLightStructure\("S2"/);
  assert.match(draft.generatedLua, /local c1S3 = TrafficLight:newForLightStructure\("S3"/);
  assert.match(draft.generatedLua, /local c1K5Light1 = TrafficLight:newForLightStructure\("K5Light1"/);
  assert.doesNotMatch(draft.generatedLua, /:addLightStructure\(/);
  assert.match(
    draft.generatedLua,
    /c1Lane2:routes\("Tram 11 Heiderand"\)\n\s+:driveOnlyOnSignalGroups\(c1SgEastTramLeft\)/,
  );
  assert.match(draft.generatedLua, /local c1PedSouth = c1:newPedestrianCrossing\("Furt Nord-Sued"\)/);
}

function testCurrentIntersectionDraftRecreatesHohenfurtC1ControlModel(): void {
  const { intersection, lanes, ampeln } = makeHohenfurtC1CurrentAppDtosFromLuaDtos();

  const draft = createDraftFromCurrentIntersection(intersection, lanes, ampeln);
  const { lua, warnings } = generateIntersectionWizardLua(draft);

  assert.deepEqual(warnings, []);
  assert.equal(draft.name, 'Bahnhofstraße - Hauptstraße');
  assert.equal(draft.luaVariableName, 'c1');
  assert.equal(draft.intersectionEepSaveId, 3);
  assert.equal(draft.tippStructure, '#5573_Schaltschrank-Ampel2_SK2');
  assert.deepEqual(draft.staticCams, [
    'Kreuzung 1 - Draufsicht',
    'Kreuzung 1 - Zufahrt Nord',
    'Kreuzung 1 - Zufahrt Ost',
    'Kreuzung 1 - Zufahrt Süd',
    'Kreuzung 1 - Zufahrt West',
  ]);
  assert.equal(draft.lanes.length, 11);
  assert.equal(draft.ampeln.length, 21);
  assert.equal(draft.signalGroups.length, 16);
  assert.equal(draft.phases.length, 7);
  assert.equal(draft.supportPedestrianSignals, true);
  assert.equal(draft.supportMultipleLaneSignals, true);
  assert.equal(draft.supportStructureLightSignals, true);

  assert.deepEqual(
    draft.signalGroups.map((group) => ({
      name: group.name,
      luaVariableName: group.luaVariableName,
      approach: group.approach,
      turnDirections: group.turnDirections,
      trafficType: group.trafficType,
      showRequests: group.showRequests,
    })),
    [
      {
        name: 'sgWestCarStraight',
        luaVariableName: 'sgLane1Straight',
        approach: 'WEST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        showRequests: false,
      },
      {
        name: 'sgWestCarLeft',
        luaVariableName: 'sgLane2Left',
        approach: 'WEST',
        turnDirections: ['LEFT'],
        trafficType: 'CAR',
        showRequests: false,
      },
      {
        name: 'sgWestTramStraight',
        luaVariableName: 'sgLane3Straight',
        approach: 'WEST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'TRAM',
        showRequests: true,
      },
      {
        name: 'sgNorthCarStraight',
        luaVariableName: 'sgLane4Straight',
        approach: 'NORTH',
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        showRequests: false,
      },
      {
        name: 'sgNorthCarRight',
        luaVariableName: 'sgLane4Right',
        approach: 'NORTH',
        turnDirections: ['RIGHT'],
        trafficType: 'CAR',
        showRequests: false,
      },
      {
        name: 'sgNorthCarLeft',
        luaVariableName: 'sgLane5and5aLeft',
        approach: 'NORTH',
        turnDirections: ['LEFT'],
        trafficType: 'CAR',
        showRequests: false,
      },
      {
        name: 'sgEastCarRight',
        luaVariableName: 'sgLane6Right',
        approach: 'EAST',
        turnDirections: ['RIGHT'],
        trafficType: 'CAR',
        showRequests: false,
      },
      {
        name: 'sgEastCarStraight',
        luaVariableName: 'sgLane7Straight',
        approach: 'EAST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        showRequests: false,
      },
      {
        name: 'sgEastTramStraight',
        luaVariableName: 'sgLane8Straight',
        approach: 'EAST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'TRAM',
        showRequests: true,
      },
      {
        name: 'sgEastTramLeft',
        luaVariableName: 'sgLane8Left',
        approach: 'EAST',
        turnDirections: ['LEFT'],
        trafficType: 'TRAM',
        showRequests: true,
      },
      {
        name: 'sgSouthCarLeftStraightRight',
        luaVariableName: 'sgLane10AllDirections',
        approach: 'SOUTH',
        turnDirections: ['LEFT', 'STRAIGHT', 'RIGHT'],
        trafficType: 'CAR',
        showRequests: false,
      },
      {
        name: 'sgSouthTramRight',
        luaVariableName: 'sgLane11Right',
        approach: 'SOUTH',
        turnDirections: ['RIGHT'],
        trafficType: 'TRAM',
        showRequests: true,
      },
      {
        name: 'sgNorthPed',
        luaVariableName: 'sgPedNorth',
        approach: 'NORTH',
        turnDirections: [],
        trafficType: 'PEDESTRIAN',
        showRequests: false,
      },
      {
        name: 'sgSouthPed',
        luaVariableName: 'sgPedSouth',
        approach: 'SOUTH',
        turnDirections: [],
        trafficType: 'PEDESTRIAN',
        showRequests: false,
      },
      {
        name: 'sgEastPed',
        luaVariableName: 'sgPedEast',
        approach: 'EAST',
        turnDirections: [],
        trafficType: 'PEDESTRIAN',
        showRequests: false,
      },
      {
        name: 'sgWestPed',
        luaVariableName: 'sgPedWest',
        approach: 'WEST',
        turnDirections: [],
        trafficType: 'PEDESTRIAN',
        showRequests: false,
      },
    ],
  );

  assert.deepEqual(
    draft.lanes.map((lane) => ({
      name: lane.name,
      approach: lane.approach,
      type: laneTrafficTypeForTest(draft, lane),
      signalSource: lane.signalSource,
      signalId: lane.signal.signalId,
      signalGroupAssignments: lane.signalGroupAssignments.map((assignment) => ({
        group: draft.signalGroups.find((group) => group.id === assignment.signalGroupId)?.luaVariableName,
        mode: assignment.mode,
        routeNames: assignment.routeNames,
      })),
    })),
    [
      {
        name: 'Spur 1',
        approach: 'WEST',
        type: 'CAR',
        signalSource: 'SIGNAL_GROUP',
        signalId: '92',
        signalGroupAssignments: [{ group: 'sgLane1Straight', mode: 'DEFAULT', routeNames: undefined }],
      },
      {
        name: 'Spur 2',
        approach: 'WEST',
        type: 'CAR',
        signalSource: 'SIGNAL_GROUP',
        signalId: '91',
        signalGroupAssignments: [{ group: 'sgLane2Left', mode: 'DEFAULT', routeNames: undefined }],
      },
      {
        name: 'Spur 3',
        approach: 'WEST',
        type: 'TRAM',
        signalSource: 'SIGNAL_GROUP',
        signalId: '96',
        signalGroupAssignments: [{ group: 'sgLane3Straight', mode: 'DEFAULT', routeNames: undefined }],
      },
      {
        name: 'Spur 4',
        approach: 'NORTH',
        type: 'CAR',
        signalSource: 'OWN',
        signalId: '89',
        signalGroupAssignments: [
          { group: 'sgLane4Straight', mode: 'DEFAULT', routeNames: undefined },
          { group: 'sgLane4Right', mode: 'DEFAULT', routeNames: undefined },
        ],
      },
      {
        name: 'Spur 5',
        approach: 'NORTH',
        type: 'CAR',
        signalSource: 'SIGNAL_GROUP',
        signalId: '88',
        signalGroupAssignments: [{ group: 'sgLane5and5aLeft', mode: 'DEFAULT', routeNames: undefined }],
      },
      {
        name: 'Spur 5a',
        approach: 'NORTH',
        type: 'CAR',
        signalSource: 'SIGNAL_GROUP',
        signalId: '86',
        signalGroupAssignments: [{ group: 'sgLane5and5aLeft', mode: 'DEFAULT', routeNames: undefined }],
      },
      {
        name: 'Spur 6',
        approach: 'EAST',
        type: 'CAR',
        signalSource: 'SIGNAL_GROUP',
        signalId: '85',
        signalGroupAssignments: [{ group: 'sgLane6Right', mode: 'DEFAULT', routeNames: undefined }],
      },
      {
        name: 'Spur 7',
        approach: 'EAST',
        type: 'CAR',
        signalSource: 'SIGNAL_GROUP',
        signalId: '83',
        signalGroupAssignments: [{ group: 'sgLane7Straight', mode: 'DEFAULT', routeNames: undefined }],
      },
      {
        name: 'Spur 8',
        approach: 'EAST',
        type: 'TRAM',
        signalSource: 'OWN',
        signalId: '93',
        signalGroupAssignments: [
          { group: 'sgLane8Straight', mode: 'DEFAULT', routeNames: undefined },
          { group: 'sgLane8Left', mode: 'ONLY', routeNames: ['Tram 11 Heiderand', 'Tram 11 Rehfeld'] },
        ],
      },
      {
        name: 'Spur 10',
        approach: 'SOUTH',
        type: 'CAR',
        signalSource: 'SIGNAL_GROUP',
        signalId: '80',
        signalGroupAssignments: [{ group: 'sgLane10AllDirections', mode: 'DEFAULT', routeNames: undefined }],
      },
      {
        name: 'Spur 11',
        approach: 'SOUTH',
        type: 'TRAM',
        signalSource: 'SIGNAL_GROUP',
        signalId: '95',
        signalGroupAssignments: [{ group: 'sgLane11Right', mode: 'DEFAULT', routeNames: undefined }],
      },
    ],
  );

  assert.match(lua, /local c1 = Intersection:new\("Bahnhofstraße - Hauptstraße", 15\)/);
  assert.match(lua, /:setTippStructure\("#5573_Schaltschrank-Ampel2_SK2"\)/);
  assert.match(lua, /:withStorage\(3\)/);
  assert.match(lua, /:addStaticCams\(\n\s+"Kreuzung 1 - Draufsicht",/);
  assert.match(lua, /"Kreuzung 1 - Zufahrt West"\n\s+\)/);
  assert.doesNotMatch(lua, /:addStaticCam\(/);
  ['K1', 'K2', 'K3', 'K4', 'K5', 'K6', 'K7', 'K8', 'K9', 'K10', 'K11', 'K12', 'K13', 'K14'].forEach((name) =>
    assert.match(lua, new RegExp(`TrafficLight:newForSignal\\("${name}", \\d+, TrafficLightModel\\.`)),
  );
  ['S1Light1', 'S2', 'S3', 'S4Light1'].forEach((name) =>
    assert.match(lua, new RegExp(`TrafficLight:newForLightStructure\\("${name}"`)),
  );
  ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7'].forEach((name) =>
    assert.match(lua, new RegExp(`:asPedestrianSignal\\("${name}"\\)`)),
  );
  assert.match(lua, /TrafficLight:newForSignal\("F8", 94, TrafficLightModel\.JS2_2er_nur_FG\)/);
  assert.match(lua, /newLane\("Spur 4", c1Lane\d+Signal\)/);
  assert.match(lua, /newLane\("Spur 8", c1Lane\d+Signal\)/);
  assert.match(
    lua,
    /routes\("Tram 11 Heiderand", "Tram 11 Rehfeld"\)\n\s+:driveOnlyOnSignalGroups\(c1SgEastTramLeft\)\n\s+:showRequestsOnSignalGroups\(c1SgEastTramLeft\)/,
  );
  assert.match(
    lua,
    /driveOnDefaultSignalGroups\(c1SgEastTramStraight\)\n\s+:showRequestsOnSignalGroups\(c1SgEastTramStraight\)/,
  );
  assert.match(
    lua,
    /c1Lane\d+:driveOnDefaultSignalGroups\(c1SgWestTramStraight\)\n\s+:showRequestsOnSignalGroups\(c1SgWestTramStraight\)/,
  );
  assert.match(
    lua,
    /c1Lane\d+:driveOnDefaultSignalGroups\(c1SgSouthTramRight\)\n\s+:showRequestsOnSignalGroups\(c1SgSouthTramRight\)/,
  );
  ['c1PedNorth', 'c1PedSouth', 'c1PedEast', 'c1PedWest'].forEach((name) =>
    assert.match(lua, new RegExp(`local ${name} = c1:newPedestrianCrossing`)),
  );
  ['P1', 'P1a', 'P2', 'P3', 'P3a', 'P4', 'P4a'].forEach((name) =>
    assert.match(lua, new RegExp(`c1:newPhase\\("${escapeRegExp(name)}", 15\\)`)),
  );
  assert.match(
    lua,
    /c1:newPhase\("P2", 15\)\n\s+:addSignalGroups\(\n\s+c1SgWestCarLeft,\n\s+c1SgNorthCarRight,\n\s+c1SgSouthTramRight,\n\s+c1SgEastTramLeft/,
  );
  assert.doesNotMatch(lua, /driveOnlyOnSignals|driveAlsoOnSignals|showRequestsOnSignals|addSignalGroup\(/);
}

function laneTrafficTypeForTest(
  draft: IntersectionWizardDraftAppDto,
  lane: IntersectionWizardDraftAppDto['lanes'][number],
): string {
  return (
    lane.signalGroupAssignments
      .map((assignment) => draft.signalGroups.find((group) => group.id === assignment.signalGroupId)?.trafficType)
      .find((trafficType) => trafficType === 'TRAM') ?? 'CAR'
  );
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
    'intersection wizard codegen resets variable names when manual names are disabled',
    testCodegenResetsVariableNamesWhenManualNamesAreDisabled,
  );
  await runTest(
    'intersection wizard codegen reuses matching lane signal from multi-signal group',
    testCodegenUsesLaneSignalIdWhenSignalGroupHasMultipleSignals,
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
    'current intersection import uses signal group metadata and reuses lane signal',
    testCurrentIntersectionDraftUsesSignalGroupMetadataAndReusesLaneSignal,
  );
  await runTest(
    'current intersection import keeps imported lanes without fallback defaults',
    testCurrentIntersectionDraftKeepsImportedLanesWithoutFallbackDefaults,
  );
  await runTest(
    'current intersection import loads Hohenfurt-style signal groups',
    testCurrentIntersectionDraftLoadsHohenfurtStyleSignalGroups,
  );
  await runTest(
    'current intersection import recreates Hohenfurt c1 control model',
    testCurrentIntersectionDraftRecreatesHohenfurtC1ControlModel,
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
