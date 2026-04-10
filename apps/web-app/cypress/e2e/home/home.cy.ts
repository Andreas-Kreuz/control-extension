import EepSimulator from '../../test-helpers/eep-simulator';

const simulator = new EepSimulator();

beforeEach(() => {
  simulator.reset();
});

describe('App Home', () => {
  it('contains the home modules after reset', () => {
    cy.visit('/simple');
    cy.contains('Control Extension App');
    cy.contains('Ampeln');
    cy.contains('ÖPNV');
    cy.contains('Fuhrpark');
    cy.contains('Statistik');
  });

  it('still renders the home modules after an EEP event', () => {
    simulator.eepEvent('eep-version-complete.json');

    cy.visit('/simple');
    cy.contains('Control Extension App');
    cy.contains('Ampeln');
    cy.contains('ÖPNV');
    cy.contains('Fuhrpark');
    cy.contains('Statistik');
  });
});
