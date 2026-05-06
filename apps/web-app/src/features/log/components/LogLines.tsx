import { useLog } from '../providers/LogProvider';
import Box from '@mui/material/Box';
import type { SxProps, Theme } from '@mui/material/styles';
import { useEffect, useRef } from 'react';

interface LogLinesProps {
  height?: string;
  width?: string;
  sx?: SxProps<Theme>;
}

function LogLines({ height = '14.2em', width = 'calc(100vw)', sx }: LogLinesProps) {
  const logState = useLog();
  const lines = logState?.lines;
  const autoScroll = logState?.autoScroll;
  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  const scrollToBottom = () => {
    if (autoScroll) {
      messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  };

  useEffect(() => {
    scrollToBottom();
  }, [lines, autoScroll]);

  return (
    <Box
      height={height}
      width={width}
      sx={[
        {
          overflow: 'auto',
          pt: 1,
          px: 1,
        },
        ...(Array.isArray(sx) ? sx : [sx]),
      ]}
    >
      <Box component="ul" sx={{ m: 0, p: 0, marginBlock: 0, paddingInlineStart: 0 }}>
        {lines?.map((l) => (
          <Box
            component="li"
            key={l.key}
            sx={{ fontFamily: 'monospace', fontSize: 14, listStyleType: 'none', whiteSpace: 'pre' }}
          >
            {l.line}
          </Box>
        ))}
      </Box>
      <div ref={messagesEndRef} />
    </Box>
  );
}

export default LogLines;
