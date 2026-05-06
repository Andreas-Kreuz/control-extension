import type { ReactNode } from 'react';
import Box from '@mui/material/Box';

function DetailTabPanelBody(props: { children?: ReactNode }) {
  return <Box sx={{ '--section-content-px': '16px', px: 2, py: 2 }}>{props.children}</Box>;
}

export default DetailTabPanelBody;
