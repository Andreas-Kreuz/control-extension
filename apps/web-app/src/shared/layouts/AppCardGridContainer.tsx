import Grid from '@mui/material/Grid';
import { SxProps, Theme } from '@mui/material/styles';
import { Key, ReactNode } from 'react';

function AppCardGridContainer(props: { key?: Key; children: ReactNode; sx?: SxProps<Theme> }) {
  return (
    <Grid container spacing={{ xs: 2, md: 3 }} sx={props.sx}>
      {props.children}
    </Grid>
  );
}

export default AppCardGridContainer;
