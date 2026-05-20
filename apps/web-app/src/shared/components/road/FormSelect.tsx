import FormControl from '@mui/material/FormControl';
import FormHelperText from '@mui/material/FormHelperText';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import type { SelectProps } from '@mui/material/Select';
import type { ReactNode } from 'react';

export interface FormSelectOption<TValue extends string> {
  label: ReactNode;
  value: TValue;
}

export interface FormSelectProps<TValue extends string> {
  errorTexts?: string[];
  id: string;
  infoText?: string;
  label: string;
  onChange: (value: TValue) => void;
  options: FormSelectOption<TValue>[];
  renderValue?: (value: TValue) => ReactNode;
  size?: SelectProps['size'];
  value: TValue;
}

function FormSelect<TValue extends string>({
  errorTexts = [],
  id,
  infoText,
  label,
  onChange,
  options,
  renderValue,
  size,
  value,
}: FormSelectProps<TValue>) {
  const labelId = `${id}-label`;
  const hasError = errorTexts.length > 0;
  const helperText = hasError ? <strong>{errorTexts.join(' ')}</strong> : infoText;
  return (
    <FormControl
      fullWidth
      error={hasError}
      size={size}
      sx={
        !hasError && infoText
          ? {
              '& .MuiFormHelperText-root': {
                visibility: 'hidden',
              },
              '&:hover .MuiFormHelperText-root, &:focus-within .MuiFormHelperText-root': {
                visibility: 'visible',
              },
            }
          : undefined
      }
    >
      <InputLabel id={labelId}>{label}</InputLabel>
      <Select
        labelId={labelId}
        label={label}
        value={value}
        renderValue={(selected) => renderValue?.(selected as TValue) ?? selected}
        onChange={(event) => onChange(event.target.value as TValue)}
      >
        {options.map((option) => (
          <MenuItem key={option.value} value={option.value}>
            {option.label}
          </MenuItem>
        ))}
      </Select>
      {helperText && <FormHelperText sx={{ ml: 1.75 }}>{helperText}</FormHelperText>}
    </FormControl>
  );
}

export default FormSelect;
