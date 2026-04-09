import { io } from 'socket.io-client';

const clientStorageKey = 'ce-client-key';

export function resolveSocketUrl(): string {
  if (import.meta.env.VITE_SOCKET_URL) {
    return import.meta.env.VITE_SOCKET_URL;
  }

  const currentPort = window.location.port;
  if (currentPort === '3000' || currentPort === '3001') {
    return window.location.origin;
  }

  return window.location.protocol + '//' + window.location.hostname + ':3000';
}

export function createClientKey(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }

  return 'ce-' + Math.random().toString(36).slice(2) + '-' + Date.now().toString(36);
}

export function getOrCreateClientKey(): string {
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

export const socketUrl = resolveSocketUrl();
export const socket = io(socketUrl, { autoConnect: false });
