import DirectionsTransitIcon from '@mui/icons-material/DirectionsTransit';
import Avatar from '@mui/material/Avatar';
import ListItem from '@mui/material/ListItem';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import Typography from '@mui/material/Typography';
import type { TransitStationAppDto } from '@ce/web-shared';

interface TransitStationItemProps {
  station: TransitStationAppDto;
  selected: boolean;
  onSelect: () => void;
}

function TransitStationItem({ station, selected, onSelect }: TransitStationItemProps) {
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
            <Typography component="span" variant="body2" color="textSecondary">
              {platformCount > 0 ? `${platformCount} Steige` : 'Keine Steige hinterlegt'}
            </Typography>
          }
        />
      </ListItemButton>
    </ListItem>
  );
}

export default TransitStationItem;
