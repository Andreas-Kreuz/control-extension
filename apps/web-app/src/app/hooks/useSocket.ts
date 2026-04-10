import { useContext } from 'react';
import { SocketContext } from '../providers/socketContexts';

export function useSocket() {
  return useContext(SocketContext);
}
