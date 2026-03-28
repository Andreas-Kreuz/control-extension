import * as assert from 'node:assert/strict';
import TrustedServerAddressPolicy from './TrustedServerAddressPolicy';

function createPolicy(allowDevServerOrigins = false): TrustedServerAddressPolicy {
  return new TrustedServerAddressPolicy({
    serverPort: 3000,
    allowDevServerOrigins,
    hostname: 'server-box',
    networkInterfaces: {
      ethernet: [
        {
          address: '192.168.10.25',
          netmask: '255.255.255.0',
          family: 'IPv4',
          mac: '00:00:00:00:00:01',
          internal: false,
          cidr: '192.168.10.25/24',
        },
      ],
      loopback: [
        {
          address: '127.0.0.1',
          netmask: '255.0.0.0',
          family: 'IPv4',
          mac: '00:00:00:00:00:00',
          internal: true,
          cidr: '127.0.0.1/8',
        },
      ],
    },
  });
}

async function runTest(name: string, fn: () => void | Promise<void>): Promise<void> {
  try {
    await fn();
    console.log('ok - ' + name);
  } catch (error) {
    console.error('not ok - ' + name);
    throw error;
  }
}

function testTrustedServerHostsIncludeLoopbackHostnameAndLocalIpv4(): void {
  const policy = createPolicy();

  assert.equal(policy.isTrustedServerHost('localhost'), true);
  assert.equal(policy.isTrustedServerHost('127.0.0.1'), true);
  assert.equal(policy.isTrustedServerHost('::1'), true);
  assert.equal(policy.isTrustedServerHost('server-box'), true);
  assert.equal(policy.isTrustedServerHost('192.168.10.25'), true);
  assert.equal(policy.isTrustedServerHost('192.168.10.99'), false);
}

function testTrustedLocalServerRequestRequiresTrustedHostAndLocalRemoteAddress(): void {
  const policy = createPolicy();

  assert.equal(
    policy.isTrustedLocalServerRequest({
      hostHeader: '192.168.10.25:3000',
      remoteAddress: '192.168.10.25',
    }),
    true,
  );
  assert.equal(
    policy.isTrustedLocalServerRequest({
      hostHeader: 'server-box:3000',
      remoteAddress: '::ffff:127.0.0.1',
    }),
    true,
  );
  assert.equal(
    policy.isTrustedLocalServerRequest({
      hostHeader: '192.168.10.25:3000',
      remoteAddress: '192.168.10.99',
    }),
    false,
  );
  assert.equal(
    policy.isTrustedLocalServerRequest({
      hostHeader: 'example.invalid:3000',
      remoteAddress: '192.168.10.25',
    }),
    false,
  );
}

function testCorsOriginsAllowTrustedServerAddressesOnServerPort(): void {
  const policy = createPolicy();

  assert.equal(policy.isTrustedOrigin(undefined), true);
  assert.equal(policy.isTrustedOrigin('http://server-box:3000'), true);
  assert.equal(policy.isTrustedOrigin('http://192.168.10.25:3000'), true);
  assert.equal(policy.isTrustedOrigin('http://server-box:5173'), false);
  assert.equal(policy.isTrustedOrigin('http://example.invalid:3000'), false);
}

function testCorsOriginsAllowConfiguredDevPortsOnlyWhenEnabled(): void {
  const devPolicy = createPolicy(true);
  const prodPolicy = createPolicy(false);

  assert.equal(devPolicy.isTrustedOrigin('http://server-box:5173'), true);
  assert.equal(devPolicy.isTrustedOrigin('http://192.168.10.25:4173'), true);
  assert.equal(prodPolicy.isTrustedOrigin('http://server-box:5173'), false);
}

export async function run(): Promise<void> {
  await runTest(
    'TrustedServerAddressPolicy trusts loopback, hostname, and the server IPv4 addresses',
    testTrustedServerHostsIncludeLoopbackHostnameAndLocalIpv4,
  );
  await runTest(
    'TrustedServerAddressPolicy only treats same-machine requests to trusted hosts as local admin requests',
    testTrustedLocalServerRequestRequiresTrustedHostAndLocalRemoteAddress,
  );
  await runTest(
    'TrustedServerAddressPolicy allows CORS only for trusted server addresses on the server port',
    testCorsOriginsAllowTrustedServerAddressesOnServerPort,
  );
  await runTest(
    'TrustedServerAddressPolicy allows trusted dev origins only when the dev-origin flag is enabled',
    testCorsOriginsAllowConfiguredDevPortsOnlyWhenEnabled,
  );
}

if (require.main === module) {
  run().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
