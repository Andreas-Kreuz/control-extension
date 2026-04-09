import ConnectingScreen from '../../shared/ui/ConnectingScreen';
import { useSocketUrl } from '../providers/SocketProvider';

function ConnectingScreenWrapper() {
  const socketUrl = useSocketUrl();
  return <ConnectingScreen url={socketUrl} />;
}

export default ConnectingScreenWrapper;

