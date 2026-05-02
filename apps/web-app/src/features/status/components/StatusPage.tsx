import Grid from '@mui/material/Grid';
import { useSocketIsConnected } from '../../../app/hooks/useSocketConnection';
import { useServerStatus } from '../hooks/useServerInfo';
import ConnectionStatusCard from './ConnectionStatusCard';

function StatusPage() {
  const isConnected = useSocketIsConnected();
  const [eepDataUpToDate, luaDataReceived, apiEntryCount] = useServerStatus();

  return (
    <Grid container spacing={3} sx={{ width: 'auto', m: 3 }}>
      <Grid size={{ xs: 12 }}>
        <ConnectionStatusCard
          name="Web-Server"
          icon={isConnected ? 'ok' : 'error'}
          statusColor={isConnected ? 'success' : 'error'}
          statusText={isConnected ? 'OK' : 'Server nicht erreichbar'}
          statusDescription="Diese Webseite zeigt nur aktuelle Informationen an, wenn sie den Web-Server erreicht."
        ></ConnectionStatusCard>
      </Grid>
      <Grid size={{ xs: 12 }}>
        <ConnectionStatusCard
          name="Data-Bridge"
          icon={isConnected && luaDataReceived ? 'ok' : 'error'}
          statusColor={isConnected && luaDataReceived ? 'success' : 'error'}
          statusText={
            isConnected ? (luaDataReceived ? 'OK' : 'Bibliothek nicht eingebunden') : 'Server nicht erreichbar'
          }
          statusDescription={
            isConnected
              ? luaDataReceived
                ? 'Die Data-Bridge stellt ' + apiEntryCount + ' verschiedene Informationen zur Verfügung'
                : 'Konfiguriere die Control-Extension in EEP, damit Du Informationen anzeigen kannst'
              : 'Diese Webseite zeigt nur aktuelle Informationen an, wenn sie den Web-Server erreicht.'
          }
        />
      </Grid>
      <Grid size={{ xs: 12 }}>
        <ConnectionStatusCard
          name="EEP"
          icon={isConnected ? (eepDataUpToDate ? 'ok' : 'time') : 'error'}
          statusColor={isConnected ? (eepDataUpToDate ? 'success' : 'warning') : 'error'}
          statusText={isConnected ? (eepDataUpToDate ? 'OK' : 'Daten nicht aktuell') : 'Server nicht erreichbar'}
          statusDescription={
            isConnected
              ? eepDataUpToDate
                ? 'Wenn EEP pausiert ist, dann werden keine Updates empfangen und keine Befehle entgegengenommen.'
                : 'Wenn EEP pausiert ist, dann werden keine Updates empfangen und keine Befehle entgegengenommen.'
              : 'Diese Webseite zeigt nur aktuelle Informationen an, wenn sie den Web-Server erreicht.'
          }
        />
      </Grid>
    </Grid>
  );
}

export default StatusPage;
