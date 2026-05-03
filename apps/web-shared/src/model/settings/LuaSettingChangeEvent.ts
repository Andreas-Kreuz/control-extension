import { SettingAppDto } from '../../dtos/app/settings/SettingAppDto';

export class SettingDtoChangeEvent {
  constructor(
    public setting: SettingAppDto<any>,
    public newValue: any,
  ) {}
}

export default SettingDtoChangeEvent;
