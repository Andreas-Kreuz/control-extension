// KEEP THIS FILE FOR HEADLESS TESTS
// See in node ./build/node-main.js --testmode --exchange-dir ../web-app-react/cypress/io package.json
import CommandLineParser from './config/CommandLineParser';
import { ServerMain } from './ServerMain';

const commandLineOptions = new CommandLineParser().parseOptions();
const serverPort = typeof commandLineOptions.port === 'number' ? commandLineOptions.port : 3000;
const serverConfigDir = typeof commandLineOptions['config-dir'] === 'string' ? commandLineOptions['config-dir'] : '.';
const testMode = Boolean(commandLineOptions['testmode']);
const server = new ServerMain(serverConfigDir, serverPort, {
  allowOpenServerRoute: testMode || Boolean(commandLineOptions['allow-dev-origins']),
  debug: !testMode,
});
server.start();
