import BarChartIcon from '@mui/icons-material/BarChart';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import Button from '@mui/material/Button';
import Grid from '@mui/material/Grid';
import { useNavigate } from 'react-router-dom';
import AppCardImg from '../../../shared/components/AppCardImg';
import AppCardGrid from '../../../shared/layouts/AppCardGrid';
import AppCardGridContainer from '../../../shared/layouts/AppCardGridContainer';
import AppPage from '../../../shared/layouts/AppPage';
import getNavSections from '../lib/NavElements';

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
