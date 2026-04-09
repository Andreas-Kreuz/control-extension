import { lazy, useMemo } from 'react';
import useNavState from '../lib/NavElements';
import { useNavigate } from 'react-router-dom';
import BarChartIcon from '@mui/icons-material/BarChart';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import Grid from '@mui/material/Grid';
import Button from '@mui/material/Button';

const AppCardGrid = lazy(() => import('../../../shared/ui/AppCardGrid'));
const AppCardGridContainer = lazy(() => import('../../../shared/ui/AppCardGridContainer'));
const AppCardImg = lazy(() => import('../../../shared/ui/AppCardImg'));
const AppPage = lazy(() => import('../../../shared/ui/AppPage'));

function MainMenu() {
  const navigation = useNavState();
  const navigate = useNavigate();

  const trafficNav = useMemo(
    () => navigation.filter((nav) => nav.name === 'Verkehr').flatMap((nav) => nav.values),
    [navigation],
  );
  const dataNav = useMemo(
    () => navigation.filter((nav) => nav.name === 'Daten').flatMap((nav) => nav.values),
    [navigation],
  );

  return useMemo(
    () => (
      <AppPage>
        <AppCardGridContainer>
          {trafficNav.map((card) => (
            card.image && (
              <AppCardGrid key={card.title}>
                <AppCardImg
                  title={card.title}
                  image={'/assets/' + card.image}
                  to={card.link}
                  {...(card.subtitle !== undefined ? { subtitle: card.subtitle } : {})}
                />
              </AppCardGrid>
            )
          ))}
        </AppCardGridContainer>
        <Grid container style={{ alignItems: 'flex-start' }} justifyContent={'flex-start'} spacing={2} mt={2}>
          <Button variant="text" startIcon={<BarChartIcon />} onClick={() => navigate('statistics')}>
            Statistik
          </Button>
          <Button variant="text" startIcon={<Inventory2Icon />} href="/data">
            Daten
          </Button>
        </Grid>
      </AppPage>
    ),
    [trafficNav, dataNav],
  );
}

export default MainMenu;


