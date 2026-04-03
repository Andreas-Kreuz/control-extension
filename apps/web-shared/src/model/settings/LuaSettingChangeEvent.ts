import { SettingDto } from '../../dtos/server/settings/SettingDto';

export class SettingDtoChangeEvent {
  constructor(
    public setting: SettingDto<any>,
    public newValue: any,
  ) {}
}

export default SettingDtoChangeEvent;
