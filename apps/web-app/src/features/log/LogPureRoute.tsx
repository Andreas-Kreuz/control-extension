import Box from '@mui/material/Box';
import LogLines from './components/LogLines';
import { LogProvider } from './providers/LogProvider';

function LogPureRoute() {
  return (
    <LogProvider>
      <Box
        sx={{
          position: 'fixed',
          inset: 0,
          zIndex: (theme) => theme.zIndex.modal,
          overflow: 'hidden',
          bgcolor: 'background.default',
        }}
      >
        <LogLines height="100vh" width="100vw" />
      </Box>
    </LogProvider>
  );
}

export default LogPureRoute;
