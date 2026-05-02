import BarChartIcon from '@mui/icons-material/BarChart';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import TrainIcon from '@mui/icons-material/Train';
import Button from '@mui/material/Button';
import Grid from '@mui/material/Grid';
import { Link as RouterLink } from 'react-router-dom';
import ImageCard from '../../../shared/components/cards/ImageCard';
import CardGridItem from '../../../shared/layouts/CardGridItem';
import CardGridContainer from '../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../shared/layouts/PageContainer';
import getNavSections from '../lib/NavElements';

function MainMenu() {
  const navigation = getNavSections();

  const trafficNav = navigation.filter((nav) => nav.name === 'Verkehr').flatMap((nav) => nav.values);

  return (
    <PageContainer>
      <CardGridContainer>
        {trafficNav.map(
          (card) =>
            card.image && (
              <CardGridItem key={card.title}>
                <ImageCard
                  title={card.title}
                  image={'/assets/' + card.image}
                  to={card.link}
                  {...(card.subtitle !== undefined ? { subtitle: card.subtitle } : {})}
                />
              </CardGridItem>
            ),
        )}
      </CardGridContainer>
      <Grid container spacing={2} sx={{ alignItems: 'flex-start', justifyContent: 'flex-start', mt: 2 }}>
        <Button variant="text" startIcon={<BarChartIcon />} component={RouterLink} to="/insights">
          Einblicke
        </Button>
        <Button variant="text" startIcon={<Inventory2Icon />} component={RouterLink} to="/data">
          Daten
        </Button>
        <Button variant="text" startIcon={<TrainIcon />} component={RouterLink} to="/selectedTrain">
          Aktiver Zug
        </Button>
      </Grid>
    </PageContainer>
  );
}

export default MainMenu;
