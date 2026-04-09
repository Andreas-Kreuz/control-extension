import { lazy } from 'react';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardActions from '@mui/material/CardActions';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import useIntersectionSettings from '../hooks/useIntersectionSettings';
import useIntersections from '../hooks/useIntersections';
import IntersectionControlSection from './IntersectionControlSection';
import IntersectionCamsSection from './IntersectionCamsSection';
import IntersectionListItem from './IntersectionListItem';

const AppCardBg = lazy(() => import('../../../shared/ui/AppCardBg'));
const AppCardGridContainer = lazy(() => import('../../../shared/ui/AppCardGridContainer'));
const AppPage = lazy(() => import('../../../shared/ui/AppPage'));
const AppPageHeadline = lazy(() => import('../../../shared/ui/AppPageHeadline'));
const ModuleSettingsButton = lazy(() => import('../../../shared/ui/ModuleSettingsButton'));
import ListLayout from '../../../shared/ui/ListLayout';

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
      <ListLayout
        items={intersections}
        keyExtractor={(i) => String(i.id)}
        getFilterText={(i) => `${i.id} ${i.name}`}
        filterLabel="Kreuzung filtern"
        renderListItem={(i, selected, onSelect) => (
          <IntersectionListItem intersection={i} selected={selected} onSelect={onSelect} />
        )}
        renderCard={(i, selected, onSelect, mobileExpansion) => (
          <AppCardBg
            title={`Kreuzung ${i.id}`}
            id={i.name}
            image="/assets/card-img-intersection.jpg"
            selected={selected}
            expanded={selected}
            setExpanded={() => onSelect()}
          >
            {mobileExpansion}
          </AppCardBg>
        )}
        getDetails={(i) => [
          { title: 'Modus & Schaltung', component: <IntersectionControlSection intersection={i} /> },
          { title: 'Kameras', component: <IntersectionCamsSection intersection={i} /> },
        ]}
      />

      <AppPageHeadline gutterTop>Hilfe</AppPageHeadline>
      <AppCardGridContainer>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 3 }}>
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
        </Grid>
      </AppCardGridContainer>
    </AppPage>
  );
}

export default IntersectionOverview;
