import EepSimulator from '../../test-helpers/eep-simulator';

const simulator = new EepSimulator();

beforeEach(() => {
  simulator.reset();
});

describe('Data Transfer Insights', () => {
  it('navigates from insights and loads field counts lazily', () => {
    simulator.eepEvent('eep-version-complete.json');

    cy.visit('/simple/insights');
    cy.contains('Datenfluss anzeigen').click();

    cy.location('pathname').should('eq', '/insights/data-transfer');
    cy.contains('Datenfluss');
    cy.contains('Gesamt');
    cy.contains('Letzte Aktualisierung');
    cy.contains('ce.hub.EepVersion');

    cy.get('button[aria-label="Felder ausklappen"]').first().click();

    cy.contains('singleVersion');
    cy.contains('luaVersion');
  });
});
