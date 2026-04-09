import ConnectingScreen from '../../shared/ui/ConnectingScreen';
import { useSocketUrl } from '../hooks/useSocketUrl';

function ConnectingScreenHost() {
  const socketUrl = useSocketUrl();
  return <ConnectingScreen url={socketUrl} />;
}

export default ConnectingScreenHost;
