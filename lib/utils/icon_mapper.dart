import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

IconData getWeatherIcon(String iconCode) {
  // Use the first two characters for the main weather type
  final code = iconCode.substring(0, 2);

  switch (code) {
    case '01':
      return WeatherIcons.day_sunny; // Clear Sky
    case '02':
      return WeatherIcons.day_cloudy; // Few Clouds
    case '03':
      return WeatherIcons.cloud; // Scattered Clouds
    case '04':
      return WeatherIcons.cloudy; // Broken Clouds
    case '09':
      return WeatherIcons.showers; // Shower Rain
    case '10':
      return WeatherIcons.rain; // Rain
    case '11':
      return WeatherIcons.thunderstorm; // Thunderstorm
    case '13':
      return WeatherIcons.snow; // Snow
    case '50':
      return WeatherIcons.fog; // Mist/Fog
    default:
      return WeatherIcons.na; // Not Available
  }
}
