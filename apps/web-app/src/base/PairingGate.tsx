import { ReactNode } from 'react';
import { PairingStatus } from '@ce/web-shared';
import ConnectingScreen from '../ui/ConnectingScreen';
import PairingScreen from '../ui/PairingScreen';
import { useSocketIsConnected, useSocketPairingCode, useSocketPairingStatus, useSocketUrl } from '../io/SocketProvider';

function PairingGate(props: { children: ReactNode }) {
  const currentPath = window.location.pathname;
  const socketUrl = useSocketUrl();
  const socketIsConnected = useSocketIsConnected();
  const pairingStatus = useSocketPairingStatus();
  const pairingCode = useSocketPairingCode();

  // Show /server directlywithout the pairing gate.
  if (currentPath.startsWith('/server')) {
    return <>{props.children}</>;
  }

  // Show the connecting screen if we're not connected or still in pairing process.
  if (!socketIsConnected || pairingStatus === PairingStatus.Connecting) {
    return <ConnectingScreen url={socketUrl} />;
  }

  // Show the pairing code if we're in the pending state.
  if (pairingStatus === PairingStatus.Pending) {
    return <PairingScreen {...(pairingCode !== undefined ? { pairingCode } : {})} />;
  }

  return <>{props.children}</>;
}

export default PairingGate;

