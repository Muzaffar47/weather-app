import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // REQUIRED for Position
import '../services/weather_service.dart'; // REQUIRED for WeatherService
import '../services/location_service.dart'; // REQUIRED for LocationService
import '../models/weather_data.dart'; // REQUIRED for WeatherData
import '../models/forecast_data.dart'; // REQUIRED for ForecastData
import '../models/daily_forecast_data.dart'; // REQUIRED for DailyForecastData

// NOTE: The previous code had redundant imports. This version is cleaned up.

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider with ChangeNotifier {
  // Service classes (assuming they are implemented correctly)
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

  // --- Mock Data Function ---
  void _mockDailyForecast() {
    _dailyForecast = List.generate(7, (index) {
      final date = DateTime.now().add(Duration(days: index));
      return DailyForecastData(
        date: date,
        tempMax: 30.0 + index.toDouble(),
        tempMin: 20.0 + index.toDouble(),
        // Varying icons for visual effect
        iconCode: (index % 3 == 0)
            ? '01d'
            : (index % 3 == 1)
            ? '10d'
            : '04d',
      );
    });
  }

  // --- Main Fetch Function ---
  Future<void> fetchWeatherForCurrentLocation() async {
    _state = WeatherState.loading;
    notifyListeners();
    _errorMessage = null;

    try {
      // 1. Get location
      Position position = await _locationService.getCurrentLocation();
      double lat = position.latitude;
      double lon = position.longitude;

      // 2. Fetch data (assuming success)
      _currentWeather = await _weatherService.fetchCurrentWeather(lat, lon);
      _hourlyForecast = (await _weatherService.fetchWeatherForecast(
        lat,
        lon,
      )).take(8).toList();

      // 3. Populate mock daily data
      _mockDailyForecast();

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

  Future<void> fetchWeatherForCity(String cityName) async {
    _state = WeatherState.loading;
    notifyListeners();
    _errorMessage = null;

    try {
      final newWeather = await _weatherService.fetchCurrentWeatherByCity(
        cityName,
      );

      // NOTE: For a real app, you would fetch forecast using coordinates from newWeather.
      // For this step, we'll only update current weather and mock the forecast data.

      _currentWeather = newWeather;
      _mockDailyForecast(); // Call mock data to refresh daily list too

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
