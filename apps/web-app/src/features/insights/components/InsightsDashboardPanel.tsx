import Box from '@mui/material/Box';
import { ReactNode } from 'react';

function InsightsDashboardPanel(props: { children: ReactNode }) {
  return (
    <Box
      sx={{
        height: 1,
        p: 0.5,
        width: 1,
      }}
    >
      {props.children}
    </Box>
  );
}

export default InsightsDashboardPanel;
