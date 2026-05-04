import BarChartIcon from '@mui/icons-material/BarChart';
import InfoOutlinedIcon from '@mui/icons-material/InfoOutlined';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import TrainIcon from '@mui/icons-material/Train';
import Badge from '@mui/material/Badge';
import Button from '@mui/material/Button';
import Grid from '@mui/material/Grid';
import { Link as RouterLink } from 'react-router-dom';
import ImageCard from '../../../shared/components/cards/ImageCard';
import CardGridItem from '../../../shared/layouts/CardGridItem';
import CardGridContainer from '../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../shared/layouts/PageContainer';
import useModuleAvailability from '../../../app/hooks/useModuleAvailability';
import useUpdateStatus from '../../update/hooks/useUpdateStatus';
import getNavSections, { hubCeModuleId } from '../lib/NavElements';
import ControlExtensionSetupCard from './ControlExtensionSetupCard';

function MainMenu() {
  const { isModuleAvailable } = useModuleAvailability();
  const navigation = getNavSections(isModuleAvailable);
  const updateStatus = useUpdateStatus();
  const updateAvailable = updateStatus.state === 'stable-available' || updateStatus.state === 'prerelease-available';

  const trafficNav = navigation.filter((nav) => nav.name === 'Verkehr').flatMap((nav) => nav.values);
  const availableTrafficCards = trafficNav.filter((card) => card.available && card.image);
  const hubModuleAvailable = isModuleAvailable(hubCeModuleId);

  return (
    <PageContainer>
      {availableTrafficCards.length > 0 ? (
        <CardGridContainer>
          {availableTrafficCards.map((card) => (
            <CardGridItem key={card.title}>
              <ImageCard
                title={card.title}
                image={'/assets/' + card.image}
                to={card.link}
                {...(card.subtitle !== undefined ? { subtitle: card.subtitle } : {})}
              />
            </CardGridItem>
          ))}
        </CardGridContainer>
      ) : (
        <ControlExtensionSetupCard />
      )}
      <Grid
        container
        spacing={2}
        sx={{
          alignItems: 'flex-start',
          flexDirection: { xs: 'column', sm: 'row' },
          justifyContent: 'flex-start',
          mt: 2,
        }}
      >
        <Button variant="text" startIcon={<BarChartIcon />} component={RouterLink} to="/insights">
          Einblicke
        </Button>
        <Button variant="text" startIcon={<Inventory2Icon />} component={RouterLink} to="/data">
          Daten
        </Button>
        {hubModuleAvailable && (
          <Button variant="text" startIcon={<TrainIcon />} component={RouterLink} to="/selectedTrain">
            Aktiver Zug
          </Button>
        )}
        <Button
          variant="text"
          startIcon={
            updateAvailable ? (
              <Badge
                badgeContent={' '}
                color="success"
                overlap="circular"
                sx={{
                  '& .MuiBadge-badge': {
                    height: 14,
                    minWidth: 14,
                    p: 0,
                  },
                }}
              >
                <InfoOutlinedIcon />
              </Badge>
            ) : (
              <InfoOutlinedIcon />
            )
          }
          component={RouterLink}
          to="/about"
        >
          Über diese Version
        </Button>
      </Grid>
    </PageContainer>
  );
}

export default MainMenu;
