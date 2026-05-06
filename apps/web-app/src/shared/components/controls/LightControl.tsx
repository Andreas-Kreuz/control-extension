import Box from '@mui/material/Box';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import ControlTile from './ControlTile';

function LightControl(props: { checked: boolean; label: string; enabledLabel?: string; onChange: (checked: boolean) => void }) {
  return (
    <ControlTile>
      <Box sx={{ minWidth: 0, width: 1 }}>
        <Typography variant="body2" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {props.label}
        </Typography>
        <ToggleButtonGroup
          exclusive
          fullWidth
          size="small"
          value={props.checked ? 'on' : 'off'}
          onChange={(_event, value: 'off' | 'on' | null) => {
            if (value !== null) {
              props.onChange(value === 'on');
            }
          }}
          sx={{ mt: 1 }}
        >
          <ToggleButton value="off">Aus</ToggleButton>
          <ToggleButton value="on">{props.enabledLabel ?? 'Ein'}</ToggleButton>
        </ToggleButtonGroup>
      </Box>
    </ControlTile>
  );
}

export default LightControl;
