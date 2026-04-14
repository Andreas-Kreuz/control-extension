import EepSimulator from '../../test-helpers/eep-simulator';
import { createScreenshots, prepareForScreenshot } from './createScreenshots';
import { generatedScreenshotPath } from './generatedScreenshotPath';

export const screenShotsizes = [['ipad-2', 'landscape']];

describe('Log Screenshots', () => createScreenshots(tests, screenShotsizes));

function tests(size: string, _closestSelector: string, simulator: EepSimulator) {
  const initialLogLines = [
    'Willkommen in EEP',
    '-----------------',
    'EEPMain() wurde erfolgreich beendet',
    'Signal 3 geschaltet auf 2',
    'EEPMain() wurde erfolgreich beendet',
    'Signal 3 geschaltet auf 1',
    'EEPMain() wurde erfolgreich beendet',
    'Signal 3 geschaltet auf 2',
    'EEPMain() wurde erfolgreich beendet',
    'Signal 3 geschaltet auf 1',
    'EEPMain() wurde erfolgreich beendet',
    'Signal 3 geschaltet auf 2',
    'EEPMain() wurde erfolgreich beendet',
    'Signal 3 geschaltet auf 1',
  ];
  const appendedLogLines = ['EEPMain() wurde erfolgreich beendet', 'Signal 3 geschaltet auf 2'];

  function waitForHome() {
    simulator.eepEvent('eep-version-complete.json');
    cy.contains('Control Extension App');
  }

  function writeLogLines(lines: string[]) {
    lines.forEach((line) => simulator.writeLogLine(line));
  }

  function openLogPanel() {
    cy.get('#open-log').then(($button) => {
      const buttonText = $button.text().toLowerCase();
      if (buttonText.includes('log anzeigen')) {
        cy.wrap($button).click();
      }
    });

    cy.get('#open-log').invoke('text').should('match', /log verbergen/i);
    cy.get('#delete-log').should('be.visible');
    return cy.get('ul');
  }

  function waitForLogScrollToSettle() {
    cy.get('ul')
      .parent()
      .should(($container) => {
        const element = $container[0];
        const maxScrollTop = Math.max(0, element.scrollHeight - element.clientHeight);
        expect(element.scrollTop).to.equal(maxScrollTop);
      });
  }

  function waitForLogLines(expectedTotal: number, lastLine: string) {
    openLogPanel()
      .children()
      .should('have.length', expectedTotal)
      .last()
      .should('contain.text', lastLine);
    waitForLogScrollToSettle();
  }

  beforeEach(() => {});

  describe('screenshot', () => {
    it('/ log open ' + size, () => {
      simulator.reset();
      writeLogLines(initialLogLines);
      cy.visit('/old');
      waitForHome();
      waitForLogLines(initialLogLines.length, initialLogLines[initialLogLines.length - 1]);
      writeLogLines(appendedLogLines);
      waitForLogLines(initialLogLines.length + appendedLogLines.length, appendedLogLines[appendedLogLines.length - 1]);
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/old', 'log-open', size));
    });
    it('/ log closed ' + size, () => {
      cy.visit('/old');
      waitForHome();
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/old', 'log-closed', size));
    });
  });
}
