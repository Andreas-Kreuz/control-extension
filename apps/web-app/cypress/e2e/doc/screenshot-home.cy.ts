import EepSimulator from '../../test-helpers/eep-simulator';
import { createScreenshots } from './createScreenshots';

describe('Home Screenshots', () => createScreenshots(tests));

function tests(size: string, _closestSelector: string, simulator: EepSimulator) {
  function waitForHome() {
    simulator.eepEvent('eep-version-complete.json');
    cy.contains('Control Extension App');
  }

  beforeEach(() => {
    simulator.reset();
  });
  describe('screenshot', () => {
    const path = `assets/doc/${size}-home`;
    it('/ home', () => {
      cy.visit('/');
      waitForHome();
      cy.contains('Ampeln');
      cy.screenshot(`${path}`);
    });
  });
}
