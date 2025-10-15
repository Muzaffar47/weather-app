import 'package:flutter/material.dart';

// Helper function to determine the background based on OpenWeatherMap icon code (e.g., '01d', '10n')
List<Color> getWeatherGradient(String iconCode) {
  // Determine if it's day (d) or night (n)
  bool isDay = iconCode.endsWith('d');

  switch (iconCode.substring(0, 2)) {
    case '01': // Clear Sky
      return isDay
          ? [const Color(0xFF48A6EF), const Color(0xFF47C2FF)] // Sunny Day Blue
          : [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
            ]; // Clear Night Dark

    case '02': // Few Clouds
    case '03': // Scattered Clouds
    case '04': // Broken Clouds
      return isDay
          ? [
              const Color(0xFFC3CFE2),
              const Color(0xFF414D6A),
            ] // Cloudy Day Gray
          : [
              const Color(0xFF333333),
              const Color(0xFF555555),
            ]; // Cloudy Night Gray-Black

    case '09': // Shower Rain
    case '10': // Rain
    case '11': // Thunderstorm
      return [
        const Color(0xFF1E3C72),
        const Color(0xFF2A5298),
      ]; // Rainy/Stormy Deep Blue

    case '13': // Snow
      return [
        const Color(0xFFB9E5F2),
        const Color(0xFFD2E8F4),
      ]; // Snowy Light Blue

    case '50': // Mist / Fog
      return [
        const Color(0xFFA7BFE8),
        const Color(0xFF6190E8),
      ]; // Misty Lavender

    default: // Default/Fallback
      return [const Color(0xFF1E213A), const Color(0xFF283845)];
  }
}
