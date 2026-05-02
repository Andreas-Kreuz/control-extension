import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import type { Meta, StoryObj } from '@storybook/react';
import { Fragment } from 'react';

const typographySamples = [
  { variant: 'h1', text: 'h1. Heading' },
  { variant: 'h2', text: 'h2. Heading' },
  { variant: 'h3', text: 'h3. Heading' },
  { variant: 'h4', text: 'h4. Heading' },
  { variant: 'h5', text: 'h5. Heading' },
  { variant: 'h6', text: 'h6. Heading' },
  {
    variant: 'subtitle1',
    text: 'subtitle1. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos blanditiis tenetur',
  },
  {
    variant: 'subtitle2',
    text: 'subtitle2. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos blanditiis tenetur',
  },
  {
    variant: 'body1',
    text: 'body1. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos blanditiis tenetur unde suscipit, quam beatae rerum inventore consectetur, neque doloribus, cupiditate numquam dignissimos laborum fugiat deleniti? Eum quasi quidem quibusdam.',
  },
  {
    variant: 'body2',
    text: 'body2. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos blanditiis tenetur unde suscipit, quam beatae rerum inventore consectetur, neque doloribus, cupiditate numquam dignissimos laborum fugiat deleniti? Eum quasi quidem quibusdam.',
  },
  { variant: 'button', text: 'button text' },
  { variant: 'caption', text: 'caption text' },
  { variant: 'overline', text: 'overline text' },
] as const;

function formatFontSize(fontSize: string | number) {
  if (typeof fontSize === 'number') {
    return fontSize.toFixed(3);
  }

  return fontSize.replace(/^-?\d*\.?\d+/, (value) => Number(value).toFixed(3));
}

function TypographyScale() {
  const theme = useTheme();

  return (
    <Box
      sx={{
        '--column-gap': '16px',
        '--info-column-width': '8rem',
        columnGap: 'var(--column-gap)',
        display: 'grid',
        gridTemplateColumns: 'var(--info-column-width) minmax(0, 1fr)',
        maxWidth: 900,
        position: 'relative',
        width: '100%',
        '&::before': {
          bgcolor: 'common.white',
          bottom: 0,
          content: '""',
          left: 'calc(var(--info-column-width) + var(--column-gap))',
          position: 'absolute',
          right: 0,
          top: 0,
        },
      }}
    >
      {typographySamples.map((sample) => {
        const typographyStyle = theme.typography[sample.variant];

        return (
          <Fragment key={sample.variant}>
            <Typography
              variant="caption"
              sx={{
                alignSelf: 'baseline',
                color: 'text.secondary',
                fontFamily: 'monospace',
                justifySelf: 'end',
                whiteSpace: 'nowrap',
                zIndex: 1,
              }}
            >
              {formatFontSize(typographyStyle.fontSize)} / {typographyStyle.fontWeight}
            </Typography>
            <Typography
              variant={sample.variant}
              gutterBottom
              sx={{
                display:
                  sample.variant === 'button' || sample.variant === 'caption' || sample.variant === 'overline'
                    ? 'block'
                    : undefined,
                px: '3rem',
                zIndex: 1,
              }}
            >
              {sample.text}
            </Typography>
          </Fragment>
        );
      })}
    </Box>
  );
}

const meta = {
  title: 'Elements/Typography',
  component: TypographyScale,
} satisfies Meta<typeof TypographyScale>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};
