import Avatar from '@mui/material/Avatar';
import ListItem from '@mui/material/ListItem';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import Typography from '@mui/material/Typography';
import { getColor, getIcon } from '../lib/Transit';
import Line from '../model/Line';

interface TransitLineListItemProps {
  line: Line;
  selected: boolean;
  onSelect: () => void;
}

const TransitLineListItem = ({ line, selected, onSelect }: TransitLineListItemProps) => {
  const destinations = line.lineSegments.flatMap((ls) => ls.destination).join(' - ');
  return (
    <ListItem disablePadding>
      <ListItemButton selected={selected} onClick={onSelect}>
        <ListItemAvatar>
          <Avatar sx={{ bgcolor: getColor(line.trafficType) }}>{getIcon(line.trafficType)}</Avatar>
        </ListItemAvatar>
        <ListItemText
          primary={
            <>
              <Typography component="span" fontWeight={600} sx={{ mr: 1 }}>
                {line.nr}
              </Typography>
              {destinations}
            </>
          }
        />
      </ListItemButton>
    </ListItem>
  );
};

export default TransitLineListItem;
