import { useLog } from '../providers/LogProvider';
import Box from '@mui/material/Box';
import { styled, type SxProps, type Theme } from '@mui/material/styles';
import { useEffect, useRef } from 'react';

const LogLineList = styled('ul')({
  m: 0,
  p: 0,
  marginBlock: 0,
  paddingInlineStart: 0,
});

const LogLineEntry = styled('li')({
  fontSize: 14,
  fontFamily: 'monospace',
  listStyleType: 'none',
  whiteSpace: 'pre',
});

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
      <LogLineList>
        {lines?.map((l) => (
          <LogLineEntry key={l.key}>{l.line}</LogLineEntry>
        ))}
      </LogLineList>
      <div ref={messagesEndRef} />
    </Box>
  );
}

export default LogLines;
