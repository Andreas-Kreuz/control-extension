import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import type { SxProps, Theme } from '@mui/material/styles';
import type { ReactNode } from 'react';

export interface BorderedSimpleCardProps {
  children?: ReactNode;
  contentSx?: SxProps<Theme>;
  sx?: SxProps<Theme>;
}

function BorderedSimpleCard(props: BorderedSimpleCardProps) {
  const contentSx = Array.isArray(props.contentSx) ? props.contentSx : [props.contentSx];

  return (
    <Card variant="outlined" sx={{ bgcolor: 'background.paper', height: 1, minWidth: 0, width: 1, ...props.sx }}>
      <CardContent sx={[{ '&:last-child': { pb: 2 } }, ...contentSx]}>{props.children}</CardContent>
    </Card>
  );
}

export default BorderedSimpleCard;
