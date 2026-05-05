import AssignmentIcon from '@mui/icons-material/Assignment';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function TagEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<AssignmentIcon />} title="Tag-Text" value={props.value} />;
}

export default TagEntry;
