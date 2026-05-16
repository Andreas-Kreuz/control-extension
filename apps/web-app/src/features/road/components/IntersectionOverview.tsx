import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardActions from '@mui/material/CardActions';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import BackgroundImageCard from '../../../shared/components/cards/BackgroundImageCard';
import ModuleSettingsButton from '../../../shared/components/ModuleSettingsButton';
import CardGridContainer from '../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import ListLayout from '../../../shared/layouts/ListLayout';
import useSelectedElementNavigation from '../../../shared/layouts/useSelectedElementNavigation';
import useIntersectionSettings from '../hooks/useIntersectionSettings';
import useIntersections from '../hooks/useIntersections';
import useSelectedIntersection from '../hooks/useSelectedIntersection';
import IntersectionControlSection from './IntersectionControlSection';
import IntersectionCamsSection from './IntersectionCamsSection';
import IntersectionListItem from './IntersectionListItem';
import IntersectionPhasesSection from './IntersectionPhasesSection';
import type Intersection from '../model/Intersection';

interface IntersectionOverviewProps {
  selectedElement: string | undefined;
}

function IntersectionOverview({ selectedElement }: IntersectionOverviewProps) {
  const intersections = useIntersections();
  const selectedIntersection = useSelectedIntersection(selectedElement);
  const settings = useIntersectionSettings();
  const handleSelectedElementChange = useSelectedElementNavigation(selectedElement);

  function detailsIntersection(i: Intersection): Intersection {
    if (selectedElement !== String(i.id) || selectedIntersection?.id !== i.id) return i;

    return {
      ...i,
      ...selectedIntersection,
      staticCams: selectedIntersection.staticCams.length > 0 ? selectedIntersection.staticCams : i.staticCams,
      phases: selectedIntersection.phases.length > 0 ? selectedIntersection.phases : i.phases,
      greenTimeSeconds: selectedIntersection.greenTimeSeconds || i.greenTimeSeconds,
    };
  }

  return (
    <PageContainer>
      <PageHeadline
        {...(settings !== undefined ? { rightSettings: <ModuleSettingsButton settings={settings} /> } : {})}
      >
        Ampelkreuzungen
      </PageHeadline>
      <ListLayout
        items={intersections}
        keyExtractor={(i) => String(i.id)}
        getFilterText={(i) => `${i.id} ${i.name}`}
        filterLabel="Kreuzung filtern"
        renderListItem={(i, selected, onSelect) => (
          <IntersectionListItem intersection={i} selected={selected} onSelect={onSelect} />
        )}
        renderCard={(i, selected, onSelect, mobileExpansion) => (
          <BackgroundImageCard
            title={`Kreuzung ${i.id}`}
            id={i.name}
            image="/assets/card-img-intersection.jpg"
            selected={selected}
            expanded={selected}
            setExpanded={() => onSelect()}
          >
            {mobileExpansion}
          </BackgroundImageCard>
        )}
        getDetails={(i) => {
          const details = detailsIntersection(i);
          return [
            { title: 'Modus & Phase', component: <IntersectionControlSection intersection={details} /> },
            // { title: 'Phasen', component: <IntersectionPhasesSection intersection={details} /> },
            { title: 'Kameras', component: <IntersectionCamsSection intersection={details} /> },
          ];
        }}
        selectedElement={selectedElement}
        onSelectedElementChange={handleSelectedElementChange}
      />

      {/* <PageHeadline gutterTop>Hilfe</PageHeadline>
      <CardGridContainer>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 3 }}>
          <Card>
            <CardActionArea sx={{ p: 2 }} disabled>
              <Typography variant="h5" gutterBottom>
                Hilfe
              </Typography>
              <Typography variant="body2">Erfahre wie Du Kreuzungen mit der Control Extension einrichtest</Typography>
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
      </CardGridContainer> */}
    </PageContainer>
  );
}

export default IntersectionOverview;
