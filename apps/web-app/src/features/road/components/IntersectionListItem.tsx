import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import Intersection from '../model/Intersection';

interface IntersectionListItemProps {
  intersection: Intersection;
  selected: boolean;
  onSelect: () => void;
}

const IntersectionListItem = ({ intersection, selected, onSelect }: IntersectionListItemProps) => {
  return (
    <ListItem disablePadding>
      <ListItemButton selected={selected} onClick={onSelect}>
        <ListItemText primary={`Kreuzung ${intersection.id}`} secondary={intersection.name} />
      </ListItemButton>
    </ListItem>
  );
};

export default IntersectionListItem;
