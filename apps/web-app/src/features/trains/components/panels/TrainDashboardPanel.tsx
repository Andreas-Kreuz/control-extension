import { TrainAppDto } from '@ce/web-shared';
import CommuteIcon from '@mui/icons-material/Commute';
import DashboardIcon from '@mui/icons-material/Dashboard';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Grid from '@mui/material/Grid';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { ReactNode } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import IconHeaderCard from '../../../../shared/components/cards/IconHeaderCard';
import CardGridContainer from '../../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../../shared/layouts/PageContainer';
import PageHeadline from '../../../../shared/layouts/PageHeadline';
import { TrainDashboardPanelModel } from '../../lib/trainDashboardPanelModel';
import { trainSections } from '../trainSectionPresentation';
import MergedAxisPanel from './MergedAxisPanel';
import TrainControlsPanel from './TrainControlsPanel';
import TrainInfoPanel from './TrainInfoPanel';

const fuhrparkButton = (
  <Button variant="contained" startIcon={<CommuteIcon />} component={RouterLink} to="/train/list">
    Fuhrpark
  </Button>
);

function TrainDashboardPanel(props: { dashboard: TrainDashboardPanelModel; rollingStockContent?: ReactNode }) {
  const { dashboard } = props;

  if (dashboard.status === 'empty') {
    return (
      <PageContainer>
        <PageHeadline icon={<DashboardIcon color="primary" />}>Aktiver Zug</PageHeadline>
        <IconHeaderCard title="Kein Zug in EEP ausgewählt" icon={<DashboardIcon color="primary" />}>
          <Typography variant="body2" color="textSecondary">
            Wähle in EEP einen RollingStock oder Zug aus, dann folgt dieses Dashboard automatisch.
          </Typography>
        </IconHeaderCard>
      </PageContainer>
    );
  }

  if (dashboard.status === 'loading') {
    return (
      <PageContainer>
        <PageHeadline icon={<DashboardIcon color="primary" />}>Aktiver Zug</PageHeadline>
        <IconHeaderCard title="Zugdaten" icon={<DashboardIcon color="primary" />}>
          <Typography variant="body2" color="textSecondary">
            Zugdaten werden geladen.
          </Typography>
        </IconHeaderCard>
      </PageContainer>
    );
  }

  return (
    <PageContainer>
      <PageHeadline icon={<DashboardIcon color="primary" />} rightSettings={fuhrparkButton}>
        Aktiver Zug
      </PageHeadline>
      <Stack spacing={2}>
        <CardGridContainer>
          <Grid size={{ xs: 12 }}>
            <TrainHeadline selected={dashboard.trainSelected} train={dashboard.train} />
          </Grid>
          <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
            <IconHeaderCard title={trainSections.trainInfo.title} icon={trainSections.trainInfo.icon}>
              <TrainInfoPanel
                licencePlates={dashboard.licencePlates}
                train={dashboard.train}
                {...(dashboard.transit !== undefined ? { transit: dashboard.transit } : {})}
                vehicleNumbers={dashboard.vehicleNumbers}
                onSpeedCommit={dashboard.onSpeedCommit}
              />
            </IconHeaderCard>
          </Grid>
          <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
            <IconHeaderCard title={trainSections.trainControls.title} icon={trainSections.trainControls.icon}>
              <TrainControlsPanel
                cameraSources={dashboard.cameraSources}
                couplingFront={dashboard.controls.couplingFront}
                couplingRear={dashboard.controls.couplingRear}
                lights={dashboard.controls.lights}
                onCameraSelect={dashboard.onCameraSelect}
                onCouplingChange={dashboard.controls.onCouplingChange}
                onLightChange={dashboard.controls.onLightChange}
              />
            </IconHeaderCard>
          </Grid>
          <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
            <IconHeaderCard title={trainSections.trainAxes.title} icon={trainSections.trainAxes.icon}>
              <MergedAxisPanel
                canShowTrainAxes={dashboard.canShowTrainAxes}
                groups={dashboard.mergedAxisGroups}
                rollingStockCount={dashboard.rollingStock.length}
                onCommit={dashboard.onMergedAxisCommit}
              />
            </IconHeaderCard>
          </Grid>
          {props.rollingStockContent}
        </CardGridContainer>
      </Stack>
    </PageContainer>
  );
}

function TrainHeadline(props: { selected: boolean; train: TrainAppDto }) {
  return (
    <Stack direction="row" spacing={1} sx={{ alignItems: 'center', minWidth: 0, mt: 1 }}>
      <Typography variant="h6" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
        Zug
        <Box component="span" sx={{ display: { xs: 'none', sm: 'inline' } }}>
          : {props.train.name || '-'}
        </Box>
      </Typography>
      {props.selected && <Chip size="small" color="primary" label="Ausgewählt" />}
    </Stack>
  );
}

export default TrainDashboardPanel;
