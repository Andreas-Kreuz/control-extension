import { useContext } from 'react';
import { SocketConnectedContext } from '../providers/socketContexts';

export function useSocketIsConnected() {
  return useContext(SocketConnectedContext);
}
