import BarChartIcon from '@mui/icons-material/BarChart';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import Button from '@mui/material/Button';
import Grid from '@mui/material/Grid';
import { lazy } from 'react';
import { useNavigate } from 'react-router-dom';
import getNavSections from '../lib/NavElements';

const AppCardGrid = lazy(() => import('../../../shared/layouts/AppCardGrid'));
const AppCardGridContainer = lazy(() => import('../../../shared/layouts/AppCardGridContainer'));
const AppCardImg = lazy(() => import('../../../shared/components/AppCardImg'));
const AppPage = lazy(() => import('../../../shared/layouts/AppPage'));

function MainMenu() {
  const navigation = getNavSections();
  const navigate = useNavigate();

  const trafficNav = navigation.filter((nav) => nav.name === 'Verkehr').flatMap((nav) => nav.values);

  return (
    <AppPage>
      <AppCardGridContainer>
        {trafficNav.map(
          (card) =>
            card.image && (
              <AppCardGrid key={card.title}>
                <AppCardImg
                  title={card.title}
                  image={'/assets/' + card.image}
                  to={card.link}
                  {...(card.subtitle !== undefined ? { subtitle: card.subtitle } : {})}
                />
              </AppCardGrid>
            ),
        )}
      </AppCardGridContainer>
      <Grid container spacing={2} sx={{ alignItems: 'flex-start', justifyContent: 'flex-start', mt: 2 }}>
        <Button variant="text" startIcon={<BarChartIcon />} onClick={() => navigate('statistics')}>
          Statistik
        </Button>
        <Button variant="text" startIcon={<Inventory2Icon />} href="/data">
          Daten
        </Button>
      </Grid>
    </AppPage>
  );
}

export default MainMenu;
