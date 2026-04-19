import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';

function StatisticsDiagramLegend(props: { ids: string[]; colorOf: (index: number) => string }) {
  return (
    <Stack
      sx={{
        flex: '0 0 auto',
        gap: 0.75,
        minWidth: 0,
        width: 1,
      }}
    >
      {props.ids.map((id, index) => (
        <Stack key={id} direction="row" sx={{ alignItems: 'center' }}>
          <Box
            sx={{
              bgcolor: props.colorOf(index),
              flex: '0 0 auto',
              height: 10,
              mr: 0.75,
              width: 10,
            }}
          />
          <Typography variant="caption">{id}</Typography>
        </Stack>
      ))}
    </Stack>
  );
}

export default StatisticsDiagramLegend;
