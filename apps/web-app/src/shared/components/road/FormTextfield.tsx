import TextField from '@mui/material/TextField';
import type { TextFieldProps } from '@mui/material/TextField';

export type FormTextfieldProps = Omit<TextFieldProps, 'error' | 'helperText' | 'variant'> & {
  errorTexts?: string[];
  infoText?: string;
};

const hiddenInfoTextSx = {
  '& .MuiFormHelperText-root': {
    visibility: 'hidden',
  },
  '&:hover .MuiFormHelperText-root, &:focus-within .MuiFormHelperText-root': {
    visibility: 'visible',
  },
};

function FormTextfield({ errorTexts = [], infoText, sx, ...props }: FormTextfieldProps) {
  const hasError = errorTexts.length > 0;
  const helperText = hasError ? errorTexts.join(' ') : infoText;
  return (
    <TextField
      {...props}
      error={hasError}
      helperText={helperText}
      variant="outlined"
      fullWidth
      sx={[!hasError && infoText ? hiddenInfoTextSx : {}, ...(Array.isArray(sx) ? sx : [sx])]}
    />
  );
}

export default FormTextfield;
