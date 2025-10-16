import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../models/daily_forecast_data.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider with ChangeNotifier {
  // Service classes
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  // State properties
  WeatherData? _currentWeather;
  List<ForecastData> _hourlyForecast = [];
  List<DailyForecastData> _dailyForecast = [];
  WeatherState _state = WeatherState.initial;
  String? _errorMessage;

  // Getters
  WeatherData? get currentWeather => _currentWeather;
  List<ForecastData> get hourlyForecast => _hourlyForecast;
  List<DailyForecastData> get dailyForecast => _dailyForecast;
  WeatherState get state => _state;
  String? get errorMessage => _errorMessage;

  // --- Core Data Fetch Logic (Reusable) ---
  // This function fetches all necessary data (hourly and daily) for a given location.
  Future<void> _fetchAllWeatherData(double lat, double lon) async {
    // 1. Fetch current and hourly forecast (existing live calls)
    _currentWeather = await _weatherService.fetchCurrentWeather(lat, lon);
    _hourlyForecast = (await _weatherService.fetchWeatherForecast(
      lat,
      lon,
    )).take(8).toList();

    // 2. LIVE DATA INTEGRATION: Fetch 7-day daily forecast using One Call API
    // Assumes WeatherService has the fetchDailyForecast method implemented.
    _dailyForecast = await _weatherService.fetchDailyForecast(lat, lon);
  }

  // --- Main Fetch Function: By GPS Location ---
  Future<void> fetchWeatherForCurrentLocation() async {
    _state = WeatherState.loading;
    notifyListeners();
    _errorMessage = null;

    try {
      // 1. Get location
      Position position = await _locationService.getCurrentLocation();
      double lat = position.latitude;
      double lon = position.longitude;

      // 2. Fetch all data using coordinates
      await _fetchAllWeatherData(lat, lon);

      _state = WeatherState.loaded;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception:')
          ? e.toString().split('Exception: ')[1]
          : 'An unexpected error occurred: ${e.toString()}';
      _state = WeatherState.error;
    } finally {
      notifyListeners();
    }
  }

  // --- Main Fetch Function: By City Search ---
  Future<void> fetchWeatherForCity(String cityName) async {
    _state = WeatherState.loading;
    notifyListeners();
    _errorMessage = null;

    try {
      // 1. Fetch current weather by city name (required to get new lat/lon)
      final newWeather = await _weatherService.fetchCurrentWeatherByCity(
        cityName,
      );

      // 2. Extract coordinates from the result
      double lat = newWeather.latitude;
      double lon = newWeather.longitude;

      // 3. Update current weather state immediately
      _currentWeather = newWeather;

      // 4. Fetch all other data using the new coordinates
      await _fetchAllWeatherData(lat, lon);

      _state = WeatherState.loaded;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception:')
          ? e.toString().split('Exception: ')[1]
          : 'An unexpected error occurred: ${e.toString()}';
      _state = WeatherState.error;
    } finally {
      notifyListeners();
    }
  }
}
