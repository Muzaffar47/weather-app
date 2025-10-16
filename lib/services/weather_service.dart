import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/daily_forecast_data.dart';
import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../models/city_suggestion.dart';

class WeatherService {
  final String apiKey = const String.fromEnvironment('OPEN_WEATHER_API_KEY');
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // --- 1. Fetch Current Weather by Coordinates ---
  Future<WeatherData> fetchCurrentWeather(double lat, double lon) async {
    final url = '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Failed to load current weather: ${response.statusCode}');
    }
  }

  // --- FIX: Derive Daily Forecast from 5-day/3-hour data (v2.5) ---
  Future<List<DailyForecastData>> fetchDailyForecast(
    double lat,
    double lon,
  ) async {
    // API URL already includes &units=metric
    final url =
        '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List list = json['list'];

      // Group forecast items by date
      final Map<DateTime, List<dynamic>> dailyMap = {};

      for (var item in list) {
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(
          item['dt'] * 1000,
          isUtc: true,
        );
        final DateTime dayKey = DateTime(date.year, date.month, date.day);

        if (!dailyMap.containsKey(dayKey)) {
          dailyMap[dayKey] = [];
        }
        dailyMap[dayKey]!.add(item);
      }

      // Process the daily groups to extract min/max temp and the midday icon
      final List<DailyForecastData> dailyForecasts = [];

      dailyMap.forEach((date, hourlyData) {
        if (dailyForecasts.length >= 7) return; // Limit to 7 days

        // Extract all temperatures for the day (these are already in Celsius from the API call)
        final List<double> temps = hourlyData
            .map((e) => (e['main']['temp'] as num).toDouble())
            .toList();

        // Extract the icon from the item closest to midday (12:00 UTC)
        final bestIconItem = hourlyData.firstWhere((item) {
          final dt = DateTime.fromMillisecondsSinceEpoch(
            item['dt'] * 1000,
            isUtc: true,
          );
          return dt.hour >= 11 && dt.hour <= 15;
        }, orElse: () => hourlyData.first);

        dailyForecasts.add(
          DailyForecastData(
            date: date.toLocal(),
            // FIX 2: Removed the incorrect -273.15 subtraction here
            tempMax: temps.reduce((a, b) => a > b ? a : b),
            tempMin: temps.reduce((a, b) => a < b ? a : b),
            iconCode: bestIconItem['weather'][0]['icon'] as String,
          ),
        );
      });

      return dailyForecasts;
    } else {
      throw Exception(
        'Failed to load weather forecast: ${response.statusCode}',
      );
    }
  }

  // --- 2. Fetch 5-Day/3-Hour Forecast by Coordinates (Standard) ---
  Future<List<ForecastData>> fetchWeatherForecast(
    double lat,
    double lon,
  ) async {
    final url =
        '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
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
    final encodedCity = Uri.encodeComponent(cityName);
    final url = '$baseUrl/weather?q=$encodedCity&appid=$apiKey&units=metric';
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
    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=$encodedQuery&limit=5&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => CitySuggestion.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch city suggestions.');
    }
  }
}
