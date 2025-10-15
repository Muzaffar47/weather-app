import 'package:intl/intl.dart';

class DailyForecastData {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String iconCode;

  DailyForecastData({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.iconCode,
  });

  // NOTE: This factory is a simplified model based on OpenWeatherMap's general structure.
  factory DailyForecastData.fromJson(Map<String, dynamic> json) {
    final tempMap = json['temp'] as Map<String, dynamic>;

    return DailyForecastData(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      // Convert from Kelvin to Celsius
      tempMax: (tempMap['max'] as num).toDouble() - 273.15,
      tempMin: (tempMap['min'] as num).toDouble() - 273.15,
      iconCode: json['weather'][0]['icon'] as String,
    );
  }

  String get dayOfWeek => DateFormat('E').format(date); // e.g., "Mon", "Tue"
}
