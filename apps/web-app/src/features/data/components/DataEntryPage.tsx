import { Link as RouterLink, useParams } from 'react-router-dom';
import Breadcrumbs from '@mui/material/Breadcrumbs';
import Link from '@mui/material/Link';
import Typography from '@mui/material/Typography';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import DataEntrySection from './DataEntrySection';

function DataEntryPage() {
  const { ceType = '', entryId = '' } = useParams<{ ceType: string; entryId: string }>();

  return (
    <PageContainer>
      <Breadcrumbs sx={{ mb: 1 }}>
        <Link component={RouterLink} to="/data" underline="hover" color="inherit">
          CE-Typen
        </Link>
        <Link component={RouterLink} to={`/data/${encodeURIComponent(ceType)}`} underline="hover" color="inherit">
          {ceType}
        </Link>
        <Typography color="textPrimary">{entryId}</Typography>
      </Breadcrumbs>
      <PageHeadline>{entryId}</PageHeadline>
      <DataEntrySection ceType={ceType} entryId={entryId} />
    </PageContainer>
  );
}

export default DataEntryPage;
