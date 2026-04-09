import { TrainListDto } from '@ce/web-shared';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import { trainIconFor } from '../lib/trainIconFor';
import { ListItemIcon } from '@mui/material';

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
        <ListItemIcon sx={{ pr: 1 }}>
          <img src={iconSrc} height="32" />
        </ListItemIcon>
        <ListItemText primary={train.id} />
      </ListItemButton>
    </ListItem>
  );
};

export default TrainListItem;
