import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardHeader from '@mui/material/CardHeader';
import type { SxProps, Theme } from '@mui/material/styles';
import type { ReactNode } from 'react';

export interface OutlinedCardProps {
  children?: ReactNode;
  title?: ReactNode;
  description?: ReactNode;
  sx?: SxProps<Theme>;
}

function OutlinedCard(props: OutlinedCardProps) {
  const hasHeader = props.title !== undefined || props.description !== undefined;

  return (
    <Card variant="outlined" sx={{ bgcolor: 'transparent', height: 1, minWidth: 0, width: 1, ...props.sx }}>
      {hasHeader && (
        <CardHeader
          title={props.title}
          subheader={props.description}
          slotProps={{
            content: { sx: { display: 'flex', flexDirection: 'column', gap: '0.25rem' } },
            title: { variant: 'h5', sx: { lineHeight: 1, m: 0 } },
            subheader: { variant: 'subtitle1', sx: { color: 'text.secondary', lineHeight: 1, m: 0 } },
          }}
        />
      )}
      {props.children !== undefined && (
        <CardContent sx={{ pt: hasHeader ? 0 : 2, '&:last-child': { pb: 1.5 } }}>{props.children}</CardContent>
      )}
    </Card>
  );
}

export default OutlinedCard;
