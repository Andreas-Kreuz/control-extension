import type { ReactNode } from 'react';
import Line from '../model/Line';
import Card from '@mui/material/Card';
import { CardActionArea, Stack, Avatar, Typography } from '@mui/material';
import { getColor, getIcon } from '../lib/Transit';

export interface TransitLineCardProps {
  line: Line;
  selected: boolean;
  onSelect: () => void;
  children?: ReactNode;
}

const TransitLineCard = ({ line, selected, onSelect, children }: TransitLineCardProps) => {
  return (
    <Card sx={{ ...(selected && { outline: '2px solid', outlineColor: 'primary.main' }) }}>
      <CardActionArea onClick={onSelect}>
        <Stack direction={'row'} spacing={1} sx={{ pt: 2, px: 2, pb: 2 }}>
          <Avatar sx={{ bgcolor: getColor(line.trafficType) }}>{getIcon(line.trafficType)}</Avatar>
          <Typography variant="h5" align="center" sx={{ fontWeight: 500, px: 2, minWidth: '4rem' }}>
            {line.nr}
          </Typography>
          <Typography variant="h5">{line.lineSegments.flatMap((el) => el.destination).join(' - ')}</Typography>
        </Stack>
      </CardActionArea>
      {children}
    </Card>
  );
};

export default TransitLineCard;
