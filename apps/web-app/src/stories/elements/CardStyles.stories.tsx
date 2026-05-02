import CheckCircleOutlineRoundedIcon from '@mui/icons-material/CheckCircleOutlineRounded';
import DashboardIcon from '@mui/icons-material/Dashboard';
import TramIcon from '@mui/icons-material/Tram';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import PlainCard from '../../shared/components/cards/PlainCard';
import BackgroundImageCard from '../../shared/components/cards/BackgroundImageCard';
import IconHeaderCard from '../../shared/components/cards/IconHeaderCard';
import ImageCard from '../../shared/components/cards/ImageCard';
import OutlinedCard from '../../shared/components/cards/OutlinedCard';
import StatusCard from '../../shared/components/cards/StatusCard';
import TransitLineCard from '../../shared/components/cards/TransitLineCard';

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

const meta = {
  title: 'Elements/Cards/Card Styles',
  component: CardStyles,
} satisfies Meta<typeof CardStyles>;

export default meta;
type Story = StoryObj<typeof meta>;

export const AllStyles: Story = {};

export const AllStylesOnMobile: Story = {
  globals: {
    viewport: { value: 'mobile1', isRotated: false },
  },
  tags: ['mobile'],
};
