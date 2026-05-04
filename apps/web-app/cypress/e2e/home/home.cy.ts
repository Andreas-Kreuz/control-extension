import EepSimulator from '../../test-helpers/eep-simulator';

const simulator = new EepSimulator();

beforeEach(() => {
  simulator.reset();
});

describe('App Home', () => {
  it('hides module-gated home modules after reset', () => {
    cy.visit('/simple');
    cy.contains('Control Extension App');
    cy.contains('Ampeln').should('not.exist');
    cy.contains('ÖPNV').should('not.exist');
    cy.contains('Fuhrpark').should('not.exist');
    cy.contains('Control Extension einbinden');
    cy.contains('ControlExtension.addModules');
    cy.contains('Einblicke');
  });

  it('renders only the road module after the road module is loaded', () => {
    simulator.eepEvent('road-module.json');

    cy.visit('/simple');
    cy.contains('Control Extension App');
    cy.contains('Ampeln');
    cy.contains('ÖPNV').should('not.exist');
    cy.contains('Fuhrpark').should('not.exist');
    cy.contains('Einblicke');
  });

  it('renders transit after the transit module is loaded', () => {
    simulator.eepEvent('transit-module.json');

    cy.visit('/simple');
    cy.contains('Control Extension App');
    cy.contains('ÖPNV');
    cy.contains('Ampeln').should('not.exist');
    cy.contains('Fuhrpark').should('not.exist');
    cy.contains('Einblicke');
  });

  it('renders the fleet after the hub module is loaded', () => {
    simulator.eepEvent('hub-module.json');

    cy.visit('/simple');
    cy.contains('Control Extension App');
    cy.contains('Fuhrpark');
    cy.contains('Ampeln').should('not.exist');
    cy.contains('ÖPNV').should('not.exist');
    cy.contains('Einblicke');
  });

  it('filters the root navigation by loaded modules', () => {
    cy.viewport(1280, 720);
    simulator.eepEvent('road-module.json');

    cy.visit('/');
    cy.get('.MuiDrawer-root').contains('Start');
    cy.get('.MuiDrawer-root').contains('Ampeln');
    cy.get('.MuiDrawer-root').contains('ÖPNV').should('not.exist');
    cy.get('.MuiDrawer-root').contains('Fuhrpark').should('not.exist');
  });
});
