// KEEP THIS FILE FOR HEADLESS TESTS
// See in node ./build/node-main.js --testmode --exchange-dir ../web-app-react/cypress/io package.json
import CommandLineParser from './config/CommandLineParser';
import { ServerMain } from './ServerMain';

const commandLineOptions = new CommandLineParser().parseOptions();
const server = new ServerMain('.', 3000, {
  allowOpenServerRoute:
    Boolean(commandLineOptions['testmode']) || Boolean(commandLineOptions['allow-dev-origins']),
});
server.start();
