import Box from '@mui/material/Box';
import { SxProps, Theme } from '@mui/material/styles';
import { ReactNode } from 'react';

function ControlTile(props: { children: ReactNode; sx?: SxProps<Theme> }) {
  return (
    <Box
      sx={[
        {
          alignItems: 'center',
          display: 'flex',
          minHeight: 72,
          minWidth: 0,
          width: 1,
        },
        ...(Array.isArray(props.sx) ? props.sx : props.sx ? [props.sx] : []),
      ]}
    >
      {props.children}
    </Box>
  );
}

export default ControlTile;
