import DownloadRoundedIcon from '@mui/icons-material/DownloadRounded';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { SxProps, Theme } from '@mui/material/styles';
import type { ReactNode } from 'react';

export interface UpdateAvailableProps {
  iconOnly?: boolean;
  label?: ReactNode;
  sx?: SxProps<Theme>;
}

function UpdateAvailable(props: UpdateAvailableProps) {
  return (
    <Card
      variant="outlined"
      sx={{ bgcolor: 'background.paper', display: 'block', p: props.iconOnly ? 0.75 : 1.5, ...props.sx }}
    >
      <Stack direction="row" spacing={1} sx={{ alignItems: 'center' }}>
        <Box
          sx={{
            alignItems: 'center',
            bgcolor: 'secondary.main',
            borderRadius: '20%',
            color: 'primary.contrastText',
            display: 'flex',
            justifyContent: 'center',
            height: 24,
            width: 24,
          }}
        >
          <DownloadRoundedIcon sx={{ fontSize: 24 }} />
        </Box>
        {!props.iconOnly && (
          <Typography variant="subtitle1" sx={{ fontWeight: 600, lineHeight: 1.2, color: 'secondary.main' }}>
            {props.label ?? 'Update available'}
          </Typography>
        )}
      </Stack>
    </Card>
  );
}

export default UpdateAvailable;
