import { WeatherLuaDto } from '../../ce/dto/weather/WeatherLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { CeTypes, WeatherDto } from '@ak/web-shared';

export default class WeatherSelector {
  private lastState: fromEepData.State = undefined;
  private weather: Record<string, WeatherDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState || !state.ceTypes[CeTypes.HubWeather]) {
      return;
    }
    this.lastState = state;
    const dict = state.ceTypes[CeTypes.HubWeather] as unknown as Record<string, WeatherLuaDto>;
    this.weather = {};
    Object.values(dict).forEach((dto: WeatherLuaDto) => {
      this.weather[dto.id] = {
        id: dto.id,
        name: dto.name,
        season: dto.season,
        cloudsIntensity: dto.cloudsIntensity,
        cloudsMode: dto.cloudsMode,
        windIntensity: dto.windIntensity,
        rainIntensity: dto.rainIntensity,
        snowIntensity: dto.snowIntensity,
        hailIntensity: dto.hailIntensity,
        fogIntensity: dto.fogIntensity,
      };
    });
  }

  getWeather = (): Record<string, WeatherDto> => this.weather;
}
