import { LogProvider } from './providers/LogProvider';
import LogPanel from './components/LogPanel';

const LogOverlay = () => {
  return (
    <LogProvider>
      <LogPanel />
    </LogProvider>
  );
};

export default LogOverlay;
