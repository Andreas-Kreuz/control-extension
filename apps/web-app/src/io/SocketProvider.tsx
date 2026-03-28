import { PairingEvent, PairingStatus, PairingStatusPayload } from '@ak/web-shared';
import { createContext, ReactNode, useEffect, useState } from 'react';
import { io } from 'socket.io-client';
import { useContext } from 'react';
import useDebug from './useDebug';

const clientStorageKey = 'ce-client-key';
const socketUrl = window.location.protocol + '//' + window.location.hostname + ':3000';
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
  const socket = useContext(SocketContext);
  const [isConnected, setIsConnected] = useState(() => socket.connected);
  const [pairingStatus, setPairingStatus] = useState(PairingStatus.Connecting);
  const [pairingCode, setPairingCode] = useState<string>();
  const [isAdmin, setIsAdmin] = useState(false);
  const debug = useDebug();

  useEffect(() => {
    socket.auth = {
      clientKey: getOrCreateClientKey(),
      requestedPath: window.location.pathname,
    };

    const connector = () => {
      if (debug) console.log('SOCKET CONNECT    ☑️☑️☑️☑️☑️', socket.id, "'connect' received");
      setIsConnected(true);
    };

    const pairingStatusHandler = (payload: PairingStatusPayload) => {
      setPairingStatus(payload.status);
      setPairingCode(payload.code);
      setIsAdmin(payload.status === PairingStatus.Admin || payload.isAdmin === true);
    };

    const disconnector = () => {
      if (debug) console.log('SOCKET DISCONNECT ✴️✴️✴️✴️✴️', socket.id, "'disconnect' received");
      setIsConnected(false);
      setPairingStatus(PairingStatus.Connecting);
      setPairingCode(undefined);
      setIsAdmin(false);
    };

    socket.on('connect', connector);
    socket.on(PairingEvent.Status, pairingStatusHandler);
    socket.on('disconnect', disconnector);

    if (socket.connected) {
      setIsConnected(true);
    } else {
      socket.connect();
    }

    return () => {
      if (socket) {
        socket.disconnect();
        socket.off('connect', connector);
        socket.off(PairingEvent.Status, pairingStatusHandler);
        socket.off('disconnect', disconnector);
      }
      setIsConnected(false);
      setPairingStatus(PairingStatus.Connecting);
      setPairingCode(undefined);
      setIsAdmin(false);
    };
  }, []);

  return (
    <SocketUrlContext.Provider value={socketUrl}>
      <SocketContext.Provider value={socket}>
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
