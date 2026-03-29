import SocketService from '../clientio/SocketService';
import { CacheService } from '../eep/server-data/CacheService';
import EepDataEffects from '../eep/server-data/EepDataEffects';
import EepService from '../eep/service/EepService';
import { ServerStatisticsService } from '../eep/service/ServerStatisticsService';
import { registerCommandMod } from '../mod/command/registerCommandMod';
import { registerRoadMod } from '../mod/road/registerRoadMod';
import { registerLogMod } from '../mod/log/registerLogMod';
import TransitService from '../mod/transit/TransitService';
import TrainUpdateService from '../mod/train/TrainUpdateService';
import VersionService from '../mod/version/VersionService';
import TimeService from '../mod/time/TimeService';
import WeatherService from '../mod/weather/WeatherService';
import EepDataService from '../mod/eepdata/EepDataService';
import RoadDataService from '../mod/road/RoadDataService';
import AppConfig from './config/AppConfig';
import AppReducer from './config/AppData';
import CommandLineParser from './config/CommandLineParser';
import { RoomEvent, ServerInfoEvent, SettingsEvent } from '@ak/web-shared';
import * as express from 'express';
import * as fs from 'fs';
import * as path from 'path';
import { performance } from 'perf_hooks';
import { Server, Socket } from 'socket.io';

export default class AppEffects {
  private debug = true;
  private serverConfigFile: string;
  private eepDataEffects!: EepDataEffects;
  private eepService: EepService | null = null;
  private store = new AppReducer();
  private TESTMODE = false;

  // Statistic data
  private statistics: ServerStatisticsService;

  constructor(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    private app: any,
    private router: express.Router,
    private io: Server,
    private socketService: SocketService,
    private serverConfigPath: string,
  ) {
    this.serverConfigFile = path.resolve(this.serverConfigPath, 'settings.json');

    // Start collecting statistic data
    this.statistics = new ServerStatisticsService();
    this.statistics.start();

    this.loadConfig();
    this.socketService.addOnSocketConnectedCallback((socket: Socket) => this.socketConnected(socket));
  }

  private socketConnected(socket: Socket) {
    socket.on(RoomEvent.JoinRoom, (rooms: { room: string }) => {
      if (rooms.room === SettingsEvent.Room) {
        if (!this.socketService.ensureAdminSocket(socket, SettingsEvent.Room)) {
          return;
        }
        const event = this.store.getEepDirOk() ? SettingsEvent.DirOk : SettingsEvent.DirError;
        if (this.debug) console.log('🟨 EMIT to ' + socket.id + ': ' + event, this.getEepDirectory());
        socket.emit(event, this.getEepDirectory());
        if (this.debug) console.log('🟨 EMIT to ' + socket.id + ': ' + SettingsEvent.Host, this.getHostname());
        socket.emit(SettingsEvent.Host, this.getHostname());
        if (this.debug)
          console.log('🟨 EMIT to ' + socket.id + ': ' + SettingsEvent.PairingRequired, this.getPairingRequired());
        socket.emit(SettingsEvent.PairingRequired, JSON.stringify(this.getPairingRequired()));
      }

      if (rooms.room === ServerInfoEvent.Room) {
        if (!this.socketService.ensureAdminSocket(socket, ServerInfoEvent.Room)) {
          return;
        }
        if (this.debug) console.log('🟨 EMIT to ' + socket.id + ': ' + ServerInfoEvent.Room, this.getHostname());
        socket.emit(ServerInfoEvent.StatisticsUpdate, this.statistics);
      }
    });

    socket.on(SettingsEvent.ChangeDir, (dir: string) => {
      if (!this.socketService.ensureAdminSocket(socket, SettingsEvent.ChangeDir)) {
        return;
      }
      if (this.debug) console.log(SettingsEvent.ChangeDir + '"' + dir + '"');
      this.changeEepDirectory(dir);
    });

    socket.on(SettingsEvent.ChangePairingRequired, (pairingRequired: boolean) => {
      if (!this.socketService.ensureAdminSocket(socket, SettingsEvent.ChangePairingRequired)) {
        return;
      }
      if (this.debug) console.log(SettingsEvent.ChangePairingRequired + '"' + pairingRequired + '"');
      this.changePairingRequired(Boolean(pairingRequired));
    });
  }

  private loadConfig(): void {
    let appConfig = new AppConfig();
    try {
      const options = new CommandLineParser().parseOptions();
      appConfig.eepDir = path.resolve(options['exchange-dir'] || '../web-app/cypress/io');
      this.TESTMODE = options.testmode || false;
      if (!this.TESTMODE && fs.statSync(this.serverConfigFile).isFile()) {
        const data = fs.readFileSync(this.serverConfigFile, { encoding: 'utf8' });
        const config = JSON.parse(data);
        appConfig = config;
      }
    } catch (error) {
      console.log(error);
    }
    appConfig.pairingRequired = appConfig.pairingRequired !== false;
    this.store.setAppConfig(appConfig);
    this.socketService.setPairingRequired(this.store.getPairingRequired());
  }

  private saveConfig(config: AppConfig): void {
    if (!this.TESTMODE) {
      try {
        fs.mkdirSync(this.serverConfigPath);
      } catch (_error) {
        // IGNORE console.log(error);
      }
      try {
        fs.writeFileSync(this.serverConfigFile, JSON.stringify(config));
      } catch (error) {
        console.log(error);
      }
    }
  }

  public getEepDirectory(): string {
    return this.store.getEepDir();
  }

  public getHostname(): string {
    return this.store.getHostname();
  }

  public saveEepDirectory(dir: string): void {
    this.store.setEepDir(dir);
    this.saveConfig(this.store.getAppConfig());
  }

  public getPairingRequired(): boolean {
    return this.store.getPairingRequired();
  }

  public changePairingRequired(pairingRequired: boolean): void {
    this.store.setPairingRequired(pairingRequired);
    this.socketService.setPairingRequired(pairingRequired);
    this.saveConfig(this.store.getAppConfig());
    this.io.to(SettingsEvent.Room).emit(SettingsEvent.PairingRequired, JSON.stringify(pairingRequired));
  }

  public changeEepDirectory(eepDir: string) {
    this.eepService?.disconnect();
    this.eepService = null;

    // Append the exchange directory to the path
    const completeDir = path.resolve(eepDir, 'LUA/ce/databridge/exchange/');

    // Check the directory and register handlers on success
    const eepService = new EepService(this.debug);
    eepService.reInit(completeDir, (err: string | null, dir: string | null) => {
      if (err) {
        console.error(err);
      }
      if (dir) {
        console.log('Directory set to : ' + dir);
        this.eepService = eepService;
        this.initServices(eepService);
        this.store.setEepDirOk(true);
        this.saveEepDirectory(eepDir);
        this.io.to(SettingsEvent.Room).emit(SettingsEvent.DirOk, eepDir);
      } else {
        this.store.setEepDirOk(false);
        this.saveEepDirectory(eepDir);
        this.io.to(SettingsEvent.Room).emit(SettingsEvent.DirError, eepDir);
      }

      if (this.debug) console.log('🟦 EMIT to all IO: ' + SettingsEvent.Host, this.getHostname());
      this.io.to(SettingsEvent.Room).emit(SettingsEvent.Host, this.store.getHostname());
    });
  }

  private initServices(eepService: EepService) {
    // Replacing the EEP service should also replace socket-connected handlers
    // so new clients do not accumulate duplicate room and command listeners.
    this.socketService.resetOnSocketConnectedCallbacks();
    this.socketService.addOnSocketConnectedCallback((socket: Socket) => this.socketConnected(socket));

    this.eepDataEffects = new EepDataEffects(this.router, this.io, this.socketService, eepService as CacheService);

    // Init event handler
    eepService.setOnNewEventLine((eventLines: string) => {
      this.eepDataEffects.onNewEventLine(eventLines);
    });

    this.registerMods(this.eepDataEffects, eepService);

    // Init JsonHandler
    eepService.setOnJsonContentChanged((jsonString: string, lastJsonUpdate: number) => {
      performance.mark('json-parsing:before');
      // this.jsonDataEffects.announceState(); // The real stuff
      performance.mark('json-parsing:after');
      performance.measure(ServerStatisticsService.TimeForJsonParsing, 'json-parsing:before', 'json-parsing:after');
      this.statistics.setLastEepTime(lastJsonUpdate);
    });
  }

  private registerMods(eepDataEffects: EepDataEffects, eepService: EepService) {
    // register dynamic rooms services
    eepDataEffects.registerDynamicRoom(new TrainUpdateService(this.io));
    eepDataEffects.registerDynamicRoom(new TransitService(this.io));
    eepDataEffects.registerDynamicRoom(new VersionService(this.io));
    eepDataEffects.registerDynamicRoom(new TimeService(this.io));
    eepDataEffects.registerDynamicRoom(new WeatherService(this.io));
    eepDataEffects.registerDynamicRoom(new EepDataService(this.io));
    eepDataEffects.registerDynamicRoom(new RoadDataService(this.io));

    // register mods
    registerLogMod(this.io, this.socketService, eepService, this.debug);
    registerCommandMod(this.io, this.socketService, eepService, this.debug);
    registerRoadMod(this.io, this.socketService, eepService, this.debug);
  }
}
