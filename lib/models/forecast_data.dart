class ForecastData {
  final DateTime dateTime;
  final double temperature; // In Celsius
  final String iconCode;

  ForecastData({
    required this.dateTime,
    required this.temperature,
    required this.iconCode,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    double kelvinTemp = (json['main']['temp'] as num).toDouble();
    double celsiusTemp = kelvinTemp - 273.15;

    return ForecastData(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: celsiusTemp,
      iconCode: json['weather'][0]['icon'] as String,
    );
  }
}
