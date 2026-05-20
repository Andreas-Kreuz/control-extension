import Box from '@mui/material/Box';
import Slider from '@mui/material/Slider';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useEffect, useState } from 'react';

export type CompactAxisListEntry = {
  axisNumber: number;
  name: string;
  value: number;
  trailingLabel?: string;
};

function CompactAxisList(props: {
  entries: CompactAxisListEntry[];
  emptyMessage: string;
  onCommit: (axisNumber: number, value: number) => void;
}) {
  if (props.entries.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        {props.emptyMessage}
      </Typography>
    );
  }

  return (
    <Stack spacing={0.5}>
      {props.entries.map((entry) => (
        <CompactAxisSlider
          key={entry.axisNumber}
          name={entry.name}
          value={entry.value}
          trailingLabel={entry.trailingLabel}
          onCommit={(value) => props.onCommit(entry.axisNumber, value)}
        />
      ))}
    </Stack>
  );
}

function CompactAxisSlider(props: {
  name: string;
  value: number;
  trailingLabel?: string;
  onCommit: (value: number) => void;
}) {
  const [value, setValue] = useState(props.value);

  useEffect(() => {
    setValue(props.value);
  }, [props.value]);

  return (
    <Box
      sx={{
        alignItems: 'center',
        columnGap: 1,
        display: 'grid',
        gridTemplateColumns: 'minmax(0, 1fr) minmax(0, 1fr)',
        minWidth: 0,
      }}
    >
      <Stack direction="row" spacing={0.5} sx={{ alignItems: 'baseline', minWidth: 0 }}>
        <Typography variant="body2" sx={{ flex: 1, minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {props.name}
        </Typography>
        {props.trailingLabel && (
          <Typography variant="caption" color="textSecondary" sx={{ flexShrink: 0 }}>
            {props.trailingLabel}
          </Typography>
        )}
      </Stack>
      <Slider
        min={0}
        max={100}
        size="small"
        value={value}
        valueLabelDisplay="auto"
        onChange={(_event, nextValue) => setValue(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
        onChangeCommitted={(_event, nextValue) => props.onCommit(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
      />
    </Box>
  );
}

export default CompactAxisList;
