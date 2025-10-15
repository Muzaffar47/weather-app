import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart'; // REQUIRED for time formatting
import '../providers/weather_provider.dart';
import '../utils/app_theme.dart';
import '../utils/icon_mapper.dart';
import '../widgets/hourly_chart.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/glass_card.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).fetchWeatherForCurrentLocation();
    });
  }

  // Helper function to build each info row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.white54),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        switch (weatherProvider.state) {
          case WeatherState.loading:
          case WeatherState.initial:
            return const Scaffold(
              body: Center(child: Text("Fetching weather data...")),
            );
          case WeatherState.error:
            return Scaffold(
              body: Center(
                child: Text(
                  "Error fetching data: ${weatherProvider.errorMessage}",
                ),
              ),
            );

          case WeatherState.loaded:
            final weather = weatherProvider.currentWeather!;
            final forecast = weatherProvider.hourlyForecast;
            final dailyForecast = weatherProvider.dailyForecast;

            final formattedTime = DateFormat('h:mm a').format(weather.date);
            final isSunny = weather.iconCode.startsWith('01d');
            final glareColor = isSunny ? Colors.yellow : Colors.white;

            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(
                  weather.cityName,
                  // FIX: Explicitly set city text color to white
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  // Icons are explicitly set to white
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () =>
                        weatherProvider.fetchWeatherForCurrentLocation(),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.location_city_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                ],
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),

              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: getWeatherGradient(weather.iconCode),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    30.0,
                    MediaQuery.of(context).padding.top + 60,
                    30.0,
                    20.0,
                  ),
                  children: [
                    // --- 1. Dynamic Weather Icon with Glare/Aura ---
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: glareColor.withOpacity(
                                isSunny ? 0.8 : 0.4,
                              ),
                              blurRadius: isSunny ? 35 : 15,
                              spreadRadius: isSunny ? 5 : 2,
                            ),
                          ],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          getWeatherIcon(weather.iconCode),
                          color: glareColor,
                          size: 150,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- 2. Current Temperature and Description ---
                    Center(
                      child: Text(
                        '${weather.temperature.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        weather.description.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- 3. Additional Info (New Position - GlassCard) ---
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            WeatherIcons.humidity,
                            "Humidity",
                            "${weather.humidity}%",
                          ),

                          // Wind Speed & Direction (Rotated Icon)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Transform.rotate(
                                      angle:
                                          (weather.windDegrees *
                                          (3.141592653589793 / 180.0)),
                                      child: const Icon(
                                        WeatherIcons.direction_up,
                                        size: 20,
                                        color: Colors.white54,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Wind",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${weather.windSpeed.toStringAsFixed(1)} m/s",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Atmospheric Pressure
                          _buildInfoRow(
                            WeatherIcons.barometer,
                            "Pressure",
                            "${weather.pressure} hPa",
                          ),

                          // Last Updated Time (AM/PM)
                          _buildInfoRow(
                            Icons.access_time,
                            "Last Updated",
                            formattedTime,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 4. Hourly Forecast Chart ---
                    const Text(
                      "Hourly Temperature",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    HourlyChart(forecast: forecast),

                    const SizedBox(height: 30),

                    // --- 5. Daily Forecast Card ---
                    DailyForecastCard(forecast: dailyForecast),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );

          default:
            return const Scaffold(body: Center(child: Text("Initializing...")));
        }
      },
    );
  }
}
