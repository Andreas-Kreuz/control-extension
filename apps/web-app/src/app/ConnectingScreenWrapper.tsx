import { useSocketUrl } from '../socket/SocketProvider';
import ConnectingScreen from '../components/ConnectingScreen';

function ConnectingScreenWrapper() {
  const socketUrl = useSocketUrl();
  return <ConnectingScreen url={socketUrl} />;
}

export default ConnectingScreenWrapper;
