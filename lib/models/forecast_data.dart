import 'package:intl/intl.dart';

class ForecastData {
  final DateTime dateTime;
  final double temperature;
  final String iconCode;

  ForecastData({
    required this.dateTime,
    required this.temperature,
    required this.iconCode,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    // FIX: Get temperature directly. It is already Celsius.
    double temperature = (json['main']['temp'] as num).toDouble();

    return ForecastData(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: temperature,
      iconCode: json['weather'][0]['icon'] as String,
    );
  }
}
