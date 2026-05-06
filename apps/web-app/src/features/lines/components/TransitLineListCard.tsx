import type { ReactNode } from 'react';
import Line from '../model/Line';
import Card from '@mui/material/Card';
import { CardActionArea, Stack, Typography } from '@mui/material';
import LineAvatar from '../../../shared/components/lines/LineAvatar';

export interface TransitLineListCardProps {
  line: Line;
  selected: boolean;
  onSelect: () => void;
  children?: ReactNode;
}

const TransitLineListCard = ({ line, selected, onSelect, children }: TransitLineListCardProps) => {
  return (
    <Card sx={{ ...(selected && { outline: '2px solid', outlineColor: 'primary.main' }) }}>
      <CardActionArea onClick={onSelect}>
        <Stack direction={'row'} spacing={1} sx={{ pt: 2, px: 2, pb: 2 }}>
          <LineAvatar trafficType={line.trafficType} />
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

export default TransitLineListCard;
