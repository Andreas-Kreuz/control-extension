import Avatar from '@mui/material/Avatar';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { ReactNode } from 'react';

export interface TransitLineCardProps {
  children?: ReactNode;
  title: ReactNode;
  subtitle?: ReactNode;
  icon: ReactNode;
  badge?: ReactNode;
  selected?: boolean;
  iconColor?: string;
  onClick?: () => void;
}

function TransitLineCard(props: TransitLineCardProps) {
  const header = (
    <Stack direction="row" spacing={1} sx={{ alignItems: 'center', minWidth: 0, pt: 2, px: 2, pb: 2 }}>
      <Avatar sx={{ bgcolor: props.iconColor }}>{props.icon}</Avatar>
      {props.badge !== undefined && (
        <Typography variant="h5" align="center" sx={{ fontWeight: 500, px: 2, minWidth: '4rem' }}>
          {props.badge}
        </Typography>
      )}
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.25, minWidth: 0 }}>
        <Typography variant="h5" sx={{ lineHeight: 1, overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {props.title}
        </Typography>
        {props.subtitle !== undefined && (
          <Typography
            variant="subtitle1"
            sx={{
              color: 'text.secondary',
              display: 'block',
              lineHeight: 1,
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {props.subtitle}
          </Typography>
        )}
      </Box>
    </Stack>
  );

  return (
    <Card sx={{ ...(props.selected && { outline: '2px solid', outlineColor: 'primary.main' }) }}>
      {props.onClick !== undefined ? <CardActionArea onClick={props.onClick}>{header}</CardActionArea> : header}
      {props.children}
    </Card>
  );
}

export default TransitLineCard;
