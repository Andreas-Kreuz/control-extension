import SquareFootIcon from '@mui/icons-material/SquareFoot';
import { ReactNode } from 'react';
import IconListEntry from './IconListEntry';

function LengthEntry(props: { value: ReactNode }) {
  return <IconListEntry icon={<SquareFootIcon />} title="Länge" value={props.value} />;
}

export default LengthEntry;
