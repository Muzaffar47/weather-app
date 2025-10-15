import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../models/city_suggestion.dart';

class WeatherService {
  final String apiKey = const String.fromEnvironment(
    'OPEN_WEATHER_API_KEY',
  ); // <<< REPLACE THIS
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // --- 1. Fetch Current Weather by Coordinates ---
  Future<WeatherData> fetchCurrentWeather(double lat, double lon) async {
    final url = '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Failed to load current weather: ${response.statusCode}');
    }
  }

  // --- 2. Fetch 5-Day/3-Hour Forecast by Coordinates ---
  Future<List<ForecastData>> fetchWeatherForecast(
    double lat,
    double lon,
  ) async {
    final url = '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List list = json['list'];

      // Map the list of forecast items to ForecastData models
      return list.map((e) => ForecastData.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load weather forecast: ${response.statusCode}',
      );
    }
  }

  Future<WeatherData> fetchCurrentWeatherByCity(String cityName) async {
    // Ensure the city name is URL-encoded for safety
    final encodedCity = Uri.encodeComponent(cityName);
    // Assuming baseUrl and apiKey are defined globally in this class
    final url = '$baseUrl/weather?q=$encodedCity&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherData.fromJson(json);
    } else if (response.statusCode == 404) {
      throw Exception('City not found. Please check spelling.');
    } else {
      throw Exception('Failed to load current weather: ${response.statusCode}');
    }
  }

  Future<List<CitySuggestion>> searchCities(String query) async {
    if (query.isEmpty) return [];

    final encodedQuery = Uri.encodeComponent(query);
    // OpenWeatherMap Geocoding API endpoint: 'direct'
    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=$encodedQuery&limit=5&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // Map the list of JSON objects to CitySuggestion models
      return data.map((json) => CitySuggestion.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch city suggestions.');
    }
  }
}
