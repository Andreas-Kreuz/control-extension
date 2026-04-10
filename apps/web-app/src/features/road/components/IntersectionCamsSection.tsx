import CamIcon from '@mui/icons-material/Videocam';
import Alert from '@mui/material/Alert';
import Chip from '@mui/material/Chip';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { styled } from '@mui/material/styles';
import { useSocket } from '../../../app/hooks/useSocket';
import { CommandEvent } from '@ce/web-shared';
import Intersection from '../model/Intersection';
import AppCaption from '../../../shared/components/AppCaption';

const Pre = styled('pre')({ fontSize: 14, whiteSpace: 'normal' });

function IntersectionCamsSection({ intersection: i }: { intersection: Intersection }) {
  const socket = useSocket();

  function changeCam(camName: string) {
    socket.emit(CommandEvent.ChangeCamToStatic, { staticCam: camName });
  }

  if (!i.staticCams || i.staticCams.length === 0) {
    return (
      <Alert severity="info" sx={{ m: 2, border: 1, borderColor: 'info.main', alignItems: 'top' }} icon={false}>
        <Typography variant="body2" sx={{ fontWeight: 'bolder' }} gutterBottom>
          Tipp: Kameras hinzufügen
        </Typography>
        <Typography variant="body2">
          So hast Du Deine Kreuzung angelegt:
          <Pre>c1 = Crossing:new(...)</Pre>
          Suche Dir nun eine statische Kamera aus und füge ihren Namen wie folgt hinzu:
          <Pre>c1:addStaticCam('Kameraname')</Pre>
        </Typography>
      </Alert>
    );
  }

  return (
    <Stack sx={{ px: 2, pt: 1, pb: 2 }}>
      <AppCaption>Kameras</AppCaption>
      <Stack direction="row" sx={{ pt: 1, flexWrap: 'wrap' }}>
        {i.staticCams.map((c, j) => (
          <Tooltip key={c} title={c}>
            <Chip
              sx={{ mr: 1, mb: 1, justifyContent: 'flex-start' }}
              color="secondary"
              icon={<CamIcon />}
              label={(i.staticCams.length === 1 && c) || j}
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
