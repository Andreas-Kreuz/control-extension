import DirectionsTransitIcon from '@mui/icons-material/DirectionsTransit';
import Avatar from '@mui/material/Avatar';
import ListItem from '@mui/material/ListItem';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import Typography from '@mui/material/Typography';
import type { TransitStationDto } from '@ce/web-shared';

interface TransitStationListItemProps {
  station: TransitStationDto;
  selected: boolean;
  onSelect: () => void;
}

function TransitStationListItem({ station, selected, onSelect }: TransitStationListItemProps) {
  const primaryText = station.name ?? station.id;
  const platformCount = station.platforms?.length ?? 0;

  return (
    <ListItem disablePadding>
      <ListItemButton selected={selected} onClick={onSelect}>
        <ListItemAvatar>
          <Avatar>
            <DirectionsTransitIcon />
          </Avatar>
        </ListItemAvatar>
        <ListItemText
          primary={primaryText}
          secondary={
            <Typography component="span" variant="body2" color="text.secondary">
              {platformCount > 0 ? `${platformCount} Steige` : 'Keine Steige hinterlegt'}
            </Typography>
          }
        />
      </ListItemButton>
    </ListItem>
  );
}

export default TransitStationListItem;
