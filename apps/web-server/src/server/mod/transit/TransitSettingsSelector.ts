import { SettingLuaDto } from '../../ce/dto/settings/SettingLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { CeTypes, SettingDto, SettingsDto } from '@ce/web-shared';

export default class TransitSettingsSelector {
  private lastState?: fromEepData.State;
  private settings: SettingsDto = { moduleName: 'Public Transport', settings: [] };

  updateFromState(state: fromEepData.State): void {
    this.settings = { moduleName: 'Public Transport', settings: [] };

    if (state === this.lastState || !state.ceTypes[CeTypes.TransitModuleSetting]) {
      return;
    }
    this.lastState = state;

    const settingsDict = state.ceTypes[CeTypes.TransitModuleSetting] as unknown as Record<
      string,
      SettingLuaDto<unknown>
    >;
    Object.values(settingsDict).forEach((settingDto: SettingLuaDto<unknown>) => {
      const setting: SettingDto<unknown> = {
        name: settingDto.name,
        category: settingDto.category,
        description: settingDto.description,
        eepFunction: settingDto.eepFunction,
        type: settingDto.type,
        value: settingDto.value,
      };
      this.settings.settings.push(setting);
    });
  }

  getSettings = () => this.settings;
  getSetting = (name: string): SettingDto<unknown> | undefined =>
    this.settings.settings.find((setting) => setting.name === name);
}
