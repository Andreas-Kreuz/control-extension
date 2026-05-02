import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { ReactNode } from 'react';
import AxisSlider from './AxisSlider';

export type AxisListEntry = {
  axisNumber: number;
  name: string;
  value: number;
  trailingLabel?: string;
};

function AxisList(props: {
  entries: AxisListEntry[];
  emptyContent?: ReactNode;
  onCommit: (axisNumber: number, value: number) => void;
}) {
  if (props.entries.length === 0) {
    return (
      props.emptyContent ?? (
        <Typography variant="body2" color="textSecondary">
          Keine Achsen.
        </Typography>
      )
    );
  }

  return (
    <Stack spacing={1}>
      {props.entries.map((entry) => (
        <AxisSlider
          key={entry.axisNumber}
          name={entry.name}
          value={entry.value}
          trailingLabel={entry.trailingLabel ?? `(#${entry.axisNumber})`}
          onCommit={(value) => props.onCommit(entry.axisNumber, value)}
        />
      ))}
    </Stack>
  );
}

export default AxisList;
