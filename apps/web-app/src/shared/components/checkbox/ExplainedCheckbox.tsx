import Checkbox from '@mui/material/Checkbox';
import FormControlLabel from '@mui/material/FormControlLabel';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { SxProps, Theme } from '@mui/material/styles';
import type { ChangeEvent, ReactNode } from 'react';

export interface ExplainedCheckboxProps {
  checked: boolean;
  label: ReactNode;
  explanation?: ReactNode;
  disabled?: boolean;
  onChange: (event: ChangeEvent<HTMLInputElement>, checked: boolean) => void;
  sx?: SxProps<Theme>;
}

function ExplainedCheckbox({ checked, disabled, explanation, label, onChange, sx }: ExplainedCheckboxProps) {
  return (
    <Stack spacing={0} sx={sx}>
      <FormControlLabel
        control={<Checkbox checked={checked} disabled={disabled} onChange={onChange} />}
        disabled={disabled}
        label={label}
      />
      {explanation && (
        <Typography variant="caption" sx={{ pl: 4, mt: -0.5, color: 'text.secondary' }}>
          {explanation}
        </Typography>
      )}
    </Stack>
  );
}

export default ExplainedCheckbox;
