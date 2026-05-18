import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Divider from '@mui/material/Divider';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import ContentCopyIcon from '@mui/icons-material/ContentCopy';
import { FeedbackMessages } from '../../../../shared/components/feedback';

export interface IntersectionWizardCodePreviewProps {
  lua: string;
  warnings: string[];
  copyEnabled: boolean;
  onCopyIntersection: () => void;
  onCopyAll: () => void;
  fullWidth?: boolean;
}

function IntersectionWizardCodePreview({
  copyEnabled,
  fullWidth = false,
  lua,
  onCopyAll,
  onCopyIntersection,
  warnings,
}: IntersectionWizardCodePreviewProps) {
  return (
    <Paper
      sx={{
        position: fullWidth ? 'static' : { xs: 'static', xl: 'sticky' },
        top: fullWidth ? 'auto' : { xl: 88 },
        overflow: fullWidth ? 'visible' : { xs: 'visible', xl: 'hidden' },
        alignSelf: fullWidth ? 'stretch' : { xl: 'start' },
        height: fullWidth ? 'auto' : { xl: 'calc(100vh - 104px)' },
        minHeight: fullWidth ? 0 : { xl: 'calc(100vh - 104px)' },
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <Stack sx={{ p: 2 }} spacing={1}>
        <Stack direction={{ xs: 'column', sm: 'row' }} spacing={1} alignItems={{ xs: 'stretch', sm: 'center' }}>
          <Typography variant="h6" sx={{ flex: 1 }}>
            Lua-Code
          </Typography>
          <Button
            size="small"
            variant="contained"
            startIcon={<ContentCopyIcon />}
            disabled={!copyEnabled || !lua}
            onClick={onCopyIntersection}
          >
            Kreuzung kopieren
          </Button>
          <Button
            size="small"
            variant="outlined"
            startIcon={<ContentCopyIcon />}
            disabled={!copyEnabled || !lua}
            onClick={onCopyAll}
          >
            Alles kopieren
          </Button>
        </Stack>
        <Typography variant="caption" color="text.secondary">
          Kreuzung kopieren: Kopiert den Kreuzungscode, kann genutzt werden, um eine Kreuzung mit gleichem Namen zu
          überschreiben oder anzulegen.
        </Typography>
        <Typography variant="caption" color="text.secondary">
          Alles kopieren: Nur beim erstmal notwendig, wenn die require-Befehle fehlen.
        </Typography>
        <FeedbackMessages messages={warnings} severity="warning" />
      </Stack>
      <Divider />
      <Box
        component="pre"
        sx={{
          flex: fullWidth ? 'none' : { xl: 1 },
          m: 0,
          p: 2,
          overflowX: 'auto',
          overflowY: fullWidth ? 'visible' : { xs: 'visible', xl: 'auto' },
          bgcolor: '#101418',
          color: '#e7edf3',
          fontSize: 13,
          lineHeight: 1.5,
        }}
      >
        {lua || '-- Der Lua-Code erscheint hier, sobald Angaben vorhanden sind.'}
      </Box>
    </Paper>
  );
}

export default IntersectionWizardCodePreview;
