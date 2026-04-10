import { PairingStatus } from '@ce/web-shared';
import { createContext } from 'react';
import { socket, socketUrl } from './socketClient';

export const SocketConnectedContext = createContext<boolean>(false);
export const SocketUrlContext = createContext(socketUrl);
export const SocketContext = createContext(socket);
export const SocketPairingStatusContext = createContext<PairingStatus>(PairingStatus.Connecting);
export const SocketPairingCodeContext = createContext<string | undefined>(undefined);
export const SocketAdminContext = createContext<boolean>(false);
