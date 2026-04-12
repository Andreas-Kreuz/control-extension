import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { TransitStationDto } from '@ce/web-shared';

function TransitStationOverviewSection({ station }: { station: TransitStationDto }) {
  return (
    <Stack spacing={1} sx={{ p: 2 }}>
      <Typography variant="body2" color="text.secondary">
        Name
      </Typography>
      <Typography variant="h6">{station.name ?? station.id}</Typography>
    </Stack>
  );
}

export default TransitStationOverviewSection;
