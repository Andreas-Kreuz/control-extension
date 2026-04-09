import { PairingEvent, PairingStatus, PairingStatusPayload } from '@ce/web-shared';
import { createContext, ReactNode, useContext, useEffect, useState } from 'react';
import { io } from 'socket.io-client';
import useDebug from '../../shared/socket/useDebug';

const clientStorageKey = 'ce-client-key';

function resolveSocketUrl(): string {
  if (import.meta.env.VITE_SOCKET_URL) {
    return import.meta.env.VITE_SOCKET_URL;
  }

  const currentPort = window.location.port;
  if (currentPort === '3000' || currentPort === '3001') {
    return window.location.origin;
  }

  return window.location.protocol + '//' + window.location.hostname + ':3000';
}

const socketUrl = resolveSocketUrl();
const socket = io(socketUrl, { autoConnect: false });

const SocketConnectedContext = createContext<boolean>(false);
const SocketUrlContext = createContext(socketUrl);
const SocketContext = createContext(socket);
const SocketPairingStatusContext = createContext<PairingStatus>(PairingStatus.Connecting);
const SocketPairingCodeContext = createContext<string | undefined>(undefined);
const SocketAdminContext = createContext<boolean>(false);

function createClientKey(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }

  return 'ce-' + Math.random().toString(36).slice(2) + '-' + Date.now().toString(36);
}

function getOrCreateClientKey(): string {
  try {
    const existingClientKey = window.localStorage.getItem(clientStorageKey);
    if (existingClientKey) {
      return existingClientKey;
    }

    const newClientKey = createClientKey();
    window.localStorage.setItem(clientStorageKey, newClientKey);
    return newClientKey;
  } catch (_error) {
    return createClientKey();
  }
}

const SocketProvider = (props: { children: ReactNode }) => {
  const providedSocket = useContext(SocketContext);
  const [isConnected, setIsConnected] = useState(() => providedSocket.connected);
  const [pairingStatus, setPairingStatus] = useState(PairingStatus.Connecting);
  const [pairingCode, setPairingCode] = useState<string>();
  const [isAdmin, setIsAdmin] = useState(false);
  const debug = useDebug();

  useEffect(() => {
    providedSocket.auth = {
      clientKey: getOrCreateClientKey(),
      requestedPath: window.location.pathname,
    };

    const connector = () => {
      if (debug) console.log('SOCKET CONNECT    ☑️☑️☑️☑️☑️', providedSocket.id, "'connect' received");
      setIsConnected(true);
    };

    const pairingStatusHandler = (payload: PairingStatusPayload) => {
      setPairingStatus(payload.status);
      setPairingCode(payload.code);
      setIsAdmin(payload.status === PairingStatus.Admin || payload.isAdmin === true);
    };

    const disconnector = () => {
      if (debug) console.log('SOCKET DISCONNECT ✴️✴️✴️✴️✴️', providedSocket.id, "'disconnect' received");
      setIsConnected(false);
      setPairingStatus(PairingStatus.Connecting);
      setPairingCode(undefined);
      setIsAdmin(false);
    };

    providedSocket.on('connect', connector);
    providedSocket.on(PairingEvent.Status, pairingStatusHandler);
    providedSocket.on('disconnect', disconnector);

    if (providedSocket.connected) {
      setIsConnected(true);
    } else {
      providedSocket.connect();
    }

    return () => {
      providedSocket.disconnect();
      providedSocket.off('connect', connector);
      providedSocket.off(PairingEvent.Status, pairingStatusHandler);
      providedSocket.off('disconnect', disconnector);
      setIsConnected(false);
      setPairingStatus(PairingStatus.Connecting);
      setPairingCode(undefined);
      setIsAdmin(false);
    };
  }, [debug, providedSocket]);

  return (
    <SocketUrlContext.Provider value={socketUrl}>
      <SocketContext.Provider value={providedSocket}>
        <SocketPairingStatusContext.Provider value={pairingStatus}>
          <SocketPairingCodeContext.Provider value={pairingCode}>
            <SocketAdminContext.Provider value={isAdmin}>
              <SocketConnectedContext.Provider value={isConnected}>{props.children}</SocketConnectedContext.Provider>
            </SocketAdminContext.Provider>
          </SocketPairingCodeContext.Provider>
        </SocketPairingStatusContext.Provider>
      </SocketContext.Provider>
    </SocketUrlContext.Provider>
  );
};

export default SocketProvider;

export function useSocket() {
  return useContext(SocketContext);
}

export function useSocketUrl() {
  return useContext(SocketUrlContext);
}

export function useSocketIsConnected() {
  return useContext(SocketConnectedContext);
}

export function useSocketPairingStatus() {
  return useContext(SocketPairingStatusContext);
}

export function useSocketPairingCode() {
  return useContext(SocketPairingCodeContext);
}

export function useSocketIsAdmin() {
  return useContext(SocketAdminContext);
}
