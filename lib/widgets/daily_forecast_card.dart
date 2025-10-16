import 'package:flutter/material.dart';
import '../models/daily_forecast_data.dart';
import '../utils/icon_mapper.dart';

class DailyForecastCard extends StatelessWidget {
  final List<DailyForecastData> forecast;

  const DailyForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      // very small vertical padding so content sits tight
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      // Uncomment the next line to see debug border:
      // decoration: BoxDecoration(border: Border.all(color: Colors.redAccent)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "7-Day Forecast",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // very small spacer
          const SizedBox(height: 2),

          // Header row (no extra container height)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                flex: 3,
                child: Text(
                  'Day',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'Weather',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Min',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Max',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          // Divider with zero extra vertical spacing
          const Divider(color: Colors.white24, height: 0, thickness: 0.5),

          // Replace ListView.builder with Column to avoid ListView's internal padding/behavior
          Column(
            // Generate a compact row for each forecast item
            children: forecast
                .map((day) {
                  final index = forecast.indexOf(day);
                  return Container(
                    height: 36, // compact controlled height
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            index == 0 ? "Today" : day.dayOfWeek,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              getWeatherIcon(day.iconCode),
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            '${day.tempMin.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white54,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            '${day.tempMax.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
