import { Divider as MuiDivider } from '@mui/material';
import MuiBackdrop from '@mui/material/Backdrop';
import MuiPaper from '@mui/material/Paper';
import MuiStack from '@mui/material/Stack';
import MuiTypography from '@mui/material/Typography';

export interface PairingScreenProps {
  pairingCode?: string;
}

const PairingScreen = (props: PairingScreenProps) => {
  return (
    <MuiBackdrop open>
      <MuiPaper sx={{ m: { xs: 1, sm: 'auto' }, p: { xs: 2, md: 4 }, borderRadius: 2 }} variant="outlined">
        <MuiStack sx={{ alignItems: 'center' }} spacing={1}>
          <MuiTypography gutterBottom>Die Verbindung steht. Warte auf Freigabe am Server für EEP.</MuiTypography>
          <MuiTypography
            sx={{ fontFamily: '"Roboto Mono", "Courier New", monospace', fontSize: { xs: '2.5rem', md: '3.5rem' } }}
            variant="h3"
          >
            {props.pairingCode}
          </MuiTypography>
          <MuiTypography gutterBottom>Bitte gib diesen Code auf der Server-Seite frei.</MuiTypography>
        </MuiStack>
        <MuiDivider sx={{ my: 2 }} />
        <MuiTypography gutterBottom>
          <img src={'/icon-192.png'} style={{ height: 48, float: 'left', marginRight: '1rem' }} />
          <strong>Dein Zugriff wird gerade freigegeben.</strong>
          <br />
          Sobald der Server die Anfrage bestaetigt, wird die App automatisch geoeffnet.
        </MuiTypography>
      </MuiPaper>
    </MuiBackdrop>
  );
};

export default PairingScreen;
