import EepSimulator from '../../test-helpers/eep-simulator';
import { createScreenshots } from './createScreenshots';

describe('Road Screenshots', () => createScreenshots(tests));

function tests(size: string, _closestSelector: string, simulator: EepSimulator) {
  beforeEach(() => {
    simulator.reset();
    simulator.simulateMap('map-01-events', 1, 81);
  });
  describe('screenshot', () => {
    const path = `assets/doc/${size}-road`;
    it('/ road ' + size, () => {
      cy.visit('/road');
      cy.contains('Kreuzung 2');
      cy.contains('Bahnhofstr. - Hauptstr.');
      cy.screenshot(`${path}`);
    });
    it('/ road details ' + size, () => {
      cy.visit('/road/1');
      cy.contains('Bahnhofstr. - Hauptstr.');
      cy.screenshot(`${path}-kreuzung1`);
    });
  });
}
