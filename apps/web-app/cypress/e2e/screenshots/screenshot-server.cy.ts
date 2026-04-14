import EepSimulator from '../../test-helpers/eep-simulator';
import { createScreenshots, prepareForScreenshot } from './createScreenshots';
import { generatedScreenshotPath } from './generatedScreenshotPath';

export const screenShotsizes = [['ipad-2', 'landscape']];

describe('Server Screenshots', () => createScreenshots(tests, screenShotsizes));

function tests(size: string, _closestSelector: string, simulator: EepSimulator) {
  const projectRoot = Cypress.config('projectRoot');
  const validDir = `${projectRoot}/cypress/io`;
  const emptyDir = `${projectRoot}/cypress/io-empty`;
  // Intentionally missing directory to verify the "invalid EEP directory" server state.
  const nonexistentDir = `${projectRoot}/cypress/io-nonexistent`;
  const pairingRequired = { value: true };

  function chooseDirectory(dir: string) {
    cy.visit('/server');
    cy.get('#choose-dir-button').should('be.enabled').click();
    cy.get('input#dir-dialog-dir').should('exist').should('be.visible').clear().type(dir).type('{esc}');
    cy.get('#dir-dialog-choose').should('be.enabled').click();
    cy.get('#responsive-dialog-title').should('not.exist');
  }

  function waitForScreenshotVisualState() {
    cy.get('#choose-dir-button').then(($button) => {
      if ($button.is(':focus')) {
        cy.wrap($button).blur();
      }
    });

    cy.get('body').should(() => {
      expect(Cypress.$('body').find('.MuiTouchRipple-rippleVisible')).to.have.length(0);
      expect(Cypress.$('body').find('.Mui-focusVisible')).to.have.length(0);
    });
  }

  before(() => {
    cy.readFile(simulator.fileNames.serverIsRunning, { timeout: 20000 }).should('exist');
    chooseDirectory(validDir);
    cy.get('input#pairing-required-switch')
      .invoke('prop', 'checked')
      .then((value) => {
        pairingRequired.value = Boolean(value);
      });
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

  describe('screenshot', () => {
    it('/ server nonexistingdir ' + size, () => {
      chooseDirectory(nonexistentDir);
      cy.contains('Bevor es losgeht, muss Du nur noch den Ordner von EEP angeben.');
      cy.get('#choose-dir-current-dir').invoke('text', 'C:\\Trend\\EEP18');
      waitForScreenshotVisualState();
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/server', '02-server-verzeichnis-falsch'));
    });

    it('/ server emptydir ' + size, () => {
      simulator.clearPersistedState(emptyDir);
      chooseDirectory(emptyDir);
      cy.reload();
      cy.get('#choose-dir-current-dir').invoke('text', 'C:\\Trend\\EEP18');
      cy.contains('Es wurden keine Daten von EEP gesammelt');
      waitForScreenshotVisualState();
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/server', '02-server-verzeichnis-ok'));
    });

    it('/ server ok ' + size, () => {
      chooseDirectory(validDir);
      simulator.reset();
      simulator.eepEvent('eep-version-complete.json');
      cy.reload();
      cy.contains('Bereitgestellte Daten');
      cy.contains('ce.server.ApiEntries');
      cy.contains('ce.hub.EepVersion');
      cy.contains('aus 2 Events');
      cy.get('#choose-dir-current-dir').invoke('text', 'C:\\Trend\\EEP18');
      waitForScreenshotVisualState();
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/server', '02-server-verzeichnis-ok-daten-da'));
    });
  });
}
