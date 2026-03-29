import * as os from 'node:os';

const DEFAULT_DEV_SERVER_PORTS = ['3001', '4200', '4173', '5173'];
const LOOPBACK_HOSTS = ['localhost', '127.0.0.1', '::1'];
const LOOPBACK_REQUEST_ADDRESSES = ['127.0.0.1', '::1'];

export interface TrustedServerAddressPolicyOptions {
  serverPort: number;
  allowDevServerOrigins?: boolean;
  devServerPorts?: string[];
  hostname?: string;
  networkInterfaces?: NodeJS.Dict<os.NetworkInterfaceInfo[]>;
}

interface TrustedLocalServerRequest {
  hostHeader?: string | string[] | undefined;
  remoteAddress?: string | undefined;
}

function normalizeHost(host: string | undefined): string | undefined {
  if (!host) {
    return undefined;
  }

  const trimmedHost = host.trim();
  if (trimmedHost.length === 0) {
    return undefined;
  }

  if (trimmedHost.startsWith('[')) {
    const closingBracketIndex = trimmedHost.indexOf(']');
    if (closingBracketIndex > 0) {
      return trimmedHost.slice(1, closingBracketIndex).toLowerCase();
    }
  }

  const colonCount = (trimmedHost.match(/:/g) ?? []).length;
  if (colonCount === 1) {
    return trimmedHost.slice(0, trimmedHost.lastIndexOf(':')).toLowerCase();
  }

  return trimmedHost.toLowerCase();
}

function normalizeAddress(address: string | undefined): string | undefined {
  if (!address) {
    return undefined;
  }

  const trimmedAddress = address.trim().toLowerCase();
  if (trimmedAddress.length === 0) {
    return undefined;
  }

  if (trimmedAddress.startsWith('::ffff:')) {
    return trimmedAddress.slice('::ffff:'.length);
  }

  return trimmedAddress;
}

function extractHostFromHeader(hostHeader?: string | string[]): string | undefined {
  const rawHostHeader = Array.isArray(hostHeader) ? hostHeader[0] : hostHeader;
  return normalizeHost(rawHostHeader);
}

function defaultPortForProtocol(protocol: string): string {
  if (protocol === 'http:') {
    return '80';
  }
  if (protocol === 'https:') {
    return '443';
  }

  return '';
}

export default class TrustedServerAddressPolicy {
  private readonly trustedServerHosts: string[] = [];
  private readonly trustedServerHostsNormalized = new Set<string>();
  private readonly localRequestAddresses = new Set<string>();
  private readonly allowedCorsPorts = new Set<string>();
  private readonly preferredServerHost?: string;

  public constructor(private readonly options: TrustedServerAddressPolicyOptions) {
    this.initializeAllowedCorsPorts();
    this.initializeLoopbackAddresses();

    const localIpv4Addresses = this.registerLocalIpv4Addresses();
    const hostname = this.registerHostname();

    this.preferredServerHost = this.choosePreferredServerHost(localIpv4Addresses, hostname);
  }

  public getTrustedServerHosts(): string[] {
    return [...this.trustedServerHosts];
  }

  public getPreferredServerHost(): string | undefined {
    return this.preferredServerHost;
  }

  public isTrustedServerHost(hostname: string | undefined): boolean {
    const normalizedHost = normalizeHost(hostname);
    return normalizedHost ? this.trustedServerHostsNormalized.has(normalizedHost) : false;
  }

  public isTrustedHostHeader(hostHeader?: string | string[]): boolean {
    return this.isTrustedServerHost(extractHostFromHeader(hostHeader));
  }

  public isLocalRequestAddress(remoteAddress?: string): boolean {
    const normalizedAddress = normalizeAddress(remoteAddress);
    return normalizedAddress ? this.localRequestAddresses.has(normalizedAddress) : false;
  }

  public isTrustedLocalServerRequest(request: TrustedLocalServerRequest): boolean {
    return this.isTrustedHostHeader(request.hostHeader) && this.isLocalRequestAddress(request.remoteAddress);
  }

  public isTrustedOrigin(origin?: string): boolean {
    if (!origin) {
      return true;
    }

    try {
      const parsedOrigin = new URL(origin);
      const effectivePort = parsedOrigin.port || defaultPortForProtocol(parsedOrigin.protocol);
      return this.isTrustedServerHost(parsedOrigin.hostname) && this.allowedCorsPorts.has(effectivePort);
    } catch (_error) {
      return false;
    }
  }

  private initializeAllowedCorsPorts(): void {
    this.allowedCorsPorts.add(this.options.serverPort.toString());

    if (!this.options.allowDevServerOrigins) {
      return;
    }

    for (const port of this.options.devServerPorts ?? DEFAULT_DEV_SERVER_PORTS) {
      this.allowedCorsPorts.add(port);
    }
  }

  private initializeLoopbackAddresses(): void {
    for (const loopbackHost of LOOPBACK_HOSTS) {
      this.addTrustedServerHost(loopbackHost);
    }

    for (const loopbackAddress of LOOPBACK_REQUEST_ADDRESSES) {
      this.addLocalRequestAddress(loopbackAddress);
    }
  }

  private registerLocalIpv4Addresses(): string[] {
    const localIpv4Addresses: string[] = [];
    const networkInterfaces = this.options.networkInterfaces ?? os.networkInterfaces();

    for (const addressEntries of Object.values(networkInterfaces)) {
      if (!addressEntries) {
        continue;
      }

      for (const entry of addressEntries) {
        if (entry.internal || entry.family !== 'IPv4') {
          continue;
        }

        localIpv4Addresses.push(entry.address);
        this.addTrustedServerHost(entry.address);
        this.addLocalRequestAddress(entry.address);
      }
    }

    return localIpv4Addresses;
  }

  private registerHostname(): string | undefined {
    const hostname = this.options.hostname ?? os.hostname();
    if (hostname) {
      this.addTrustedServerHost(hostname);
    }

    return hostname;
  }

  private choosePreferredServerHost(localIpv4Addresses: string[], hostname?: string): string {
    return localIpv4Addresses[0] ?? hostname ?? 'localhost';
  }

  private addTrustedServerHost(host: string): void {
    const normalizedHost = normalizeHost(host);
    if (!normalizedHost || this.trustedServerHostsNormalized.has(normalizedHost)) {
      return;
    }

    this.trustedServerHosts.push(host);
    this.trustedServerHostsNormalized.add(normalizedHost);
  }

  private addLocalRequestAddress(address: string): void {
    const normalizedAddress = normalizeAddress(address);
    if (!normalizedAddress) {
      return;
    }

    this.localRequestAddresses.add(normalizedAddress);
  }
}
