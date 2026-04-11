import EepSimulator from '../../test-helpers/eep-simulator';

const simulator = new EepSimulator();
const projectRoot = Cypress.config('projectRoot');
const validDir = `${projectRoot}/cypress/io`;

function chooseDirectory(dir: string) {
  cy.visit('/server');
  cy.get('#choose-dir-button').should('be.enabled').click();
  cy.get('input#dir-dialog-dir').should('exist').should('be.visible').clear().type(dir).type('{esc}');
  cy.get('#dir-dialog-choose').should('be.enabled').click();
  cy.get('#responsive-dialog-title').should('not.exist');
}

beforeEach(() => {
  cy.readFile(simulator.fileNames.serverIsRunning, { timeout: 20000 }).should('exist');
  chooseDirectory(validDir);
  simulator.reset();
  cy.reload();
});

afterEach(() => {
  chooseDirectory(validDir);
});

describe('Server Home', () => {
  it('shows no EEP data after reset', () => {
    cy.contains('Server');
    cy.contains('App öffnen');
    cy.contains('Es wurden keine Daten von EEP gesammelt');
  });

  it('has 2 events and contains ce.hub.EepVersion after second event', () => {
    simulator.eepEvent('eep-version-complete.json');
    cy.reload();
    cy.contains('Bereitgestellte Daten');
    cy.contains('aus 2 Events');
    cy.contains('ce.server.ApiEntries');
    cy.contains('ce.hub.EepVersion');
  });
});
