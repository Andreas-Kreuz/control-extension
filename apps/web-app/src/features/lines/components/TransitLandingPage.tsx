import ModuleSettingsButton from '../../../shared/components/ModuleSettingsButton';
import ImageCard from '../../../shared/components/cards/ImageCard';
import CardGridItem from '../../../shared/layouts/CardGridItem';
import CardGridContainer from '../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import useTransitSettings from '../hooks/useTransitSettings';

function TransitLandingPage() {
  const settings = useTransitSettings();

  return (
    <PageContainer>
      <PageHeadline
        {...(settings !== undefined ? { rightSettings: <ModuleSettingsButton settings={settings} /> } : {})}
      >
        ÖPNV
      </PageHeadline>
      <CardGridContainer>
        <CardGridItem>
          <ImageCard
            title="Linien"
            subtitle="Nahverkehrslinien ansehen"
            image="/assets/card-img-traffic.jpg"
            to="lines"
          />
        </CardGridItem>
        <CardGridItem>
          <ImageCard
            title="Haltestellen"
            subtitle="Abfahrten pro Station verfolgen"
            image="/assets/card-img-trains-tram.jpg"
            to="stations"
          />
        </CardGridItem>
      </CardGridContainer>
    </PageContainer>
  );
}

export default TransitLandingPage;
