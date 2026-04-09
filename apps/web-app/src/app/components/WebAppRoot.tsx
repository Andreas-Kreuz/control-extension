import { ThemeProvider as MuiThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { theme } from '../theme/theme';
import SocketProvider from '../providers/SocketProvider';
import WebAppRouter from './WebAppRouter';

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
