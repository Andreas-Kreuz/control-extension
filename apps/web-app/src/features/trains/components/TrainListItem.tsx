import { TrainListDto } from '@ce/web-shared';
import Avatar from '@mui/material/Avatar';
import ListItem from '@mui/material/ListItem';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import { trainIconFor } from '../lib/trainIconFor';

interface TrainListItemProps {
  train: TrainListDto;
  selected: boolean;
  onSelect: () => void;
}

const TrainListItem = ({ train, selected, onSelect }: TrainListItemProps) => {
  const iconSrc = '/assets/' + trainIconFor(train.trainType) + '.svg';
  return (
    <ListItem disablePadding>
      <ListItemButton selected={selected} onClick={onSelect}>
        <ListItemAvatar>
          <Avatar src={iconSrc} sx={{ bgcolor: 'background.paper' }} />
        </ListItemAvatar>
        <ListItemText primary={train.id} />
      </ListItemButton>
    </ListItem>
  );
};

export default TrainListItem;
