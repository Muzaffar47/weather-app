import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/forecast_data.dart';

class HourlyChart extends StatefulWidget {
  final List<ForecastData> forecast;
  const HourlyChart({super.key, required this.forecast});

  @override
  State<HourlyChart> createState() => _HourlyChartState();
}

class _HourlyChartState extends State<HourlyChart> {
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _touchedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forecast.isEmpty) {
      return const Center(
        child: Text(
          "No forecast data available.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final spots = widget.forecast.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.temperature.roundToDouble(),
      );
    }).toList();

    final temperatures = spots.map((spot) => spot.y).toList();
    final double minTemp = (temperatures.reduce((a, b) => a < b ? a : b) - 2)
        .floorToDouble();
    final double maxTemp = (temperatures.reduce((a, b) => a > b ? a : b) + 2)
        .ceilToDouble();

    // Chart width calculation (relies on Home Screen padding: 30.0 * 2)
    final double chartWidth = MediaQuery.of(context).size.width - (30.0 * 2);
    // Inner chart area width (chart width - reserved Y-axis space - right padding)
    final double innerChartAreaWidth = chartWidth - 30 - 10;

    // Logic to check if the touch index is near the end of the list
    final bool isNearRightEdge =
        _touchedIndex != null && _touchedIndex! >= (spots.length - 2);

    return Stack(
      children: [
        Container(
          height: 200,
          // Final padding adjustment
          padding: const EdgeInsets.fromLTRB(10, 20, 20, 2.5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (event is FlTapDownEvent || event is FlPanEndEvent) {
                        setState(() {
                          if (touchResponse?.lineBarSpots != null &&
                              touchResponse!.lineBarSpots!.isNotEmpty) {
                            _touchedIndex =
                                touchResponse.lineBarSpots!.first.spotIndex;
                          }
                        });
                      }
                    },
              ),

              minX: 0,
              maxX: (widget.forecast.length - 1).toDouble(),
              minY: minTemp,
              maxY: maxTemp,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),

              extraLinesData: ExtraLinesData(
                verticalLines:
                    (_touchedIndex != null && _touchedIndex! < spots.length)
                    ? [
                        VerticalLine(
                          x: spots[_touchedIndex!].x,
                          color: Colors.white,
                          strokeWidth: 1,
                          dashArray: const [5, 5],
                        ),
                      ]
                    : [],
              ),

              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false, reservedSize: 15),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < 0 ||
                          value.toInt() >= widget.forecast.length) {
                        return const SizedBox.shrink();
                      }
                      final dateTime = widget.forecast[value.toInt()].dateTime;
                      final formattedTime = DateFormat('j').format(dateTime);
                      return Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 5,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        '${value.toInt()}°',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: (index == _touchedIndex) ? 6 : 3,
                        color: (index == _touchedIndex)
                            ? Colors.white
                            : Colors.blueAccent.withOpacity(0.5),
                        strokeWidth: (index == _touchedIndex) ? 2 : 1,
                        strokeColor: Colors.blueAccent,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- Custom Persistent Tooltip Overlay (FIX: Conditional Offset) ---
        if (_touchedIndex != null && _touchedIndex! < spots.length)
          Positioned(
            left:
                (spots[_touchedIndex!].x / (widget.forecast.length - 1)) *
                    innerChartAreaWidth +
                30,
            top:
                (spots[_touchedIndex!].y - minTemp) / (maxTemp - minTemp) * 160,
            child: Transform.translate(
              // CONDITIONAL OFFSET: If near the end, shift left by -45
              offset: Offset(
                isNearRightEdge ? -45 : 0,
                -35 -
                    ((spots[_touchedIndex!].y - minTemp) /
                                (maxTemp - minTemp) *
                                160 >
                            100
                        ? 0
                        : 20),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  '${spots[_touchedIndex!].y.toInt()}°',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
