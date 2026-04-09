import { lazy } from 'react';
import { ThemeProvider as MuiThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { theme } from '../theme/theme';

const SocketProvider = lazy(() => import('../providers/SocketProvider'));
const WebAppRouter = lazy(() => import('./WebAppRouter'));

function WebAppRoot() {
  return (
    <MuiThemeProvider theme={theme}>
      <SocketProvider>
        <CssBaseline />
        <WebAppRouter />
      </SocketProvider>
    </MuiThemeProvider>
  );
}

export default WebAppRoot;
