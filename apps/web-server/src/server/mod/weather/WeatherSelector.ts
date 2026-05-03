import { WeatherLuaDto } from '../../ce/dto/weather/WeatherLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { optionalProperty } from '../../utils/optionalProperty';
import { CeTypes, WeatherAppDto } from '@ce/web-shared';

// Maps Lua weather DTOs into WeatherAppDto.
// Lua input: ce.hub.Weather.
export default class WeatherSelector {
  private lastState?: fromEepData.State;
  private weather: Record<string, WeatherAppDto> = {};

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
        ...optionalProperty('season', dto.season),
        ...optionalProperty('cloudsIntensity', dto.cloudsIntensity),
        ...optionalProperty('cloudsMode', dto.cloudsMode),
        ...optionalProperty('windIntensity', dto.windIntensity),
        ...optionalProperty('rainIntensity', dto.rainIntensity),
        ...optionalProperty('snowIntensity', dto.snowIntensity),
        ...optionalProperty('hailIntensity', dto.hailIntensity),
        ...optionalProperty('fogIntensity', dto.fogIntensity),
      };
    });
  }

  getWeather = (): Record<string, WeatherAppDto> => this.weather;
}
