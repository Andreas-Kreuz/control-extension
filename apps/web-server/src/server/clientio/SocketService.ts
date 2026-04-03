import {
  ApprovePairingClientPayload,
  PairingEvent,
  PairingStatus,
  PairingStatusPayload,
  PendingPairingClient,
  RoomEvent,
} from '@ce/web-shared';
import { Server, Socket } from 'socket.io';
import TrustedServerAddressPolicy from '../app/config/TrustedServerAddressPolicy';

interface SocketServiceOptions {
  adminCookieName?: string | undefined;
  adminSessionValue?: string | undefined;
  allowOpenServerRoute?: boolean | undefined;
  trustedServerAddressPolicy?: TrustedServerAddressPolicy | undefined;
}

export default class SocketService {
  private debug = true;
  private onSocketConnectedCallbacks: Array<(socket: Socket) => void> = [];
  private pairingRequired = true;
  private approvedClientKeys = new Set<string>();
  private pendingClients = new Map<string, PendingPairingClient>();
  private activeSocketsByClientKey = new Map<string, Set<string>>();
  private adminCookieName: string;
  private adminSessionValue: string | undefined;
  private allowOpenServerRoute: boolean;
  private trustedServerAddressPolicy: TrustedServerAddressPolicy | undefined;

  constructor(
    private io: Server,
    options: SocketServiceOptions = {},
  ) {
    this.adminCookieName = options.adminCookieName ?? 'ce-admin-session';
    this.adminSessionValue = options.adminSessionValue;
    this.allowOpenServerRoute = options.allowOpenServerRoute ?? false;
    this.trustedServerAddressPolicy = options.trustedServerAddressPolicy;
    this.allowRoomJoining();
  }

  /**
   * This will allow room joining for all new incoming connections
   */
  private allowRoomJoining() {
    this.io.on('connection', (socket: Socket) => {
      if (this.debug) console.log('✅ CONNECT FROM ' + socket.id);
      this.initializePairing(socket);

      for (const addSocketEvents of this.onSocketConnectedCallbacks) {
        addSocketEvents(socket);
      }

      socket.on(RoomEvent.JoinRoom, (room: { room: string }) => {
        if (!this.ensureApprovedSocket(socket, RoomEvent.JoinRoom + ' ' + room.room)) {
          return;
        }
        socket.join(room.room);
        if (this.debug) console.log('➕ JOIN by ' + socket.id + ': ' + room.room);
      });

      socket.on(RoomEvent.LeaveRoom, (room: { room: string }) => {
        socket.leave(room.room);
        if (this.debug) console.log('➖ LEFT by ' + socket.id + ': ' + room.room);
      });

      socket.on(PairingEvent.ApproveClient, (payload: ApprovePairingClientPayload) => {
        if (!this.ensureAdminSocket(socket, PairingEvent.ApproveClient)) {
          return;
        }
        this.approveClient(payload.clientKey);
      });

      socket.on(PairingEvent.PendingList, () => {
        if (!this.ensureAdminSocket(socket, PairingEvent.PendingList)) {
          return;
        }
        this.emitPendingClientsToAdmin(socket);
      });

      socket.on('disconnect', () => {
        if (this.debug) console.log('✴️  DISCONNECT FROM ' + socket.id);
        this.unregisterSocket(socket);
      });
    });
  }

  public addOnSocketConnectedCallback(callback: (socket: Socket) => void): void {
    this.onSocketConnectedCallbacks.push(callback);
  }

  public resetOnSocketConnectedCallbacks(): void {
    this.onSocketConnectedCallbacks = [];
  }

  public setPairingRequired(pairingRequired: boolean): void {
    this.pairingRequired = pairingRequired;

    if (!pairingRequired) {
      for (const clientKey of Array.from(this.pendingClients.keys())) {
        this.approveClient(clientKey);
      }
    }
  }

  public ensureApprovedSocket(socket: Socket, eventName: string): boolean {
    if (this.isApprovedOrAdminSocket(socket)) {
      return true;
    }

    if (this.debug) console.log('🚫 DENY for ' + socket.id + ': ' + eventName);
    return false;
  }

  public ensureAdminSocket(socket: Socket, eventName: string): boolean {
    if (this.isAdminSocket(socket)) {
      return true;
    }

    if (this.debug) console.log('🚫 DENY ADMIN for ' + socket.id + ': ' + eventName);
    return false;
  }

  public isAdminSocket(socket: Socket): boolean {
    return socket.data.pairingStatus === PairingStatus.Admin;
  }

  public isApprovedOrAdminSocket(socket: Socket): boolean {
    return socket.data.pairingStatus === PairingStatus.Approved || this.isAdminSocket(socket);
  }

  private initializePairing(socket: Socket): void {
    const requestedPath = this.readRequestedPath(socket);
    const clientKey = this.readClientKey(socket);
    socket.data.clientKey = clientKey;
    socket.data.requestedPath = requestedPath;

    if (this.isTrustedAdminRequest(socket, requestedPath)) {
      socket.data.pairingStatus = PairingStatus.Admin;
      this.emitPairingStatus(socket, PairingStatus.Admin);
      this.emitPendingClientsToAdmins();
      return;
    }

    this.registerSocketByClientKey(clientKey, socket.id);

    if (this.isTrustedLocalClientRequest(socket) || !this.pairingRequired || this.approvedClientKeys.has(clientKey)) {
      socket.data.pairingStatus = PairingStatus.Approved;
      this.emitPairingStatus(socket, PairingStatus.Approved);
      return;
    }

    const pendingClient = this.upsertPendingClient(clientKey, requestedPath, socket.id);
    socket.data.pairingStatus = PairingStatus.Pending;
    socket.data.pairingCode = pendingClient.code;
    this.emitPairingStatus(socket, PairingStatus.Pending, pendingClient.code);
    this.emitPendingClientsToAdmins();
  }

  private readRequestedPath(socket: Socket): string {
    const auth = socket.handshake.auth as { requestedPath?: unknown } | undefined;
    return typeof auth?.requestedPath === 'string' && auth.requestedPath.length > 0 ? auth.requestedPath : '/';
  }

  private readClientKey(socket: Socket): string {
    const auth = socket.handshake.auth as { clientKey?: unknown } | undefined;
    if (typeof auth?.clientKey === 'string' && auth.clientKey.length > 0) {
      return auth.clientKey;
    }

    return socket.id;
  }

  private isTrustedAdminRequest(socket: Socket, requestedPath: string): boolean {
    if (!requestedPath.startsWith('/server')) {
      return false;
    }

    if (this.allowOpenServerRoute && requestedPath.startsWith('/server')) {
      return true;
    }

    if (
      this.trustedServerAddressPolicy?.isTrustedLocalServerRequest({
        hostHeader: socket.handshake.headers.host,
        remoteAddress: socket.handshake.address,
      })
    ) {
      return true;
    }

    if (!this.adminSessionValue) {
      return false;
    }

    const cookies = this.parseCookies(socket.handshake.headers.cookie);
    return cookies[this.adminCookieName] === this.adminSessionValue;
  }

  private isTrustedLocalClientRequest(socket: Socket): boolean {
    return (
      this.trustedServerAddressPolicy?.isTrustedLocalServerRequest({
        hostHeader: socket.handshake.headers.host,
        remoteAddress: socket.handshake.address,
      }) ?? false
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

  private registerSocketByClientKey(clientKey: string, socketId: string): void {
    const currentSocketIds = this.activeSocketsByClientKey.get(clientKey) ?? new Set<string>();
    currentSocketIds.add(socketId);
    this.activeSocketsByClientKey.set(clientKey, currentSocketIds);
  }

  private unregisterSocket(socket: Socket): void {
    const clientKey = typeof socket.data.clientKey === 'string' ? socket.data.clientKey : undefined;
    if (!clientKey) {
      return;
    }

    const currentSocketIds = this.activeSocketsByClientKey.get(clientKey);
    currentSocketIds?.delete(socket.id);

    if (currentSocketIds && currentSocketIds.size === 0) {
      this.activeSocketsByClientKey.delete(clientKey);

      if (!this.approvedClientKeys.has(clientKey) && this.pendingClients.has(clientKey)) {
        this.pendingClients.delete(clientKey);
        this.emitPendingClientsToAdmins();
      }
    }
  }

  private upsertPendingClient(clientKey: string, requestedPath: string, socketId: string): PendingPairingClient {
    const existingClient = this.pendingClients.get(clientKey);
    if (existingClient) {
      const updatedClient = {
        ...existingClient,
        requestedPath,
        socketId,
      };
      this.pendingClients.set(clientKey, updatedClient);
      return updatedClient;
    }

    const pendingClient: PendingPairingClient = {
      clientKey,
      code: this.createPairingCode(),
      connectedAt: Date.now(),
      requestedPath,
      socketId,
    };
    this.pendingClients.set(clientKey, pendingClient);
    return pendingClient;
  }

  private createPairingCode(): string {
    let code = '';
    const codesInUse = new Set(Array.from(this.pendingClients.values()).map((client) => client.code));

    do {
      const left = Math.floor(Math.random() * 1000)
        .toString()
        .padStart(3, '0');
      const right = Math.floor(Math.random() * 1000)
        .toString()
        .padStart(3, '0');
      code = left + '-' + right;
    } while (codesInUse.has(code));

    return code;
  }

  private emitPairingStatus(socket: Socket, status: PairingStatus, code?: string): void {
    const payload: PairingStatusPayload = {
      status,
      isAdmin: status === PairingStatus.Admin,
      ...(code !== undefined ? { code } : {}),
      ...(typeof socket.data.clientKey === 'string' ? { clientKey: socket.data.clientKey } : {}),
    };
    socket.emit(PairingEvent.Status, payload);
  }

  private emitPendingClientsToAdmins(): void {
    const pendingClients = Array.from(this.pendingClients.values()).sort(
      (left, right) => left.connectedAt - right.connectedAt,
    );

    for (const socket of this.io.sockets.sockets.values()) {
      if (this.isAdminSocket(socket)) {
        this.emitPendingClientsToAdmin(socket, pendingClients);
      }
    }
  }

  private emitPendingClientsToAdmin(socket: Socket, pendingClients?: PendingPairingClient[]): void {
    socket.emit(
      PairingEvent.PendingList,
      pendingClients ??
        Array.from(this.pendingClients.values()).sort((left, right) => left.connectedAt - right.connectedAt),
    );
  }

  private approveClient(clientKey: string): void {
    if (!clientKey) {
      return;
    }

    this.approvedClientKeys.add(clientKey);
    this.pendingClients.delete(clientKey);

    const socketIds = this.activeSocketsByClientKey.get(clientKey);
    if (socketIds) {
      for (const socketId of socketIds) {
        const socket = this.io.sockets.sockets.get(socketId);
        if (!socket) {
          continue;
        }

        socket.data.pairingStatus = PairingStatus.Approved;
        delete socket.data.pairingCode;
        this.emitPairingStatus(socket, PairingStatus.Approved);
      }
    }

    this.emitPendingClientsToAdmins();
  }
}

