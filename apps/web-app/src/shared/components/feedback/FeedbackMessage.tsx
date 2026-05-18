import Alert from '@mui/material/Alert';
import type { AlertColor } from '@mui/material/Alert';
import type { SxProps, Theme } from '@mui/material/styles';
import type { ReactNode } from 'react';

export interface FeedbackMessageProps {
  children: ReactNode;
  severity?: AlertColor;
  sx?: SxProps<Theme>;
}

function FeedbackMessage({ children, severity = 'info', sx }: FeedbackMessageProps) {
  return (
    <Alert severity={severity} sx={sx}>
      {children}
    </Alert>
  );
}

export default FeedbackMessage;
