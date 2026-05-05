import CommitIcon from '@mui/icons-material/Commit';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function TrainPositionEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<CommitIcon />} title="Position im Zug" value={props.value} />;
}

export default TrainPositionEntry;
