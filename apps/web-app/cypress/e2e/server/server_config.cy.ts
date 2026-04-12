import EepSimulator from '../../test-helpers/eep-simulator';

const simulator = new EepSimulator();
const projectRoot = Cypress.config('projectRoot');
const validDir = `${projectRoot}/cypress/io`;
const emptyDir = `${projectRoot}/cypress/io-empty`;

function chooseDirectory(dir: string) {
  cy.visit('/server');
  cy.get('#choose-dir-button').should('be.enabled').click();
  cy.get('input#dir-dialog-dir').should('exist').should('be.visible').clear().type(dir).type('{esc}');
  cy.get('#dir-dialog-choose').should('be.enabled').click();
  cy.get('#responsive-dialog-title').should('not.exist');
}

describe('Server Tests "/server"', () => {
  const pairingRequired = { value: true };

  before(() => {
    cy.readFile(simulator.fileNames.serverIsRunning, { timeout: 20000 }).should('exist');
    simulator.reset();
    simulator.eepEvent('eep-version-complete.json');
    chooseDirectory(validDir);
    cy.get('input#pairing-required-switch')
      .invoke('prop', 'checked')
      .then((value) => {
        pairingRequired.value = Boolean(value);
      });
    cy.contains('ce.server.ApiEntries');
    cy.contains('ce.hub.EepVersion');
    cy.contains('aus 2 Events');
  });

  after(() => {
    chooseDirectory(validDir);
    cy.get('input#pairing-required-switch').then(($switch) => {
      const currentValue = Boolean($switch.prop('checked'));
      if (currentValue !== pairingRequired.value) {
        if (pairingRequired.value) {
          cy.wrap($switch).check({ force: true });
        } else {
          cy.wrap($switch).uncheck({ force: true });
        }
      }
    });
  });

  it('has button "Ordner wählen"', () => {
    cy.get('#choose-dir-button');
  });
  it('contains "Bereitgestellte Daten"', () => {
    cy.contains('Bereitgestellte Daten');
  });
  it('contains "(2 Events)"', () => {
    cy.contains('aus 2 Events');
  });

  it('allows toggling approval for new connections and keeps the setting on reload', () => {
    cy.get('input#pairing-required-switch').should('be.checked').uncheck({ force: true });
    cy.get('input#pairing-required-switch').should('not.be.checked');
    cy.reload();
    cy.get('input#pairing-required-switch').should('not.be.checked');
  });

  describe('Changing the directory', () => {
    it('button "Wählen" is enabled', () => {
      cy.get('#choose-dir-button').click();
      cy.get('input#dir-dialog-dir').should('exist').should('be.visible').should('contain.value', 'cypress/io');
      cy.get('#dir-dialog-choose').should('be.enabled');
      cy.get('#dir-dialog-cancel').should('be.enabled');
      cy.get('input#dir-dialog-dir').type('{esc}');
      cy.get('#dir-dialog-cancel').should('be.enabled').click();
      cy.get('#responsive-dialog-title').should('not.exist');
    });
    it('button "Wählen" is disabled', () => {
      cy.get('#choose-dir-button').click();
      cy.get('input#dir-dialog-dir')
        .should('exist')
        .should('be.visible')
        .should('contain.value', 'io')
        .clear()
        .type('{selectall}{backspace}')
        .type('{esc}')
        .then(() => {
          cy.get('#dir-dialog-choose').should('be.disabled');
          cy.get('#dir-dialog-cancel').should('be.enabled');
          cy.get('#dir-dialog-cancel').should('be.enabled').click();
          cy.get('#responsive-dialog-title').should('not.exist');
        });
    });

    describe('Changing to "bad" directory', () => {
      it('Change to non-existing directory error', () => {
        cy.get('#choose-dir-button')
          .should('be.enabled')
          .click()
          .then(() => {
            cy.get('input#dir-dialog-dir')
              .should('exist')
              .should('be.visible')
              .clear()
              .type('non-existing')
              .type('{esc}');
            cy.get('#dir-dialog-choose').should('be.enabled').click();
            cy.get('#responsive-dialog-title').should('not.exist');
            cy.contains('Bevor es losgeht, muss Du nur noch den Ordner von EEP angeben.');
          });
      });

      it('Change to EEP directory without contents ', () => {
        simulator.clearPersistedState(emptyDir);
        cy.get('#choose-dir-button')
          .should('be.enabled')
          .click()
          .then(() => {
            cy.get('input#dir-dialog-dir').should('exist').should('be.visible').clear().type(emptyDir).type('{esc}');
            cy.get('#dir-dialog-choose').should('be.enabled').click();
            cy.get('#responsive-dialog-title').should('not.exist');
            cy.reload();
            cy.contains('Es wurden keine Daten von EEP gesammelt');
          });
      });

      after(() => {
        chooseDirectory(validDir);
      });
    });
  });
});
