import { lazy } from 'react';
import { ThemeProvider as MuiThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { theme } from './theme/theme';

const SocketProvider = lazy(() => import('./providers/SocketProvider'));
const AppRouter = lazy(() => import('./router'));

function App() {
  return (
    <MuiThemeProvider theme={theme}>
      <SocketProvider>
        <CssBaseline />
        <AppRouter />
      </SocketProvider>
    </MuiThemeProvider>
  );
}

export default App;
