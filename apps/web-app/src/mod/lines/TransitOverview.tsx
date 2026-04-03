import { lazy } from 'react';
import ModuleSettingsButton from '../../components/ModuleSettingsButton';
import useLines from './useLines';
import useTransitSettings from './useTransitSettings';
import Grid from '@mui/material/Grid';
const AppCardGridContainer = lazy(() => import('../../components/AppCardGridContainer'));
const AppPage = lazy(() => import('../../components/AppPage'));
const AppPageHeadline = lazy(() => import('../../components/AppPageHeadline'));
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
