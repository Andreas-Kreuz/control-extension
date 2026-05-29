import SocketService from '../clientio/SocketService';
import { CacheService } from '../eep/server-data/CacheService';
import EepDataEffects from '../eep/server-data/EepDataEffects';
import InterestSyncRegistry from '../eep/server-data/dynamic/InterestSyncRegistry';
import InterestSyncService from '../eep/server-data/dynamic/InterestSyncService';
import EepService from '../eep/service/EepService';
import { ServerStatisticsService } from '../eep/service/ServerStatisticsService';
import { registerCommandMod } from '../mod/command/registerCommandMod';
import { registerRoadMod } from '../mod/road/registerRoadMod';
import { registerLogMod } from '../mod/log/registerLogMod';
import TransitService from '../mod/transit/TransitService';
import TrainUpdateService from '../mod/train/TrainUpdateService';
import VersionService from '../mod/version/VersionService';
import EepDataService from '../mod/eepdata/EepDataService';
import RoadDataService from '../mod/road/RoadDataService';
import IntersectionWizardService from '../mod/road/IntersectionWizardService';
import ScenarioService from '../mod/scenario/ScenarioService';
import AppConfig from './config/AppConfig';
import AppReducer from './config/AppData';
import CommandLineParser from './config/CommandLineParser';
import UpdateCheckService, { UpdateStatusRoomElement } from './update/UpdateCheckService';
import { RoomEvent, ServerInfoEvent, SettingsEvent, UpdateStatusRoom } from '@ce/web-shared';
import type { UpdateStatusAppDto } from '@ce/web-shared';
import * as express from 'express';
import * as fs from 'fs';
import * as path from 'path';
import { performance } from 'perf_hooks';
import { Server, Socket } from 'socket.io';

interface AppEffectsOptions {
  debug?: boolean;
}

export default class AppEffects {
  private debug = true;
  private serverConfigFile: string;
  private eepDataEffects!: EepDataEffects;
  private eepService: EepService | null = null;
  private interestSyncService: InterestSyncService | null = null;
  private store = new AppReducer();
  private TESTMODE = false;
  private persistServerState = true;
  private stopped = false;
  private updateCheckService: UpdateCheckService;
  private updateSearchStarted = false;

  // Statistic data
  private statistics: ServerStatisticsService;

  constructor(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    private app: any,
    private router: express.Router,
    private io: Server,
    private socketService: SocketService,
    private serverConfigPath: string,
    options: AppEffectsOptions = {},
  ) {
    this.debug = options.debug ?? true;
    this.serverConfigFile = path.resolve(this.serverConfigPath, 'settings.json');
    this.updateCheckService = new UpdateCheckService({ cacheDirectory: this.serverConfigPath });
    this.updateCheckService.onStatusChanged((status) => this.emitUpdateStatus(status));

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
        if (this.debug)
          console.log('🟨 EMIT to ' + socket.id + ': ' + SettingsEvent.SearchForUpdates, this.getSearchForUpdates());
        socket.emit(SettingsEvent.SearchForUpdates, JSON.stringify(this.getSearchForUpdates()));
      }

      if (rooms.room === ServerInfoEvent.Room) {
        if (!this.socketService.ensureAdminSocket(socket, ServerInfoEvent.Room)) {
          return;
        }
        if (this.debug) console.log('🟨 EMIT to ' + socket.id + ': ' + ServerInfoEvent.Room, this.getHostname());
        socket.emit(ServerInfoEvent.StatisticsUpdate, this.statistics);
      }

      if (rooms.room === UpdateStatusRoom.roomId(UpdateStatusRoomElement)) {
        if (!this.socketService.ensureApprovedSocket(socket, rooms.room)) {
          return;
        }
        socket.emit(UpdateStatusRoom.eventId(UpdateStatusRoomElement), JSON.stringify(this.getUpdateStatus()));
        if (this.getSearchForUpdates()) {
          void this.updateCheckService.refresh();
        }
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

    socket.on(SettingsEvent.ChangeSearchForUpdates, (searchForUpdates: boolean) => {
      if (!this.socketService.ensureAdminSocket(socket, SettingsEvent.ChangeSearchForUpdates)) {
        return;
      }
      if (this.debug) console.log(SettingsEvent.ChangeSearchForUpdates + '"' + searchForUpdates + '"');
      this.changeSearchForUpdates(Boolean(searchForUpdates));
    });
  }

  private emitUpdateStatus(status: UpdateStatusAppDto): void {
    if (!this.getSearchForUpdates()) {
      return;
    }
    this.io
      .to(UpdateStatusRoom.roomId(UpdateStatusRoomElement))
      .emit(UpdateStatusRoom.eventId(UpdateStatusRoomElement), JSON.stringify(status));
  }

  private getUpdateStatus(): UpdateStatusAppDto {
    if (!this.getSearchForUpdates()) {
      return { state: 'current', currentVersion: this.updateCheckService.getStatus().currentVersion };
    }

    return this.updateCheckService.getStatus();
  }

  private loadConfig(): void {
    let appConfig = new AppConfig();
    try {
      const options = new CommandLineParser().parseOptions();
      appConfig.eepDir = path.resolve(options['exchange-dir'] || '../web-app/cypress/io');
      this.TESTMODE = options.testmode || false;
      this.persistServerState = options['skip-server-state-persistence'] !== true;
      if (!this.TESTMODE && fs.statSync(this.serverConfigFile).isFile()) {
        const data = fs.readFileSync(this.serverConfigFile, { encoding: 'utf8' });
        const config = JSON.parse(data);
        appConfig = config;
      }
    } catch (error) {
      console.log(error);
    }
    appConfig.pairingRequired = appConfig.pairingRequired !== false;
    appConfig.searchForUpdates = appConfig.searchForUpdates === true;
    this.store.setAppConfig(appConfig);
    this.socketService.setPairingRequired(this.store.getPairingRequired());
    if (this.store.getSearchForUpdates()) {
      this.startUpdateSearch();
    }
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

  public getSearchForUpdates(): boolean {
    return this.store.getSearchForUpdates();
  }

  public changePairingRequired(pairingRequired: boolean): void {
    this.store.setPairingRequired(pairingRequired);
    this.socketService.setPairingRequired(pairingRequired);
    this.saveConfig(this.store.getAppConfig());
    this.io.to(SettingsEvent.Room).emit(SettingsEvent.PairingRequired, JSON.stringify(pairingRequired));
  }

  public changeSearchForUpdates(searchForUpdates: boolean): void {
    this.store.setSearchForUpdates(searchForUpdates);
    this.saveConfig(this.store.getAppConfig());
    this.io.to(SettingsEvent.Room).emit(SettingsEvent.SearchForUpdates, JSON.stringify(searchForUpdates));

    if (searchForUpdates) {
      this.startUpdateSearch();
      void this.updateCheckService.refresh();
      return;
    }

    this.updateCheckService.stop();
    this.updateSearchStarted = false;
    this.io
      .to(UpdateStatusRoom.roomId(UpdateStatusRoomElement))
      .emit(UpdateStatusRoom.eventId(UpdateStatusRoomElement), JSON.stringify(this.getUpdateStatus()));
  }

  private startUpdateSearch(): void {
    if (this.updateSearchStarted) {
      return;
    }

    this.updateSearchStarted = true;
    this.updateCheckService.start();
  }

  public changeEepDirectory(eepDir: string) {
    if (this.stopped) {
      return;
    }

    this.eepDataEffects?.stop();
    this.eepService?.disconnect();
    this.eepService = null;

    // Append the exchange directory to the path
    const completeDir = path.resolve(eepDir, 'LUA/ce/databridge/exchange/');

    // Check the directory and register handlers on success
    const eepService = new EepService(this.debug, { persistServerState: this.persistServerState });
    eepService.reInit(completeDir, (err: string | null, dir: string | null) => {
      if (this.stopped) {
        eepService.disconnect();
        return;
      }

      if (err) {
        console.error(err);
      }
      if (dir) {
        if (this.debug) console.log('Directory set to : ' + dir);
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

  public stop(): void {
    this.stopped = true;
    this.updateCheckService.stop();
    this.updateSearchStarted = false;
    this.statistics.stop();
    this.eepDataEffects?.stop();
    this.eepService?.disconnect();
    this.eepService = null;
    this.interestSyncService = null;
  }

  private initServices(eepService: EepService) {
    // Replacing the EEP service should also replace socket-connected handlers
    // so new clients do not accumulate duplicate room and command listeners.
    this.socketService.resetOnSocketConnectedCallbacks();
    this.socketService.addOnSocketConnectedCallback((socket: Socket) => this.socketConnected(socket));

    this.interestSyncService = new InterestSyncService(new InterestSyncRegistry(eepService.queueCommand));
    this.eepDataEffects = new EepDataEffects(
      this.router,
      this.io,
      this.socketService,
      eepService as CacheService,
      this.interestSyncService,
      { debug: this.debug },
    );

    // Init event handler
    eepService.setOnNewEventLine((eventLines: string) => {
      this.eepDataEffects.onNewEventLine(eventLines);
    });
    eepService.setOnEventTransferFinished(() => {
      this.eepDataEffects.onEventTransferFinished();
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
    eepDataEffects.registerDomainRoom(
      new TrainUpdateService(this.io, this.router, this.interestSyncService ?? undefined),
    );
    eepDataEffects.registerDomainRoom(new TransitService(this.io));
    eepDataEffects.registerDomainRoom(new VersionService(this.io));
    eepDataEffects.registerDomainRoom(new ScenarioService(this.io));
    eepDataEffects.registerDomainRoom(new EepDataService(this.io));
    eepDataEffects.registerDomainRoom(new RoadDataService(this.io));
    eepDataEffects.registerDomainRoom(new IntersectionWizardService(this.router, eepService));

    // register mods
    registerLogMod(this.io, this.socketService, eepService, this.debug);
    registerCommandMod(this.io, this.socketService, eepService, this.debug);
    registerRoadMod(this.io, this.socketService, eepService, this.debug);
  }
}
