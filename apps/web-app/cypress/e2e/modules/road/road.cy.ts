import EepSimulator from '../../../test-helpers/eep-simulator';

const simulator = new EepSimulator();

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
    cy.contains('Vorbereitung');
    cy.contains('Lua-Code');
    cy.contains('Signal-IDs und Modellinformationen');
    cy.contains('Weiter').click();
    cy.contains('Kreuzungsname');
  });

  it('supports router back and forward navigation between wizard steps', () => {
    cy.visit('/simple/road/createIntersection');
    cy.contains('Weiter').click();
    cy.location('pathname').should('include', '/simple/road/createIntersection/kreuzung');
    cy.contains('Fahrspuren').click();
    cy.location('pathname').should('include', '/simple/road/createIntersection/fahrspuren');
    cy.go('back');
    cy.location('pathname').should('include', '/simple/road/createIntersection/kreuzung');
    cy.contains('Kreuzungsname');
    cy.go('forward');
    cy.location('pathname').should('include', '/simple/road/createIntersection/fahrspuren');
    cy.contains('Fahrspuren');
  });

  it('starts the create intersection wizard from the selected crossing side panel', () => {
    cy.viewport(1400, 800);
    cy.visit('/simple/road/1');
    cy.contains('Im Kreuzungs-Wizard öffnen').click();
    cy.location('pathname').should('include', '/simple/road/createIntersection');
    cy.location('search').should('include', 'intersectionId=1');
    cy.contains('Kreuzung "Bahnhofstr. - Hauptstr." geladen.');
    cy.contains('Lua-Code');
  });
});
