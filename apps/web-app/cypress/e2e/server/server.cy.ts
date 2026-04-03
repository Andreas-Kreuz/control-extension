import EepSimulator from '../../test-helpers/eep-simulator';

const simulator = new EepSimulator();

beforeEach(() => {
  simulator.reset();
});

describe('Server Home', () => {
  it('has 1 event and ce.server.ApiEntries after reset', () => {
    cy.visit('/server');
    cy.contains('Server');
    cy.contains('App öffnen');
    cy.contains('Bereitgestellte Daten');
    cy.contains('aus 1 Events');
    cy.contains('ce.server.ApiEntries');
  });

  it('has 2 events and contains ce.hub.EepVersion after second event', () => {
    simulator.eepEvent('eep-version-complete.json');
    cy.visit('/server');
    cy.contains('aus 2 Events');
    cy.contains('ce.server.ApiEntries');
    cy.contains('ce.hub.EepVersion');
  });
});
