import { LogProvider } from './providers/LogProvider';
import LogPanel from './components/LogPanel';

const LogMod = () => {
  return (
    <LogProvider>
      <LogPanel />
    </LogProvider>
  );
};

export default LogMod;
