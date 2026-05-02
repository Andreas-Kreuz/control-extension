import Box from '@mui/material/Box';
import Slider from '@mui/material/Slider';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useEffect, useState } from 'react';

function AxisSlider(props: { name: string; value: number; trailingLabel: string; onCommit: (value: number) => void }) {
  const [value, setValue] = useState(props.value);

  useEffect(() => {
    setValue(props.value);
  }, [props.value]);

  return (
    <Box>
      <Stack direction="row" spacing={0.75} sx={{ alignItems: 'baseline', minWidth: 0 }}>
        <Typography variant="body2" sx={{ flex: 1, minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {props.name}
        </Typography>
        <Typography variant="caption" color="text.secondary" sx={{ flexShrink: 0, textAlign: 'right' }}>
          {props.trailingLabel}
        </Typography>
      </Stack>
      <Box sx={{ px: 1 }}>
        <Slider
          min={0}
          max={100}
          value={value}
          valueLabelDisplay="auto"
          onChange={(_, nextValue) => setValue(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
          onChangeCommitted={(_, nextValue) => props.onCommit(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
        />
      </Box>
    </Box>
  );
}

export default AxisSlider;
