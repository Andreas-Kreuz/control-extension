import { ThemeProvider as MuiThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { theme } from '../theme/theme';
import SocketProvider from '../providers/SocketProvider';
import WebRouter from './WebRouter';

function WebRoot() {
  return (
    <MuiThemeProvider theme={theme}>
      <SocketProvider>
        <CssBaseline />
        <WebRouter />
      </SocketProvider>
    </MuiThemeProvider>
  );
}

export default WebRoot;
