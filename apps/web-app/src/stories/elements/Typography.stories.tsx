import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import type { Meta, StoryObj } from '@storybook/react';
import { Fragment } from 'react';
import PlainCard from '../../shared/components/cards/PlainCard';

type PlainCardTypographyCombination = {
  titleVariant: 'h5' | 'h6';
  subtitleVariant: 'body1' | 'body2' | 'subtitle1' | 'subtitle2' | 'caption';
};

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

const h5PlainCardTypographyCombinations: PlainCardTypographyCombination[] = [
  { titleVariant: 'h5', subtitleVariant: 'body1' },
  { titleVariant: 'h5', subtitleVariant: 'body2' },
  { titleVariant: 'h5', subtitleVariant: 'subtitle1' },
  { titleVariant: 'h5', subtitleVariant: 'subtitle2' },
  { titleVariant: 'h5', subtitleVariant: 'caption' },
];

const h6PlainCardTypographyCombinations: PlainCardTypographyCombination[] = [
  { titleVariant: 'h6', subtitleVariant: 'body1' },
  { titleVariant: 'h6', subtitleVariant: 'body2' },
  { titleVariant: 'h6', subtitleVariant: 'subtitle1' },
  { titleVariant: 'h6', subtitleVariant: 'subtitle2' },
  { titleVariant: 'h6', subtitleVariant: 'caption' },
];

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

function PlainCardTypographyExample(props: PlainCardTypographyCombination) {
  const theme = useTheme();
  const titleStyle = theme.typography[props.titleVariant];
  const subtitleStyle = theme.typography[props.subtitleVariant];
  const titleInfo = `${props.titleVariant} (${titleStyle.fontWeight}, ${formatFontSize(titleStyle.fontSize)})`;
  const subtitleInfo = `${props.subtitleVariant} (${subtitleStyle.fontWeight}, ${formatFontSize(subtitleStyle.fontSize)})`;

  return (
    <PlainCard>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 4, p: 2 }}>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: '0.25rem' }}>
          <Typography variant={props.titleVariant} sx={{ lineHeight: 1, m: 0 }}>
            Informationen
          </Typography>
          <Typography variant={props.subtitleVariant} sx={{ color: 'text.secondary', lineHeight: 1, m: 0 }}>
            Datenbestand und Laufzeit
          </Typography>
        </Box>
        <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block' }}>
          {titleInfo} / {subtitleInfo}
        </Typography>
      </Box>
    </PlainCard>
  );
}

function PlainCardTypographyCombinations() {
  const rows = h5PlainCardTypographyCombinations.map((h5Combination, index) => [
    h5Combination,
    h6PlainCardTypographyCombinations[index],
  ]);

  return (
    <Box sx={{ alignItems: 'stretch', display: 'grid', gap: 2, gridTemplateColumns: 'repeat(2, minmax(0, 1fr))' }}>
      {rows.map(([h5Combination, h6Combination], index) => (
        <Fragment key={index}>
          <PlainCardTypographyExample
            key={`${h5Combination.titleVariant}-${h5Combination.subtitleVariant}-${index}`}
            {...h5Combination}
          />
          <PlainCardTypographyExample
            key={`${h6Combination.titleVariant}-${h6Combination.subtitleVariant}-${index}`}
            {...h6Combination}
          />
        </Fragment>
      ))}
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

export const PlainCardTypography: Story = {
  render: () => <PlainCardTypographyCombinations />,
};
