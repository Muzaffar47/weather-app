class WeatherData {
  final String cityName;
  final double temperature; // In Celsius
  final String description;
  final int humidity;
  final double windSpeed; // In m/s
  final String iconCode;
  final DateTime date;
  final double windDegrees; // NEW: Wind direction in degrees (0-360)
  final int pressure; // NEW: Atmospheric pressure (hPa)
  final double latitude; // NEW: Latitude, needed for forecast by city name
  final double longitude; // NEW: Longitude, needed for forecast by city name

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.date,
    required this.windDegrees, // NEW
    required this.pressure, // NEW
    required this.latitude, // NEW
    required this.longitude, // NEW
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // OpenWeatherMap returns temperature in Kelvin by default,
    double kelvinTemp = (json['main']['temp'] as num).toDouble();
    double celsiusTemp = kelvinTemp - 273.15;

    return WeatherData(
      cityName: json['name'] as String,
      temperature: celsiusTemp,
      description: json['weather'][0]['description'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      // Mapped new properties
      windDegrees: (json['wind']['deg'] as num).toDouble(),
      pressure: json['main']['pressure'] as int,
      latitude: json['coord']['lat'] as double,
      longitude: json['coord']['lon'] as double,
    );
  }
}
