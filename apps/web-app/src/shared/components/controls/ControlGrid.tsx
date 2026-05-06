import Box from '@mui/material/Box';
import { ReactNode } from 'react';

function ControlGrid(props: { children: ReactNode }) {
  return <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(2, minmax(0, 1fr))', gap: 1 }}>{props.children}</Box>;
}

export default ControlGrid;
