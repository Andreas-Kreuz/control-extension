import EepSimulator from '../../test-helpers/eep-simulator';
import { createScreenshots } from './createScreenshots';

describe('Road Screenshots', () => createScreenshots(tests));

function tests(size: string, closestSelector: string, simulator: EepSimulator) {
  beforeEach(() => {
    simulator.reset();
    simulator.simulateMap('map-01-events', 1, 81);
  });
  describe('screenshot', () => {
    const path = `assets/doc/${size}-trains`;

    it('/ trains ' + size, () => {
      cy.visit('/trains');
      cy.contains('#Acros_Schweiger_HB3').closest(closestSelector);
      cy.screenshot(`${path}`, { capture: 'viewport' });
    });
    it('/ trains details' + size, () => {
      cy.visit('/trains/%23Acros_Schweiger_HB3');
      cy.contains('#Acros_Schweiger_HB3')
        .closest(closestSelector)
        .scrollIntoView({ offset: { top: -90, left: 0 } });
      cy.screenshot(`${path}-train1`, { capture: 'viewport' });
    });
  });
}
