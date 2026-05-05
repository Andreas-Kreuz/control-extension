import Divider from '@mui/material/Divider';

function FullBleedDivider() {
  return <Divider sx={{ mx: 'calc(var(--section-content-px, 0px) * -1)' }} />;
}

export default FullBleedDivider;
