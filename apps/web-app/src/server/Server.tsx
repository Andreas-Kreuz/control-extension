import Box from '@mui/material/Box';
import './Server.css';
import ServerHome from './ServerHome';
import ConnectingScreenWrapper from '../base/ConnectingScreenWrapper';
import { useSocketIsAdmin, useSocketIsConnected, useSocketPairingStatus } from '../io/SocketProvider';
import { PairingStatus } from '@ak/web-shared';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import { Navigate } from 'react-router-dom';

function Server() {
  const socketIsConnected = useSocketIsConnected();
  const pairingStatus = useSocketPairingStatus();
  const isAdmin = useSocketIsAdmin();

  if (!socketIsConnected || pairingStatus === PairingStatus.Connecting) {
    return <ConnectingScreenWrapper />;
  }

  if (!isAdmin) {
    return <Navigate replace to="/" />;
  }

  return (
    <div className="Server">
      <Box sx={{ minHeight: '100vh' }}>
        <AppBar>
          <Toolbar>
            <Typography variant="h6" component="div" sx={{ flexGrow: 1, display: 'block' }}>
              CE Server
            </Typography>
          </Toolbar>
        </AppBar>
        <Toolbar />
        <ServerHome />
      </Box>
    </div>
  );
}

export default Server;
