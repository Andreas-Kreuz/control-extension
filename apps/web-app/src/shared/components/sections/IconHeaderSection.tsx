import type { ReactNode } from 'react';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import FullBleedDivider from './FullBleedDivider';

export interface IconHeaderSectionProps {
  children?: ReactNode;
  icon?: ReactNode;
  title: ReactNode;
}

function IconHeaderSection(props: IconHeaderSectionProps) {
  return (
    <Box>
      <Stack direction="row" spacing={1} sx={{ alignItems: 'center', px: 2, pt: 2, pb: 1 }}>
        {props.icon}
        <Typography variant="h6">{props.title}</Typography>
      </Stack>
      <FullBleedDivider />
      <Box sx={{ '--section-content-px': '16px', px: 2, py: 2 }}>{props.children}</Box>
    </Box>
  );
}

export default IconHeaderSection;
