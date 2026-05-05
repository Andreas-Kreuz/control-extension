import VideocamIcon from '@mui/icons-material/Videocam';
import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import ControlTile from './ControlTile';

export type CameraControlSource = {
  key: number;
  label: string;
};

function CameraControl(props: { cameras: CameraControlSource[]; onCameraSelect: (key: number) => void }) {
  return (
    <ControlTile sx={{ gridColumn: '1 / -1' }}>
      <Box sx={{ minWidth: 0, width: 1 }}>
        <Typography variant="body2" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
          Kameras
        </Typography>
        <Stack direction="row" spacing={0.5} sx={{ mt: 1, overflowX: 'auto' }}>
          {props.cameras.map((camera) => (
            <Tooltip key={camera.key} title={camera.label}>
              <IconButton
                size="small"
                aria-label={`Kamera ${camera.label}`}
                onClick={() => props.onCameraSelect(camera.key)}
              >
                <VideocamIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          ))}
        </Stack>
      </Box>
    </ControlTile>
  );
}

export default CameraControl;
