import IconButton from '@mui/material/IconButton';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { TypographyProps } from '@mui/material/Typography';
import DeleteIcon from '@mui/icons-material/Delete';
import type { ReactNode } from 'react';

function IconHeadlineDelete(props: {
  ariaLabel: string;
  color?: TypographyProps['color'];
  gutterBottom?: boolean;
  icon?: ReactNode;
  onDelete: () => void;
  subText?: ReactNode;
  text: ReactNode;
  variant?: TypographyProps['variant'];
}) {
  return (
    <Stack direction="row" spacing={1} sx={{ alignItems: 'center', minWidth: 0 }}>
      <Stack direction="row" spacing={1.25} sx={{ alignItems: 'center', flex: 1, minWidth: 0 }}>
        {props.icon}
        <Stack spacing={0.5} sx={{ minWidth: 0 }}>
          <Typography
            variant={props.variant ?? 'h5'}
            color={props.color}
            gutterBottom={props.gutterBottom}
            sx={{ lineHeight: 1, minWidth: 0, textOverflow: 'ellipsis' }}
          >
            {props.text}
          </Typography>
          {props.subText && (
            <Typography variant="caption" color="text.secondary" sx={{ lineHeight: 1.2 }}>
              {props.subText}
            </Typography>
          )}
        </Stack>
      </Stack>
      <IconButton aria-label={props.ariaLabel} onClick={props.onDelete} sx={{ pt: -1 }}>
        <DeleteIcon />
      </IconButton>
    </Stack>
  );
}

export default IconHeadlineDelete;
