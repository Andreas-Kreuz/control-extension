import CamIcon from '@mui/icons-material/Videocam';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import useMediaQuery from '@mui/material/useMediaQuery';
import { useTheme } from '@mui/material/styles';
import { useSocket } from '../../../app/hooks/useSocket';
import { CommandEvent } from '@ce/web-shared';
import Intersection from '../model/Intersection';
import TypeCaption from '../../../shared/components/TypeCaption';

function IntersectionCamsSection({ intersection: i }: { intersection: Intersection }) {
  const theme = useTheme();
  const showCameraNames = useMediaQuery(theme.breakpoints.down('lg'));
  const socket = useSocket();

  function changeCam(camName: string) {
    socket.emit(CommandEvent.ChangeCamToStatic, { staticCam: camName });
  }

  if (!i.staticCams || i.staticCams.length === 0) {
    return (
      <Alert severity="info" sx={{ border: 1, borderColor: 'info.main', alignItems: 'top' }} icon={false}>
        <Typography variant="body2" sx={{ fontWeight: 'bolder' }} gutterBottom>
          Tipp: Kameras hinzufügen
        </Typography>
        <Typography variant="body2">
          So hast Du Deine Kreuzung angelegt:
          <Box component="pre" sx={{ fontSize: 14, whiteSpace: 'normal' }}>
            c1 = Crossing:new(...)
          </Box>
          Suche Dir nun eine statische Kamera aus und füge ihren Namen wie folgt hinzu:
          <Box component="pre" sx={{ fontSize: 14, whiteSpace: 'normal' }}>
            c1:addStaticCam('Kameraname')
          </Box>
        </Typography>
      </Alert>
    );
  }

  return (
    <Stack>
      <TypeCaption>Kameras</TypeCaption>
      <Stack
        direction={showCameraNames ? 'column' : 'row'}
        sx={{ pt: 1, flexWrap: showCameraNames ? 'nowrap' : 'wrap', alignItems: 'flex-start' }}
      >
        {i.staticCams.map((c, j) => (
          <Tooltip key={c} title={c} disableHoverListener={showCameraNames} disableTouchListener={showCameraNames}>
            <Chip
              sx={{ mr: showCameraNames ? 0 : 1, mb: 1, maxWidth: 1, justifyContent: 'flex-start' }}
              color="secondary"
              icon={<CamIcon />}
              label={showCameraNames || i.staticCams.length === 1 ? c : j}
              variant="outlined"
              clickable
              onClick={() => changeCam(c)}
            />
          </Tooltip>
        ))}
      </Stack>
    </Stack>
  );
}

export default IntersectionCamsSection;
