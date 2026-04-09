import { lazy } from 'react';
import ModuleSettingsButton from '../../../shared/ui/ModuleSettingsButton';
import useLines from '../hooks/useLines';
import useTransitSettings from '../hooks/useTransitSettings';
import Grid from '@mui/material/Grid';
const AppCardGridContainer = lazy(() => import('../../../shared/ui/AppCardGridContainer'));
const AppPage = lazy(() => import('../../../shared/ui/AppPage'));
const AppPageHeadline = lazy(() => import('../../../shared/ui/AppPageHeadline'));
const TransitLineCard = lazy(() => import('./TransitLineCard'));

function TransitOverview() {
  const lines = useLines();
  const settings = useTransitSettings();

  return (
    <AppPage>
      <AppPageHeadline
        {...(settings !== undefined ? { rightSettings: <ModuleSettingsButton settings={settings} /> } : {})}
      >
        ÖPNV
      </AppPageHeadline>
      <AppCardGridContainer>
        {lines.map((i) => (
          <Grid size={{ xs: 12 }} key={i.id}>
            <TransitLineCard line={i} />
          </Grid>
        ))}
      </AppCardGridContainer>
    </AppPage>
  );
}

export default TransitOverview;
