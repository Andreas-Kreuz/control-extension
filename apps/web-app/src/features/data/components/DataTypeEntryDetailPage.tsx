import { lazy } from 'react';
import { Link as RouterLink, useParams } from 'react-router-dom';
import Breadcrumbs from '@mui/material/Breadcrumbs';
import Link from '@mui/material/Link';
import Typography from '@mui/material/Typography';
import DataEntryDetailSection from './DataEntryDetailSection';

const AppPage = lazy(() => import('../../../shared/layouts/AppPage'));
const AppPageHeadline = lazy(() => import('../../../shared/layouts/AppPageHeadline'));

function DataTypeEntryDetailMod() {
  const { ceType = '', entryId = '' } = useParams<{ ceType: string; entryId: string }>();

  return (
    <AppPage>
      <Breadcrumbs sx={{ mb: 1 }}>
        <Link component={RouterLink} to="/data" underline="hover" color="inherit">
          CE-Typen
        </Link>
        <Link component={RouterLink} to={`/data/${encodeURIComponent(ceType)}`} underline="hover" color="inherit">
          {ceType}
        </Link>
        <Typography color="text.primary">{entryId}</Typography>
      </Breadcrumbs>
      <AppPageHeadline>{entryId}</AppPageHeadline>
      <DataEntryDetailSection ceType={ceType} entryId={entryId} />
    </AppPage>
  );
}

export default DataTypeEntryDetailMod;
