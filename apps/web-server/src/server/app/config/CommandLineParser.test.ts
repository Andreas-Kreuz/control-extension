import * as assert from 'node:assert/strict';
import CommandLineParser from './CommandLineParser';

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function withArgv(argv: string[], fn: () => void): void {
  const originalArgv = process.argv;
  process.argv = argv;
  try {
    fn();
  } finally {
    process.argv = originalArgv;
  }
}

function testParsesAllowDevOriginsFlag(): void {
  withArgv(['node', 'server', '--allow-dev-origins'], () => {
    const options = new CommandLineParser().parseOptions();
    assert.equal(options['allow-dev-origins'], true);
    assert.equal(options.testmode, undefined);
  });
}

function testParsesTestmodeAndExchangeDirTogether(): void {
  withArgv(['node', 'server', '--testmode', '--exchange-dir', '../web-app/cypress/io'], () => {
    const options = new CommandLineParser().parseOptions();
    assert.equal(options.testmode, true);
    assert.equal(options['exchange-dir'], '../web-app/cypress/io');
  });
}

function testParsesPortAndConfigDirFlags(): void {
  withArgv(['node', 'server', '--port', '3001', '--config-dir', '../web-app/cypress/server-config'], () => {
    const options = new CommandLineParser().parseOptions();
    assert.equal(options.port, 3001);
    assert.equal(options['config-dir'], '../web-app/cypress/server-config');
  });
}

function testParsesTestmodePortConfigDirAndExchangeDirTogether(): void {
  withArgv(
    [
      'node',
      'server',
      '--testmode',
      '--port',
      '3001',
      '--config-dir',
      '../web-app/cypress/server-config',
      '--exchange-dir',
      '../web-app/cypress/io',
    ],
    () => {
      const options = new CommandLineParser().parseOptions();
      assert.equal(options.testmode, true);
      assert.equal(options.port, 3001);
      assert.equal(options['config-dir'], '../web-app/cypress/server-config');
      assert.equal(options['exchange-dir'], '../web-app/cypress/io');
    },
  );
}

export async function run(): Promise<void> {
  await runTest('CommandLineParser parses the allow-dev-origins flag', testParsesAllowDevOriginsFlag);
  await runTest('CommandLineParser still parses testmode with exchange-dir', testParsesTestmodeAndExchangeDirTogether);
  await runTest('CommandLineParser parses the port and config-dir flags', testParsesPortAndConfigDirFlags);
  await runTest(
    'CommandLineParser parses testmode together with port, config-dir, and exchange-dir',
    testParsesTestmodePortConfigDirAndExchangeDirTogether,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
