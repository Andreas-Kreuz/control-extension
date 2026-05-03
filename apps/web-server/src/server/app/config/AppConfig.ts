export default class AppConfig {
  eepDir: string;
  pairingRequired: boolean;
  searchForUpdates: boolean;

  constructor() {
    this.eepDir = 'C:\\Trend\\EEP18';
    this.pairingRequired = true;
    this.searchForUpdates = false;
  }
}
