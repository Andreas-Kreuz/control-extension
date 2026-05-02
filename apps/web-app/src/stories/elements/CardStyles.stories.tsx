import CheckCircleOutlineRoundedIcon from '@mui/icons-material/CheckCircleOutlineRounded';
import DashboardIcon from '@mui/icons-material/Dashboard';
import TramIcon from '@mui/icons-material/Tram';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import type { Meta, StoryObj } from '@storybook/react';
import { Fragment } from 'react';
import PlainCard from '../../shared/components/cards/PlainCard';
import BackgroundImageCard from '../../shared/components/cards/BackgroundImageCard';
import IconHeaderCard from '../../shared/components/cards/IconHeaderCard';
import ImageCard from '../../shared/components/cards/ImageCard';
import OutlinedCard from '../../shared/components/cards/OutlinedCard';
import StatusCard from '../../shared/components/cards/StatusCard';
import TransitLineCard from '../../shared/components/cards/TransitLineCard';

type PlainCardTypographyCombination = {
  titleVariant: 'h5' | 'h6';
  subtitleVariant: 'body1' | 'body2' | 'subtitle1' | 'subtitle2' | 'caption';
};

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
    return `${fontSize.toFixed(3)}px`;
  }

  return fontSize.replace(/^-?\d*\.?\d+/, (value) => Number(value).toFixed(3));
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

function CardStyles() {
  return (
    <Box sx={{ display: 'grid', gap: 2, gridTemplateColumns: { xs: '1fr', md: 'repeat(2, minmax(0, 1fr))' } }}>
      <PlainCard>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.25, p: 2 }}>
          <Typography variant="h6" sx={{ lineHeight: 1 }}>
            Plain card wrapper
          </Typography>
          <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block', lineHeight: 1 }}>
            Title and subtitle supplied by the caller
          </Typography>
        </Box>
      </PlainCard>
      <ImageCard title="Image card" subtitle="Image above or beside the header" image="/assets/card-img-traffic.jpg" />
      <BackgroundImageCard
        title="Background image card"
        subtitle="My super super super long title that should be truncated with an ellipsis at some point"
        image="/assets/card-img-traffic.jpg"
      />
      <IconHeaderCard
        title="Icon header card"
        subtitle="Dashboard card header"
        icon={<DashboardIcon color="primary" />}
        headerOnly
      />
      <OutlinedCard title="Outlined card" description="Title and description header">
        <Typography variant="body2" sx={{ color: 'text.secondary' }}>
          Content inside an outlined card
        </Typography>
      </OutlinedCard>
      <StatusCard
        title="Status strip card"
        statusText="OK"
        subtitle="Colored icon rail with status text"
        statusColor="success"
        icon={<CheckCircleOutlineRoundedIcon sx={{ fontSize: 24 }} />}
      />
      <TransitLineCard
        title="Destination A - Destination B"
        subtitle="Transit line row"
        badge="12"
        icon={<TramIcon />}
        iconColor="primary.main"
      />
    </Box>
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
  title: 'Elements/Cards/Card Styles',
  component: CardStyles,
} satisfies Meta<typeof CardStyles>;

export default meta;
type Story = StoryObj<typeof meta>;

export const AllStyles: Story = {};

export const PlainCardTypography: Story = {
  render: () => <PlainCardTypographyCombinations />,
};

export const AllStylesOnMobile: Story = {
  globals: {
    viewport: { value: 'mobile1', isRotated: false },
  },
  tags: ['mobile'],
};
