import { Box, Divider as MuiDivider } from '@mui/material';
import MuiBackdrop from '@mui/material/Backdrop';
import MuiCircularProgress from '@mui/material/CircularProgress';
import MuiPaper from '@mui/material/Paper';
import MuiStack from '@mui/material/Stack';
import MuiTypography from '@mui/material/Typography';

export interface ConnectingScreenProps {
  url: string;
}

const ConnectingScreen = (props: ConnectingScreenProps) => {
  return (
    <MuiBackdrop open>
      <MuiPaper sx={{ m: { xs: 1, sm: 'auto' }, p: { xs: 2, md: 4 }, borderRadius: 2 }} variant="outlined">
        <MuiStack sx={{ alignItems: 'center' }} spacing={1}>
          <MuiTypography gutterBottom>
            Verbindung wird wiederhergestellt{' '}
            <MuiTypography component="strong" sx={{ fontWeight: 500, wordBreak: 'break-word' }}>
              {props.url}
            </MuiTypography>
          </MuiTypography>
          <MuiCircularProgress />
        </MuiStack>
        <MuiDivider sx={{ my: 2 }} />
        <MuiStack direction="row" spacing={2} sx={{ alignItems: 'center' }}>
          <Box component="img" src="/icon-192.png" sx={{ height: 48 }} />
          <MuiTypography gutterBottom>
            <strong>Server versehentlich beendet?</strong>
            <br />
            Bitte control-extension-server.exe im Ordner EEP/LUA/ce/ starten.
          </MuiTypography>
        </MuiStack>
      </MuiPaper>
    </MuiBackdrop>
  );
};

export default ConnectingScreen;
