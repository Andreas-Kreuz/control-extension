import EepSimulator from '../../test-helpers/eep-simulator';
import { createScreenshots } from './createScreenshots';

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
    cy.get('#open-log').should('contain.text', 'Log anzeigen').click();
    cy.get('#open-log').should('contain.text', 'Log verbergen');
    return cy.get('ul').should('be.visible');
  }

  function waitForLogLines(expectedTotal: number, lastLine: string) {
    openLogPanel()
      .children()
      .should('have.length', expectedTotal)
      .last()
      .should('contain.text', lastLine);
  }

  beforeEach(() => {});

  describe('screenshot', () => {
    const path = `assets/doc/${size}-home`;
    it('/ log open ' + size, () => {
      simulator.reset();
      writeLogLines(initialLogLines);
      cy.visit('/old');
      waitForHome();
      waitForLogLines(initialLogLines.length, initialLogLines[initialLogLines.length - 1]);
      writeLogLines(appendedLogLines);
      waitForLogLines(initialLogLines.length + appendedLogLines.length, appendedLogLines[appendedLogLines.length - 1]);
      cy.screenshot(`${path}-log`);
    });
    it('/ log closed ' + size, () => {
      cy.visit('/old');
      waitForHome();
      cy.screenshot(`${path}-log-closed`);
    });
  });
}
