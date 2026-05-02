import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { TransitStationAppDto } from '@ce/web-shared';

function TransitStationOverviewSection({ station }: { station: TransitStationAppDto }) {
  return (
    <Stack spacing={1} sx={{ p: 2 }}>
      <Typography variant="body2" color="textSecondary">
        Name
      </Typography>
      <Typography variant="h6">{station.name ?? station.id}</Typography>
    </Stack>
  );
}

export default TransitStationOverviewSection;
