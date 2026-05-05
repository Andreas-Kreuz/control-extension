import { TrainListAppDto } from '@ce/web-shared';
import Box from '@mui/material/Box';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import { ListItemIcon } from '@mui/material';
import { ListIconSources } from '../lib/trainListIconSources';

interface TrainListItemProps {
  train: TrainListAppDto;
  selected: boolean;
  onSelect: () => void;
}

const TrainListItem = ({ train, selected, onSelect }: TrainListItemProps) => {
  const iconSrc = ListIconSources[train.trainType];
  return (
    <ListItem disablePadding>
      <ListItemButton selected={selected} onClick={onSelect}>
        <ListItemIcon
          sx={{
            width: 48,
            height: 32,
            minWidth: 48,
            mr: 1,
            p: '2px',
            border: 1,
            borderColor: 'grey.700',
            borderRadius: '4px',
            boxSizing: 'border-box',
          }}
        >
          <Box component="img" src={iconSrc} width="100%" height="100%" alt="" sx={{ objectFit: 'contain' }} />
        </ListItemIcon>
        <ListItemText primary={train.id} />
      </ListItemButton>
    </ListItem>
  );
};

export default TrainListItem;
