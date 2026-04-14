import EepSimulator from '../../test-helpers/eep-simulator';
import { createScreenshots, prepareForScreenshot } from './createScreenshots';
import { generatedScreenshotPath } from './generatedScreenshotPath';

describe('Home, Road, and Trains Screenshots', () => createScreenshots(tests));

function tests(size: string, closestSelector: string, simulator: EepSimulator) {
  function waitForHome() {
    simulator.eepEvent('eep-version-complete.json');
    cy.contains('Control Extension App');
  }

  function screenshotCurrentPath(name: string) {
    cy.location('pathname').then((pathname) => {
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath(pathname, name, size), { capture: 'viewport' });
    });
  }

  beforeEach(() => {
    simulator.reset();
    simulator.simulateMap('map-01-events', 1, 83);
  });

  describe('screenshot', () => {
    it('/ home', () => {
      cy.visit('/');
      waitForHome();
      cy.contains('Ampeln');
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/', 'eep-web-startseite'));
    });

    it('/ road ' + size, () => {
      cy.visit('/road');
      waitForHome();
      cy.contains('Kreuzung 2');
      cy.contains('Bahnhofstr. - Hauptstr.');
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/road', 'overview', size));
    });

    it('/ road details ' + size, () => {
      cy.visit('/road/1');
      waitForHome();
      cy.contains('Bahnhofstr. - Hauptstr.');
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/road/1', 'detail', size));
    });

    it('/ trains ' + size, () => {
      cy.visit('/trains');
      waitForHome();
      cy.contains('#Acros_Schweiger_HB3').closest(closestSelector);
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/trains', 'overview', size), { capture: 'viewport' });
    });

    it('/ trains details' + size, () => {
      cy.visit('/trains/%23Acros_Schweiger_HB3');
      waitForHome();
      cy.contains('#Acros_Schweiger_HB3')
        .closest(closestSelector)
        .scrollIntoView({ offset: { top: -90, left: 0 } });
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/trains/%23Acros_Schweiger_HB3', 'detail', size), {
        capture: 'viewport',
      });
    });

    it('/ transit landing ' + size, () => {
      cy.visit('/transit');
      waitForHome();
      cy.contains('ÖPNV');
      cy.contains('Linien');
      cy.contains('Haltestellen');
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/transit', 'landing', size), { capture: 'viewport' });
    });

    it('/ transit lines ' + size, () => {
      cy.visit('/transit/lines');
      waitForHome();
      cy.contains('Sonnenhain');
      cy.contains('Westgarten');
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/transit/lines', 'overview', size), { capture: 'viewport' });
    });

    it('/ transit first line details ' + size, () => {
      cy.visit('/transit/lines/4');
      waitForHome();
      cy.contains('Richtung: Sonnenhain');
      screenshotCurrentPath('detail');
    });

    it('/ transit stations ' + size, () => {
      cy.visit('/transit/stations');
      waitForHome();
      cy.contains('Haltestellen');
      cy.contains('Zentralforum');
      cy.contains('Lindenmarkt');
      prepareForScreenshot();
      cy.screenshot(generatedScreenshotPath('/transit/stations', 'overview', size), { capture: 'viewport' });
    });

    it('/ transit station hauptbahnhof ' + size, () => {
      cy.visit('/transit/stations/Zentralforum');
      waitForHome();
      cy.contains('Zentralforum');
      cy.contains('Steig 1');
      cy.contains('Sonnenhain');
      cy.contains('Westgarten');
      screenshotCurrentPath('detail');
    });
  });
}
