import EepSimulator from '../../../test-helpers/eep-simulator';
import { prepareForScreenshot } from '../../screenshots/createScreenshots';

const simulator = new EepSimulator();

const tutorialIntersectionName = 'Abzweig Bahnhofstrasse';
const tutorialDesktopViewport = [1280, 1280] as const;
const js2ThreeWithPedestrians = 'JS2 3er-Ampel mit Fußgängern';
const js2ThreeWithoutPedestrians = 'JS2 3er-Ampel ohne Fußgänger';

function readLuaPreview() {
  return cy.contains('h6', 'Lua-Code').closest('.MuiPaper-root').find('pre').invoke('text');
}

function tutorialDraft() {
  return {
    id: 'tutorial-4-abzweig-bahnhofstrasse',
    name: tutorialIntersectionName,
    luaVariableName: 'c1',
    intersectionEepSaveId: 2,
    tippStructure: '#60_1Spur_Fahrradständer2_AS3',
    manualLuaVariableNames: true,
    supportPedestrianSignals: true,
    staticCams: ['Kreuzung aus Westen'],
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
    ampeln: [
      {
        id: 'ampel-k1',
        name: 'K1',
        signalId: '16',
        use: 'VEHICLE_ONLY',
        trafficType: 'CAR',
        modelName: js2ThreeWithPedestrians,
        modelConstant: 'JS2_3er_mit_FG',
      },
      {
        id: 'ampel-k2',
        name: 'K2',
        signalId: '18',
        use: 'VEHICLE_ONLY',
        trafficType: 'CAR',
        modelName: js2ThreeWithoutPedestrians,
        modelConstant: 'JS2_3er_ohne_FG',
      },
      {
        id: 'ampel-k3',
        name: 'K3',
        signalId: '17',
        use: 'VEHICLE_ONLY',
        trafficType: 'CAR',
        modelName: js2ThreeWithoutPedestrians,
        modelConstant: 'JS2_3er_ohne_FG',
      },
      {
        id: 'ampel-k4',
        name: 'K4',
        signalId: '11',
        use: 'VEHICLE_ONLY',
        trafficType: 'CAR',
        modelName: js2ThreeWithPedestrians,
        modelConstant: 'JS2_3er_mit_FG',
      },
      {
        id: 'ampel-s1',
        name: 'S1',
        signalId: '20',
        use: 'VEHICLE_ONLY',
        trafficType: 'TRAM',
        modelName: js2ThreeWithoutPedestrians,
        modelConstant: 'JS2_3er_ohne_FG',
      },
      {
        id: 'ampel-s2',
        name: 'S2',
        signalId: '21',
        use: 'VEHICLE_ONLY',
        trafficType: 'TRAM',
        modelName: js2ThreeWithoutPedestrians,
        modelConstant: 'JS2_3er_ohne_FG',
      },
      {
        id: 'ampel-f1',
        name: 'F1',
        pedestrianName: 'F1',
        sourceAmpelId: 'ampel-k2',
        use: 'PEDESTRIAN_ONLY',
        trafficType: 'PEDESTRIAN',
        modelName: '',
        modelConstant: '',
      },
      {
        id: 'ampel-f2',
        name: 'F2',
        pedestrianName: 'F2',
        sourceAmpelId: 'ampel-k4',
        use: 'PEDESTRIAN_ONLY',
        trafficType: 'PEDESTRIAN',
        modelName: '',
        modelConstant: '',
      },
    ],
    signalGroups: [
      {
        id: 'sg-west-car-straight',
        name: 'sgWestCarStraight',
        luaVariableName: 'c1SgWestCarStraight',
        approach: 'WEST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'CAR',
        showRequests: false,
        ampelIds: ['ampel-k1', 'ampel-k2'],
      },
      {
        id: 'sg-west-car-left',
        name: 'sgWestCarLeft',
        luaVariableName: 'c1SgWestCarLeft',
        approach: 'WEST',
        turnDirections: ['LEFT'],
        trafficType: 'CAR',
        showRequests: false,
        ampelIds: ['ampel-k3', 'ampel-k4'],
      },
      {
        id: 'sg-west-s-straight',
        name: 'sgWestTramStraight',
        luaVariableName: 'c1SgWestTramStraight',
        approach: 'WEST',
        turnDirections: ['STRAIGHT'],
        trafficType: 'TRAM',
        showRequests: false,
        ampelIds: ['ampel-s1', 'ampel-s2'],
      },
      {
        id: 'sg-west-ped',
        name: 'sgWestPed',
        luaVariableName: 'c1SgWestPed',
        approach: 'WEST',
        turnDirections: [],
        trafficType: 'PEDESTRIAN',
        showRequests: false,
        pedestrianCrossingName: 'Furt West',
        pedestrianCrossingLuaVariableName: 'c1PedWest',
        ampelIds: ['ampel-f1', 'ampel-f2'],
      },
    ],
    lanes: [
      {
        id: 'lane-1',
        name: 'FS1',
        luaVariableName: 'c1Lane1',
        approach: 'WEST',
        signalSource: 'OWN',
        signal: {
          name: 'lane1Sig',
          signalId: '12',
          modelName: 'Unsichtbares Signal',
          modelConstant: 'Unsichtbar_2er',
        },
        signalGroupAssignments: [{ signalGroupId: 'sg-west-car-straight', mode: 'DEFAULT' }],
      },
      {
        id: 'lane-2',
        name: 'FS2',
        luaVariableName: 'c1Lane2',
        approach: 'WEST',
        signalSource: 'OWN',
        signal: {
          name: 'lane2Sig',
          signalId: '13',
          modelName: 'Unsichtbares Signal',
          modelConstant: 'Unsichtbar_2er',
        },
        signalGroupAssignments: [{ signalGroupId: 'sg-west-car-left', mode: 'DEFAULT' }],
      },
      {
        id: 'lane-3',
        name: 'FS3',
        luaVariableName: 'c1Lane3',
        approach: 'WEST',
        signalSource: 'OWN',
        signal: {
          name: 'lane3Sig',
          signalId: '14',
          modelName: 'Unsichtbares Signal',
          modelConstant: 'Unsichtbar_2er',
        },
        signalGroupAssignments: [{ signalGroupId: 'sg-west-s-straight', mode: 'DEFAULT' }],
      },
    ],
    phases: [
      {
        id: 'phase-1',
        name: 'P1',
        signalGroupIds: ['sg-west-car-straight', 'sg-west-car-left'],
      },
      {
        id: 'phase-2',
        name: 'P2',
        signalGroupIds: ['sg-west-car-straight', 'sg-west-s-straight'],
      },
      {
        id: 'phase-3',
        name: 'P3',
        signalGroupIds: ['sg-west-ped'],
      },
    ],
    generatedLua: '',
  };
}

function tutorialSignalGroupErrorDraft() {
  const draft = tutorialDraft();
  draft.id = 'tutorial-4-abzweig-bahnhofstrasse-signalgruppen-fehler';
  draft.ampeln = [{ ...draft.ampeln[0], signalId: '' }];
  draft.signalGroups = [{ ...draft.signalGroups[0], ampelIds: ['ampel-k1'] }];
  draft.lanes = [];
  draft.phases = [];
  return draft;
}

function tutorialLaneErrorDraft() {
  const draft = tutorialDraft();
  draft.id = 'tutorial-4-abzweig-bahnhofstrasse-fahrspuren-fehler';
  draft.lanes = [
    {
      ...draft.lanes[0],
      signal: {
        ...draft.lanes[0].signal,
        signalId: '',
      },
    },
  ];
  draft.phases = [];
  return draft;
}

function tutorialPhaseErrorDraft() {
  const draft = tutorialDraft();
  draft.id = 'tutorial-4-abzweig-bahnhofstrasse-phasen-fehler';
  draft.phases = [{ id: 'phase-1', name: 'P1', signalGroupIds: [] }];
  return draft;
}

function createTutorialDraft() {
  return cy
    .request('POST', '/api/v1/road/intersection-wizard/drafts', tutorialDraft())
    .its('body.id')
    .then((draftId) => String(draftId));
}

function createTutorialScreenshotDraft(draft: ReturnType<typeof tutorialDraft>) {
  return cy
    .request('POST', '/api/v1/road/intersection-wizard/drafts', draft)
    .its('body.id')
    .then((draftId) => String(draftId));
}

function setupTutorialScreenshotViewport() {
  Cypress.Screenshot.defaults({ overwrite: true });
  cy.viewport(tutorialDesktopViewport[0], tutorialDesktopViewport[1]);
}

function takeTutorialScreenshot(screenshotName: string) {
  prepareForScreenshot();
  cy.document().then((document) => {
    const existingStyle = document.getElementById('tutorial-screenshot-viewport-styles');
    if (existingStyle) {
      existingStyle.remove();
    }

    const style = document.createElement('style');
    style.id = 'tutorial-screenshot-viewport-styles';
    style.textContent = `
      html,
      body,
      #root {
        min-height: ${tutorialDesktopViewport[1]}px;
        height: ${tutorialDesktopViewport[1]}px;
        overflow: hidden;
      }
    `;
    document.head.appendChild(style);
  });
  cy.scrollTo('top', { ensureScrollable: false });
  cy.contains('Kreuzung erstellen');
  cy.screenshot(screenshotName, { capture: 'fullPage', timeout: 60000 });
}

function visitTutorialStep(draftId: string, step: string, title: string, screenshotName?: string) {
  cy.visit(`/simple/road/createIntersection/${step}?draftId=${encodeURIComponent(draftId)}`);
  cy.contains(title);
  if (screenshotName) takeTutorialScreenshot(screenshotName);
}

function waitForFirstSignalGroupTrafficLights() {
  cy.contains('h6', 'Ampelgruppe sgWestCarStraight')
    .closest('.MuiPaper-root')
    .within(() => {
      cy.contains('K1');
      cy.contains('16');
      cy.contains(js2ThreeWithPedestrians);
      cy.contains('K2');
      cy.contains('18');
      cy.contains(js2ThreeWithoutPedestrians);
      cy.contains('tr', 'K2').find('button').first().click();
      cy.contains('label', 'Signal-ID')
        .invoke('attr', 'for')
        .then((id) => {
          cy.get(`#${id}`).should('have.value', '18');
        });
      cy.contains(js2ThreeWithPedestrians);
      cy.contains('JS2_3er_mit_FG').should('not.exist');
    });
  cy.scrollTo('top');
  cy.contains('h6', 'Ampelgruppe sgWestCarStraight');
}

function waitForFirstSignalGroupInPhases() {
  cy.get('body')
    .invoke('text')
    .should('match', /sgWestCarStraight[\s\S]*Ampeln:\s*K1,\s*K2[\s\S]*Phasen:\s*P1\s*und\s*P2/);
}

before(() => {
  simulator.simulateMap('map-01-events', 1, 81);
});

describe('Road', () => {
  it('should contain an expand button which toggles the expansion', () => {
    cy.visit('/simple/road');
    cy.contains('Bahnhofstr. - Hauptstr.');
    cy.contains('Kreuzung 2');
  });

  it('opens the create intersection wizard with live code preview', () => {
    cy.visit('/simple/road/createIntersection');
    cy.contains('Kreuzung erstellen');
    cy.contains('Signal-IDs und Modellinformationen');
    cy.contains('button', 'Neue Kreuzung erstellen').click();
    cy.contains('Kreuzungsname');
    cy.contains('label', 'Erweiterte Einstellungen').find('input').check({ force: true });
    cy.contains('label', 'Lua-Code sofort anzeigen').find('input').check({ force: true });
    cy.contains('Lua-Code');
  });

  it('supports router back and forward navigation between wizard steps', () => {
    cy.visit('/simple/road/createIntersection');
    cy.contains('button', 'Neue Kreuzung erstellen').click();
    cy.location('pathname').should('include', '/simple/road/createIntersection/kreuzung');
    cy.contains('Weiter').click();
    cy.location('pathname').should('include', '/simple/road/createIntersection/signalgruppen');
    cy.contains('Ampelgruppen');
    cy.contains('Weiter').click();
    cy.location('pathname').should('include', '/simple/road/createIntersection/fahrspuren');
    cy.go('back');
    cy.location('pathname').should('include', '/simple/road/createIntersection/signalgruppen');
    cy.contains('Ampelgruppen');
    cy.go('forward');
    cy.location('pathname').should('include', '/simple/road/createIntersection/fahrspuren');
    cy.contains('Fahrspuren');
  });

  it('starts the create intersection wizard from the selected crossing side panel', () => {
    cy.viewport(1400, 800);
    cy.visit('/simple/road/1');
    cy.contains('Im Kreuzungs-Wizard öffnen').click();
    cy.location('pathname').should('include', '/simple/road/createIntersection');
    cy.location('search').should('include', 'draftId=current-1');
    cy.contains('Kreuzung erstellen');
  });

  it('creates the documented tutorial intersection and generates matching Lua', () => {
    setupTutorialScreenshotViewport();
    createTutorialDraft().then((draftId) => {
      visitTutorialStep(draftId, 'kreuzung', 'Kreuzungsname', 'road-wizard-tutorial-01-kreuzung');
      visitTutorialStep(draftId, 'signalgruppen', 'Ampelgruppen');
      waitForFirstSignalGroupTrafficLights();
      takeTutorialScreenshot('road-wizard-tutorial-02-ampelgruppen');
      visitTutorialStep(draftId, 'fahrspuren', 'Fahrspuren', 'road-wizard-tutorial-03-fahrspuren');
      visitTutorialStep(draftId, 'verkehrsphasen', 'Ampelphasen');
      waitForFirstSignalGroupInPhases();
      takeTutorialScreenshot('road-wizard-tutorial-04-phasen');
      visitTutorialStep(draftId, 'zusammenfassung', 'Zusammenfassung');

      cy.contains('Lua-Code');
      readLuaPreview().should((lua) => {
        expect(lua).to.contain(`-- START Kreuzung c1 (${tutorialIntersectionName})`);
        expect(lua).to.contain(`local c1 = Intersection:new("${tutorialIntersectionName}")`);
        expect(lua).to.contain(':setScriptVariableName("c1")');
        expect(lua).to.contain(':setTippStructure("#60_1Spur_Fahrradständer2_AS3")');
        expect(lua).to.contain(':withStorage(2)');
        expect(lua).to.contain(':addStaticCams("Kreuzung aus Westen")');
        expect(lua).to.contain('TrafficLight:newForSignal("K1", 16, TrafficLightModel.JS2_3er_mit_FG)');
        expect(lua).to.contain('TrafficLight:newForSignal("K2", 18, TrafficLightModel.JS2_3er_ohne_FG)');
        expect(lua).to.contain('TrafficLight:newForSignal("K3", 17, TrafficLightModel.JS2_3er_ohne_FG)');
        expect(lua).to.contain('TrafficLight:newForSignal("K4", 11, TrafficLightModel.JS2_3er_mit_FG)');
        expect(lua).to.contain('TrafficLight:newForSignal("S1", 20, TrafficLightModel.JS2_3er_ohne_FG)');
        expect(lua).to.contain('TrafficLight:newForSignal("S2", 21, TrafficLightModel.JS2_3er_ohne_FG)');
        expect(lua).to.contain('local c1F1 = c1K2:withPedestrian("F1")');
        expect(lua).to.contain('local c1F2 = c1K4:withPedestrian("F2")');
        expect(lua).to.contain('TrafficLight:newForSignal("lane1Sig", 12, TrafficLightModel.Unsichtbar_2er)');
        expect(lua).to.contain('TrafficLight:newForSignal("lane2Sig", 13, TrafficLightModel.Unsichtbar_2er)');
        expect(lua).to.contain('TrafficLight:newForSignal("lane3Sig", 14, TrafficLightModel.Unsichtbar_2er)');
        expect(lua).to.contain('c1Lane1 = c1:newLane("FS1", c1Lane1Signal)');
        expect(lua).to.contain('c1Lane2 = c1:newLane("FS2", c1Lane2Signal)');
        expect(lua).to.contain('c1Lane3 = c1:newLane("FS3", c1Lane3Signal)');
        expect(lua).to.contain(':setKpId("c1Lane1")');
        expect(lua).to.contain(':setKpId("c1Lane2")');
        expect(lua).to.contain(':setKpId("c1Lane3")');
        expect(lua).not.to.contain(':setScriptVariableName("c1Lane1")');
        expect(lua).to.contain(':newSignalGroup("sgWestCarStraight")');
        expect(lua).to.contain(':setScriptVariableName("c1SgWestCarStraight")');
        expect(lua).to.contain(':addVehicleSignals(c1K1, c1K2)');
        expect(lua).to.contain(':addVehicleSignals(c1K3, c1K4)');
        expect(lua).to.contain(':newSignalGroup("sgWestTramStraight")');
        expect(lua).to.contain(':setScriptVariableName("c1SgWestTramStraight")');
        expect(lua).to.contain(':addTramSignals(c1S1, c1S2)');
        expect(lua).to.contain(':addPedestrianSignals(c1F1, c1F2)');
        expect(lua).to.contain('c1Lane1:driveOnDefaultSignalGroups(c1SgWestCarStraight)');
        expect(lua).to.contain('c1Lane3:driveOnDefaultSignalGroups(c1SgWestTramStraight)');
        expect(lua).to.contain(':setTrafficType(Lane.Type.TRAM)');
        expect(lua).to.contain('c1:newPhase("P1")');
        expect(lua).to.contain(`-- END Kreuzung c1 (${tutorialIntersectionName})`);
      });
      takeTutorialScreenshot('road-wizard-tutorial-05-zusammenfassung');
    });

    createTutorialScreenshotDraft(tutorialSignalGroupErrorDraft()).then((draftId) => {
      visitTutorialStep(draftId, 'signalgruppen', 'Ampelgruppen', 'road-wizard-tutorial-02-ampelgruppen-fehler');
    });

    createTutorialScreenshotDraft(tutorialLaneErrorDraft()).then((draftId) => {
      visitTutorialStep(draftId, 'fahrspuren', 'Fahrspuren', 'road-wizard-tutorial-03-fahrspuren-fehler');
    });

    createTutorialScreenshotDraft(tutorialPhaseErrorDraft()).then((draftId) => {
      visitTutorialStep(draftId, 'verkehrsphasen', 'Ampelphasen', 'road-wizard-tutorial-04-phasen-fehler');
    });
  });
});
