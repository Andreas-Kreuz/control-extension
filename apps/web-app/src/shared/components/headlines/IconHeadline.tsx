import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { TypographyProps } from '@mui/material/Typography';
import type { ReactNode } from 'react';

function IconHeadline(props: {
  color?: TypographyProps['color'];
  gutterBottom?: boolean;
  icon?: ReactNode;
  text: ReactNode;
  variant?: TypographyProps['variant'];
}) {
  return (
    <Stack direction="row" spacing={1.25} sx={{ alignItems: 'center', minWidth: 0 }}>
      {props.icon}
      <Typography
        variant={props.variant ?? 'h5'}
        color={props.color}
        gutterBottom={props.gutterBottom}
        sx={{ lineHeight: 1, minWidth: 0, textOverflow: 'ellipsis' }}
      >
        {props.text}
      </Typography>
    </Stack>
  );
}

export default IconHeadline;
