import Stack from '@mui/material/Stack';
import type { AlertColor } from '@mui/material/Alert';
import type { SxProps, Theme } from '@mui/material/styles';
import type { ReactNode } from 'react';
import FeedbackMessage from './FeedbackMessage';

export interface FeedbackMessagesProps {
  messages: ReactNode[];
  severity?: AlertColor;
  sx?: SxProps<Theme>;
}

function FeedbackMessages({ messages, severity = 'info', sx }: FeedbackMessagesProps) {
  if (messages.length === 0) return null;

  return (
    <Stack spacing={1} sx={sx}>
      {messages.map((message, index) => (
        <FeedbackMessage key={typeof message === 'string' ? message : index} severity={severity}>
          {message}
        </FeedbackMessage>
      ))}
    </Stack>
  );
}

export default FeedbackMessages;
