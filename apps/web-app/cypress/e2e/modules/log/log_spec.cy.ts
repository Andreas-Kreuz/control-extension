import EepSimulator from '../../../test-helpers/eep-simulator';

const simulator = new EepSimulator();

const getLogList = () => {
  cy.get('#open-log').then(($button) => {
    if ($button.text().toLowerCase().includes('log anzeigen')) {
      cy.wrap($button).click();
    }
  });

  cy.get('#open-log').invoke('text').should('match', /log verbergen/i);
  cy.get('#delete-log').should('be.visible');
  return cy.get('ul');
};

before(() => {
  simulator.reset();
});

beforeEach(() => {
  simulator.reset();
});

describe('Logger', () => {
  it('has no initial log', () => {
    cy.visit('/old');
    cy.readFile(simulator.fileNames.logFromCe).then((a) => cy.log(a));
    getLogList().children().should('have.length', 0);
  });

  describe('displays', () => {
    it('log line "Let us test something"', () => {
      simulator.writeLogLine('Let us test something');
      cy.visit('/old');
      cy.readFile(simulator.fileNames.logFromCe).then((a) => cy.log(a));
      getLogList().children().should('have.length', 1).first().contains('Let us test something');
    });

    it('latin1 characters correctly: "Äpfel, Überschuss, ÖPNV"', () => {
      simulator.writeLogLine('Äpfel, Überschuss, ÖPNV');
      cy.visit('/old');
      cy.readFile(simulator.fileNames.logFromCe).then((a) => cy.log(a));
      getLogList().children().should('have.length', 1).first().contains('Äpfel, Überschuss, ÖPNV');
    });

    it('displays log lines 1 to 3', () => {
      simulator.writeLogLine('Line 1\nLine 2\nLine 3');
      cy.visit('/old');
      cy.readFile(simulator.fileNames.logFromCe).then((a) => cy.log(a));
      getLogList()
        .children()
        .should('have.length', 3)
        .first()
        .contains('Line 1')
        .next()
        .contains('Line 2')
        .next()
        .contains('Line 3');
    });

    it('displays log lines 1 to 4', () => {
      simulator.writeLogLine('Line 1\nLine 2\nLine 3\nLine 4');
      cy.visit('/old');
      cy.readFile(simulator.fileNames.logFromCe).then((a) => cy.log(a));
      getLogList()
        .children()
        .should('have.length', 4)
        .first()
        .contains('Line 1')
        .next()
        .contains('Line 2')
        .next()
        .contains('Line 3')
        .next()
        .contains('Line 4');
    });
  });
  describe('action', () => {
    it('"Reset Button" sends "clearlog" command to EEP', () => {
      cy.writeFile(simulator.fileNames.commandsToCe, '');
      cy.visit('/old');
      getLogList();
      cy.get('#delete-log').click();
      cy.readFile(simulator.fileNames.commandsToCe, 'latin1').should('eq', 'clearlog\n');
    });
  });

  describe('reset marker', () => {
    it('clears the visible log when @@CE_LOG_RESET@@ is appended at runtime', () => {
      simulator.writeLogLine('Before reset');
      cy.visit('/old');
      getLogList().children().should('have.length', 1).first().contains('Before reset');

      simulator.appendLogResetMarker();
      getLogList().children().should('have.length', 0);

      simulator.writeLogLine('After reset');
      getLogList().children().should('have.length', 1).first().contains('After reset');
    });
  });
});
