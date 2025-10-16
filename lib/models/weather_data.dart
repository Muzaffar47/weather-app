class WeatherData {
  final String cityName;
  final double temperature; // In Celsius
  final String description;
  final int humidity;
  final double windSpeed; // In m/s
  final String iconCode;
  final DateTime date;
  final double windDegrees; // NEW
  final int pressure; // NEW
  final double latitude; // NEW
  final double longitude; // NEW

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.date,
    required this.windDegrees,
    required this.pressure,
    required this.latitude,
    required this.longitude,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // FIX: Get temperature directly. It is already Celsius due to &units=metric in the API call.
    double temperature = (json['main']['temp'] as num).toDouble();

    return WeatherData(
      cityName: json['name'] as String,
      temperature: temperature,
      description: json['weather'][0]['description'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      windDegrees: (json['wind']['deg'] as num).toDouble(),
      pressure: json['main']['pressure'] as int,
      latitude: (json['coord']['lat'] as num).toDouble(),
      longitude: (json['coord']['lon'] as num).toDouble(),
    );
  }
}
