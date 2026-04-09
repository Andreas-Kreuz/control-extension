import { lazy } from 'react';
const AppCardBg = lazy(() => import('../../../shared/ui/AppCardBg'));
const AppCardGrid = lazy(() => import('../../../shared/ui/AppCardGrid'));
const AppCardGridContainer = lazy(() => import('../../../shared/ui/AppCardGridContainer'));
const AppPage = lazy(() => import('../../../shared/ui/AppPage'));
const AppPageHeadline = lazy(() => import('../../../shared/ui/AppPageHeadline'));
const ModuleSettingsButton = lazy(() => import('../../../shared/ui/ModuleSettingsButton'));
import useIntersectionSettings from '../hooks/useIntersectionSettings';
import useIntersections from '../hooks/useIntersections';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardActions from '@mui/material/CardActions';
import Typography from '@mui/material/Typography';

function IntersectionOverview() {
  const intersections = useIntersections();
  const settings = useIntersectionSettings();

  return (
    <AppPage>
      <AppPageHeadline
        {...(settings !== undefined ? { rightSettings: <ModuleSettingsButton settings={settings} /> } : {})}
      >
        Ampelkreuzungen
      </AppPageHeadline>
      <AppCardGridContainer>
        {intersections.map((i) => (
          <AppCardGrid key={i.id}>
            <AppCardBg
              title={`Kreuzung ${i.id}`}
              id={i.name}
              image="/assets/card-img-intersection.jpg"
              to={`/road/${i.id}`}
            />
          </AppCardGrid>
        ))}
      </AppCardGridContainer>

      <AppPageHeadline gutterTop>Hilfe</AppPageHeadline>
      <AppCardGridContainer>
        <AppCardGrid>
          <Card>
            <CardActionArea sx={{ p: 2 }} disabled>
              <Typography variant="h5" gutterBottom>
                Hilfe
              </Typography>
              <Typography variant="body2">Erfahre wie Du Kreuzungen mit der Lua-Bibliothek einrichtest</Typography>
            </CardActionArea>
            <CardActions>
              <Button
                href="https://andreas-kreuz.github.io/control-extension/docs/anleitungen/"
                target="_blank"
                rel="noopener noreferrer"
              >
                Anleitung
              </Button>
            </CardActions>
          </Card>
        </AppCardGrid>
      </AppCardGridContainer>
    </AppPage>
  );
}

export default IntersectionOverview;
