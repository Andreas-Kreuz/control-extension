import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { ReactNode } from 'react';

export type StatusCardColor = 'success' | 'error' | 'warning' | 'info' | 'primary' | 'secondary';

export interface StatusCardProps {
  children?: ReactNode;
  title: ReactNode;
  subtitle: ReactNode;
  statusText: ReactNode;
  statusColor: StatusCardColor;
  icon: ReactNode;
}

function StatusCard(props: StatusCardProps) {
  return (
    <Card
      sx={{ borderRadius: 0, boxShadow: 0, border: 1, borderColor: '#dddddd', display: 'flex', height: 1, width: 1 }}
    >
      <Stack sx={{ m: 0, p: 0, width: 1, flexDirection: 'row', alignItems: 'stretch', justifyContent: 'start' }}>
        <Box
          sx={{
            alignItems: 'flex-start',
            backgroundColor: props.statusColor + '.main',
            color: '#ffffff',
            display: 'flex',
            p: 2,
            pt: 2.5,
          }}
        >
          {props.icon}
        </Box>
        <CardContent sx={{ display: 'flex', flexDirection: 'column', gap: 0.25, p: 2, width: '100%' }}>
          <Typography variant="h5" sx={{ lineHeight: 1 }}>
            {props.title}
          </Typography>
          <Typography variant="subtitle1" sx={{ color: props.statusColor + '.main', fontWeight: 'bold' }}>
            {props.statusText}
          </Typography>
          <Typography variant="caption" sx={{ display: 'block', lineHeight: 1 }}>
            {props.subtitle}
          </Typography>
          {props.children}
        </CardContent>
      </Stack>
    </Card>
  );
}

export default StatusCard;
