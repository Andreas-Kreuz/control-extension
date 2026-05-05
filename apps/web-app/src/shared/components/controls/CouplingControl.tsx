import Box from '@mui/material/Box';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import ControlTile from './ControlTile';

function CouplingControl(props: {
  value: number;
  disabled?: boolean;
  label: string;
  onChange: (checked: boolean) => void;
}) {
  return (
    <ControlTile>
      <Box sx={{ minWidth: 0, width: 1 }}>
        <Typography variant="body2" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {props.label}
        </Typography>
        <ToggleButtonGroup
          disabled={props.disabled}
          exclusive
          fullWidth
          size="small"
          value={props.value === 1 ? 'on' : 'off'}
          onChange={(_event, value: 'off' | 'on' | null) => {
            if (value !== null) {
              props.onChange(value === 'on');
            }
          }}
          sx={{ mt: 1 }}
        >
          <ToggleButton value="off">Aus</ToggleButton>
          <ToggleButton value="on">Ein</ToggleButton>
        </ToggleButtonGroup>
      </Box>
    </ControlTile>
  );
}

export default CouplingControl;
