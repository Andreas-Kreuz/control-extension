import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { ReactNode } from 'react';

function PageHeadline(props: {
  children: ReactNode;
  gutterTop?: boolean;
  icon?: ReactNode;
  rightSettings?: ReactNode;
}) {
  return (
    <Stack direction="row" sx={{ display: 'flex', alignContent: 'center', justifyContent: 'space-between' }}>
      <Stack direction="row" spacing={1.25} sx={{ alignItems: 'center', minWidth: 0, pt: props.gutterTop ? 5 : 0 }}>
        {props.icon}
        <Typography variant="h4" gutterBottom color="textSecondary" sx={{ minWidth: 0 }}>
          {props.children}
        </Typography>
      </Stack>
      {props.rightSettings}
    </Stack>
  );
}

export default PageHeadline;
