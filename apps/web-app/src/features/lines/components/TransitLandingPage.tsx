import ModuleSettingsButton from '../../../shared/components/ModuleSettingsButton';
import AppCardImg from '../../../shared/components/AppCardImg';
import AppCardGrid from '../../../shared/layouts/AppCardGrid';
import AppCardGridContainer from '../../../shared/layouts/AppCardGridContainer';
import AppPage from '../../../shared/layouts/AppPage';
import AppPageHeadline from '../../../shared/layouts/AppPageHeadline';
import useTransitSettings from '../hooks/useTransitSettings';

function TransitLandingPage() {
  const settings = useTransitSettings();

  return (
    <AppPage>
      <AppPageHeadline
        {...(settings !== undefined ? { rightSettings: <ModuleSettingsButton settings={settings} /> } : {})}
      >
        ÖPNV
      </AppPageHeadline>
      <AppCardGridContainer>
        <AppCardGrid>
          <AppCardImg
            title="Linien"
            subtitle="Nahverkehrslinien ansehen"
            image="/assets/card-img-traffic.jpg"
            to="lines"
          />
        </AppCardGrid>
        <AppCardGrid>
          <AppCardImg
            title="Haltestellen"
            subtitle="Abfahrten pro Station verfolgen"
            image="/assets/card-img-trains-tram.jpg"
            to="stations"
          />
        </AppCardGrid>
      </AppCardGridContainer>
    </AppPage>
  );
}

export default TransitLandingPage;
