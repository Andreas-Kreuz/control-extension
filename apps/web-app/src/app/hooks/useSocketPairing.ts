import { useContext } from 'react';
import { SocketAdminContext, SocketPairingCodeContext, SocketPairingStatusContext } from '../providers/socketContexts';

export function useSocketPairingStatus() {
  return useContext(SocketPairingStatusContext);
}

export function useSocketPairingCode() {
  return useContext(SocketPairingCodeContext);
}

export function useSocketIsAdmin() {
  return useContext(SocketAdminContext);
}
