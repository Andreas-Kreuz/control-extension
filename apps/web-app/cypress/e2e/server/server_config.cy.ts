import EepSimulator from '../../test-helpers/eep-simulator';

const simulator = new EepSimulator();

describe('Server Tests "/server"', () => {
  const pwd: { dir: string; pairingRequired: boolean } = { dir: '-', pairingRequired: true };

  before(() => {
    // Remember the old server dir otherwise the following tests will not work!
    cy.visit('/server');
    cy.wait(500).then(() => {
      cy.get('#choose-dir-current-dir')
        .should('not.have.text', '-')
        .should('not.contain.text', 'io-empty')
        .invoke('text')
        .then((value) => {
          pwd.dir = value as string;
        });
      cy.get('input#pairing-required-switch')
        .invoke('prop', 'checked')
        .then((value) => {
          pwd.pairingRequired = Boolean(value);
        });
    });
    simulator.reset();
    simulator.eepEvent('eep-version-complete.json');
    cy.wait(500).then(() => {
      cy.contains('ce.server.ApiEntries');
      cy.contains('ce.hub.EepVersion');
      cy.contains('aus 2 Events');
    });
  });

  after(() => {
    if (pwd.dir) {
      // Reset the old server dir otherwise the following tests will not work!
      cy.log('RESET TO: ' + pwd.dir);
      cy.visit('/server');
      cy.wait(500);
      cy.get('input#pairing-required-switch').then(($switch) => {
        const currentValue = Boolean($switch.prop('checked'));
        if (currentValue !== pwd.pairingRequired) {
          if (pwd.pairingRequired) {
            cy.wrap($switch).check({ force: true });
          } else {
            cy.wrap($switch).uncheck({ force: true });
          }
        }
      });
      cy.get('#choose-dir-current-dir')
        .should('not.have.text', '-')
        .then(() => {
          cy.get('#choose-dir-button')
            .should('be.enabled')
            .click()
            .then(() => {
              cy.get('input#dir-dialog-dir').should('exist').should('be.visible').clear().type(pwd.dir).type('{esc}');
              cy.get('#dir-dialog-choose').should('be.enabled').click();
              cy.get('#responsive-dialog-title').should('not.exist');
            });
        });
    }
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
      cy.get('input#dir-dialog-dir').should('exist').should('be.visible').should('contain.value', pwd.dir);
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
            cy.wait(1000);
            cy.contains('Bevor es losgeht, muss Du nur noch den Ordner von EEP angeben.');
          });
      });

      it('Change to EEP directory without contents ', () => {
        cy.get('#choose-dir-button')
          .should('be.enabled')
          .click()
          .then(() => {
            cy.get('input#dir-dialog-dir')
              .should('exist')
              .should('be.visible')
              .clear()
              .type(pwd.dir + '-empty')
              .type('{esc}');
            cy.get('#dir-dialog-choose').should('be.enabled').click();
            cy.get('#responsive-dialog-title').should('not.exist');
            cy.wait(1000);
            cy.contains('Es wurden keine Daten von EEP gesammelt');
          });
      });

      after(() => {
        // Reset the old server dir otherwise the following tests will not work!
        cy.get('#choose-dir-current-dir')
          .should('contain.text', '-empty')
          .then(() => {
            cy.get('#choose-dir-button')
              .should('be.enabled')
              .click()
              .then(() => {
                cy.get('input#dir-dialog-dir').should('exist').should('be.visible').clear().type(pwd.dir).type('{esc}');
                cy.get('#dir-dialog-choose').should('be.enabled').click();
                cy.get('#responsive-dialog-title').should('not.exist');
              });
          });
      });
    });
  });
});
