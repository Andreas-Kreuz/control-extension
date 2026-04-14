import EepSimulator from '../../test-helpers/eep-simulator';

export const defaultSizes = [
  ['iphone-xr', 'portrait'],
  ['ipad-2', 'landscape'],
  ['macbook-13', 'portrait'],
];

const getClosestSelector = (size: string) => {
  if (size === 'iphone-xr') {
    return '.MuiCard-root';
  }

  return '.MuiListItem-root';
};

export const prepareForScreenshot = () => {
  cy.document().then((document) => {
    const existingStyle = document.getElementById('screenshot-viewport-styles');
    if (existingStyle) {
      existingStyle.remove();
    }

    const style = document.createElement('style');
    style.id = 'screenshot-viewport-styles';
    style.textContent = `
      html {
        scrollbar-width: none;
        overflow: hidden;
      }

      body {
        -ms-overflow-style: none;
        overflow: hidden;
      }

      html,
      body,
      #root {
        max-width: 100vw;
      }

      ::-webkit-scrollbar {
        width: 0;
        height: 0;
        display: none;
      }
    `;
    document.head.appendChild(style);
  });
};

export const createScreenshots = (
  tests: (size: string, closestSelector: string, simulator: EepSimulator) => void,
  screenShotsizes?: string[][],
) => {
  const simulator = new EepSimulator();
  (screenShotsizes || defaultSizes).forEach((size) => {
    context(`${size[0]} in ${size[1]} mode'`, () => {
      beforeEach(() => {
        Cypress.Screenshot.defaults({
          overwrite: true,
        });
        cy.viewport(size[0], size[1]);
      });
      tests(size[0], getClosestSelector(size[0]), simulator);
    });
  });
};
