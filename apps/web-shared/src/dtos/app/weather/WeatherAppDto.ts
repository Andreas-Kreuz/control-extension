// App contract populated by:
// apps/web-server/src/server/mod/weather/WeatherSelector.ts
export interface WeatherAppDto {
  id: string;
  name: string;
  season?: number;
  cloudsIntensity?: number;
  cloudsMode?: number;
  windIntensity?: number;
  rainIntensity?: number;
  snowIntensity?: number;
  hailIntensity?: number;
  fogIntensity?: number;
}
