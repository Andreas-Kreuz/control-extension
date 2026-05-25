import type { MouseEvent } from 'react';
import { TrainListAppDto } from '@ce/web-shared';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import { ListItemIcon } from '@mui/material';
import { Link as RouterLink } from 'react-router-dom';
import { ListIconSources } from '../lib/trainListIconSources';

interface TrainListItemProps {
  train: TrainListAppDto;
  selected: boolean;
  onSelect: () => void;
  isActive?: boolean;
}

const TrainListItem = ({ train, selected, onSelect, isActive }: TrainListItemProps) => {
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
        {isActive && (
          <Chip
            label="Aktiv"
            size="small"
            color="primary"
            clickable
            component={RouterLink}
            to="/train/selected"
            onClick={(e: MouseEvent) => e.stopPropagation()}
            sx={{ flexShrink: 0 }}
          />
        )}
      </ListItemButton>
    </ListItem>
  );
};

export default TrainListItem;
