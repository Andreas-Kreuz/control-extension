import { useContext } from 'react';
import { SocketUrlContext } from '../providers/socketContexts';

export function useSocketUrl() {
  return useContext(SocketUrlContext);
}
