import { PairingEvent, PairingStatus, PairingStatusPayload } from '@ce/web-shared';
import { ReactNode, useContext, useEffect, useState } from 'react';
import useDebug from '../../shared/socket/useDebug';
import {
  SocketAdminContext,
  SocketConnectedContext,
  SocketContext,
  SocketPairingCodeContext,
  SocketPairingStatusContext,
  SocketUrlContext,
} from './socketContexts';
import { getOrCreateClientKey, socketUrl } from './socketClient';

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
