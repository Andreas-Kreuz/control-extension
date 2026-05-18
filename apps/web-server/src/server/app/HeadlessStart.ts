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

let shutdownInProgress = false;

async function stopServer(exitCode: number): Promise<void> {
  if (shutdownInProgress) {
    process.exit(1);
  }

  shutdownInProgress = true;
  try {
    await server.stop();
    process.exit(exitCode);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

for (const signal of ['SIGINT', 'SIGTERM', 'SIGBREAK'] as const) {
  process.once(signal, () => {
    void stopServer(0);
  });
}

process.once('uncaughtException', (error) => {
  console.error(error);
  void stopServer(1);
});

process.once('unhandledRejection', (reason) => {
  console.error(reason);
  void stopServer(1);
});
