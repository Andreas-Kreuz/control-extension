import AppConfig from './AppConfig';
import getHostName from './getHostname';

export default class AppData {
  private appConfig = new AppConfig();
  private eepDirOk = false;
  private hostName = getHostName() ?? 'localhost';

  public setAppConfig(appConfig: AppConfig): void {
    this.appConfig = appConfig;
  }

  public getAppConfig(): AppConfig {
    return this.appConfig;
  }
  public setEepDir(dir: string): void {
    this.appConfig.eepDir = dir;
  }

  public getEepDir(): string {
    return this.appConfig.eepDir;
  }

  public setPairingRequired(pairingRequired: boolean): void {
    this.appConfig.pairingRequired = pairingRequired;
  }

  public getPairingRequired(): boolean {
    return this.appConfig.pairingRequired;
  }

  public setEepDirOk(ok: boolean): void {
    this.eepDirOk = ok;
  }

  public getEepDirOk(): boolean {
    return this.eepDirOk;
  }

  public getHostname(): string {
    return this.hostName;
  }
}
