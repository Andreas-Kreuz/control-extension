import SocketService from '../clientio/SocketService';
import AppEffects from './AppEffects';
import CommandLineParser from './config/CommandLineParser';
import TrustedServerAddressPolicy from './config/TrustedServerAddressPolicy';
import * as cors from 'cors';
import { EventEmitter } from 'events';
import * as express from 'express';
import { createServer } from 'http';
import * as path from 'path';
import { Server } from 'socket.io';

interface ServerMainOptions {
  adminSessionValue?: string;
  allowOpenServerRoute?: boolean;
  allowViteDevServerRoute?: boolean;
}

function dirPage(title: string, items: string): string {
  return `<!DOCTYPE html><html><head><meta charset="utf-8"><title>${title}</title>
<style>body{font-family:sans-serif;padding:2rem;max-width:600px}h1{color:#333}a{color:#0070f3}li{margin:.3rem 0}</style>
</head><body><h1>${title}</h1><ul>${items}</ul></body></html>`;
}

export class ServerMain {
  private adminCookieName = 'ce-admin-session';
  private app: express.Application;
  private allowOpenServerRoute: boolean;
  private appEffects!: AppEffects;
  private httpServer;
  private io: Server;
  private router: express.Router;
  private socketService: SocketService;
  private trustedServerAddressPolicy: TrustedServerAddressPolicy;

  constructor(
    private serverConfigPath: string,
    private port = 3000,
    private options: ServerMainOptions = {},
  ) {
    this.app = express();
    this.httpServer = createServer(this.app);
    this.router = express.Router();

    this.configureProcessDefaults();
    this.configureApplication();
    this.allowOpenServerRoute = this.resolveAllowOpenServerRoute();
    this.trustedServerAddressPolicy = this.createTrustedServerAddressPolicy();
    this.io = this.createSocketIoServer();
    this.socketService = this.createSocketService();
  }

  public start() {
    console.log('Starting Server with ' + this.serverConfigPath);
    const appDir = this.resolveAppDirectory();

    this.registerApiRoutes();
    this.registerServerRouteProtection();
    this.registerStaticRoutes(appDir);
    this.registerSpaFallback(appDir);
    this.startHttpServer();
    this.appEffects = new AppEffects(this.app, this.router, this.io, this.socketService, this.serverConfigPath);
    this.appEffects.changeEepDirectory(this.appEffects.getEepDirectory());
  }

  private configureProcessDefaults(): void {
    EventEmitter.defaultMaxListeners = 50;
  }

  private configureApplication(): void {
    this.app.set('port', this.port);
    this.app.use(cors(this.createCorsOptions()));
  }

  private resolveAllowOpenServerRoute(): boolean {
    const parsedCommandLineOptions = new CommandLineParser().parseOptions();
    return this.options.allowOpenServerRoute ?? Boolean(parsedCommandLineOptions['testmode']);
  }

  private createTrustedServerAddressPolicy(): TrustedServerAddressPolicy {
    return new TrustedServerAddressPolicy({
      serverPort: this.port,
      allowDevServerOrigins: this.options.allowViteDevServerRoute || this.allowOpenServerRoute,
    });
  }

  private createSocketIoServer(): Server {
    return new Server(this.httpServer, {
      cors: this.createCorsOptions(),
      allowRequest: (req, callback) => callback(null, this.isAllowedSocketRequest(req)),
    });
  }

  private createSocketService(): SocketService {
    return new SocketService(this.io, {
      adminCookieName: this.adminCookieName,
      allowOpenServerRoute: this.allowOpenServerRoute,
      ...(this.options.adminSessionValue !== undefined ? { adminSessionValue: this.options.adminSessionValue } : {}),
      ...(this.options.allowViteDevServerRoute !== undefined
        ? { allowViteDevServerRoute: this.options.allowViteDevServerRoute }
        : {}),
      trustedServerAddressPolicy: this.trustedServerAddressPolicy,
    });
  }

  private resolveAppDirectory(): string {
    return path.join(__dirname, '../../public_html');
  }

  private registerApiRoutes(): void {
    this.app.use('/api/v1', this.router);
    this.registerApiIndexRoute();
    this.registerApiRootRoute();
  }

  private registerApiIndexRoute(): void {
    this.app.get('/api/v1', (_req: express.Request, res: express.Response) => {
      res.setHeader('Content-Type', 'text/html');
      res.send(dirPage('/api/v1', ''));
    });
  }

  private registerApiRootRoute(): void {
    this.app.get('/api', (_req: express.Request, res: express.Response) => {
      res.setHeader('Content-Type', 'text/html');
      res.send(dirPage('/api', '<li><a href="/api/v1">v1</a></li>'));
    });
  }

  private registerServerRouteProtection(): void {
    this.app.use((req: express.Request, res: express.Response, next: express.NextFunction) =>
      this.handleServerRouteProtection(req, res, next),
    );
  }

  private registerStaticRoutes(appDir: string): void {
    this.registerAssetRoute(path.join(appDir, 'assets'));
    this.registerAppRoute(appDir);
  }

  private registerAssetRoute(appAssetsDir: string): void {
    this.app.use(
      '/assets',
      express.static(appAssetsDir, {
        immutable: true,
        maxAge: '1y',
      }),
    );
  }

  private registerAppRoute(appDir: string): void {
    this.app.use(
      '/',
      express.static(appDir, {
        setHeaders: (res, filePath) => this.setStaticCacheHeaders(res, filePath),
      }),
    );
  }

  private setStaticCacheHeaders(res: express.Response, filePath: string): void {
    if (filePath.endsWith('.html')) {
      res.setHeader('Cache-Control', 'no-cache');
      return;
    }

    res.setHeader('Cache-Control', 'public, max-age=86400');
  }

  private registerSpaFallback(appDir: string): void {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    this.app.get('/{*splat}', (_req: any, res: any) => {
      res.setHeader('Cache-Control', 'no-cache');
      res.sendFile(path.join(appDir, '/index.html'));
    });
  }

  private startHttpServer(): void {
    this.httpServer.listen(this.port, () => {
      console.log('Express server listening on port ' + this.app.get('port') + ' ## ' + this.serverConfigPath);
    });
  }

  private handleServerRouteProtection(req: express.Request, res: express.Response, next: express.NextFunction): void {
    if (!this.isServerRoute(req)) {
      next();
      return;
    }

    if (this.isOpenServerRouteAllowed()) {
      next();
      return;
    }

    if (this.tryBootstrapAdminSession(req, res)) {
      return;
    }

    if (this.hasAdminSessionCookie(req)) {
      next();
      return;
    }

    if (this.isTrustedLocalServerRequest(req)) {
      next();
      return;
    }

    res.redirect('/');
  }

  private isServerRoute(req: express.Request): boolean {
    return req.path.startsWith('/server');
  }

  private isOpenServerRouteAllowed(): boolean {
    return this.allowOpenServerRoute;
  }

  private tryBootstrapAdminSession(req: express.Request, res: express.Response): boolean {
    const bootstrapToken = typeof req.query.adminBootstrap === 'string' ? req.query.adminBootstrap : undefined;
    if (!bootstrapToken || !this.options.adminSessionValue || bootstrapToken !== this.options.adminSessionValue) {
      return false;
    }

    res.setHeader('Set-Cookie', this.serializeCookie(this.adminCookieName, this.options.adminSessionValue));
    res.redirect('/server');
    return true;
  }

  private hasAdminSessionCookie(req: express.Request): boolean {
    if (!this.options.adminSessionValue) {
      return false;
    }

    const cookies = this.parseCookies(req.headers.cookie);
    return cookies[this.adminCookieName] === this.options.adminSessionValue;
  }

  private isTrustedLocalServerRequest(req: express.Request): boolean {
    return this.trustedServerAddressPolicy.isTrustedLocalServerRequest({
      hostHeader: req.headers.host,
      remoteAddress: req.socket.remoteAddress,
    });
  }

  private createCorsOptions(): cors.CorsOptions {
    return {
      origin: (origin, callback) =>
        callback(null, this.trustedServerAddressPolicy.isTrustedOrigin(origin ?? undefined)),
      credentials: false,
      methods: ['GET', 'POST'],
    };
  }

  private isAllowedSocketRequest(req: {
    headers: { host?: string | undefined; origin?: string | string[] | undefined };
  }): boolean {
    return this.trustedServerAddressPolicy.isTrustedHostHeader(req.headers.host) && this.hasTrustedOriginHeader(req);
  }

  private hasTrustedOriginHeader(req: { headers: { origin?: string | string[] | undefined } }): boolean {
    return this.trustedServerAddressPolicy.isTrustedOrigin(
      typeof req.headers.origin === 'string' ? req.headers.origin : undefined,
    );
  }

  private parseCookies(cookieHeader?: string): Record<string, string> {
    if (!cookieHeader) {
      return {};
    }

    return cookieHeader.split(';').reduce<Record<string, string>>((cookies, cookieChunk) => {
      const separatorIndex = cookieChunk.indexOf('=');
      if (separatorIndex < 0) {
        return cookies;
      }

      const name = cookieChunk.slice(0, separatorIndex).trim();
      const value = cookieChunk.slice(separatorIndex + 1).trim();
      cookies[name] = decodeURIComponent(value);
      return cookies;
    }, {});
  }

  private serializeCookie(name: string, value: string): string {
    return name + '=' + encodeURIComponent(value) + '; Path=/; HttpOnly; SameSite=Strict';
  }
}
