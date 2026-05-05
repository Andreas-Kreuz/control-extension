import SpeedIcon from '@mui/icons-material/Speed';
import Box from '@mui/material/Box';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Slider from '@mui/material/Slider';
import { useEffect, useState } from 'react';

function SpeedControl(props: { value: number; onCommit: (value: number) => void }) {
  const [value, setValue] = useState(props.value);

  useEffect(() => {
    setValue(props.value);
  }, [props.value]);

  return (
    <>
      <ListItemIcon sx={{ mt: 0.5 }}>
        <SpeedIcon />
      </ListItemIcon>
      <Box sx={{ minWidth: 0, width: 1 }}>
        <ListItemText primary={`${value} km/h`} secondary="Zielgeschwindigkeit" />
        <Box sx={{ px: 1 }}>
          <Slider
            min={-250}
            max={250}
            step={1}
            value={value}
            valueLabelDisplay="auto"
            onChange={(_, nextValue) => setValue(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
            onChangeCommitted={(_, nextValue) => props.onCommit(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
          />
        </Box>
      </Box>
    </>
  );
}

export default SpeedControl;
