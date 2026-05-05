import BadgeIcon from '@mui/icons-material/Badge';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function NameEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<BadgeIcon />} title="Name" value={props.value} />;
}

export default NameEntry;
