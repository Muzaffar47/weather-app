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

  String get dayOfWeek => DateFormat('E').format(date);

  // NOTE: This factory is used by the WeatherService to process the 3-hour list.
  // The service passes already-processed Celsius values, so this model itself needs
  // no conversion logic (assuming the service passes correct metric data).
  factory DailyForecastData.fromJson(Map<String, dynamic> json) {
    final tempMap = json['temp'] as Map<String, dynamic>;

    return DailyForecastData(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      // Assuming correct Celsius value is passed from service/API
      tempMax: (tempMap['max'] as num).toDouble(),
      tempMin: (tempMap['min'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'] as String,
    );
  }
}
