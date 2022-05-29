import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpotsChart extends StatelessWidget {

  const SpotsChart({
    Key? key,
    required this.currency,
    required this.listSpots,
  }) : super(key: key);

  final String currency;
  final List<FlSpot> listSpots;

  final List<Color> gradientColors = const [
    Color(0xffe68823),
    Color(0xffe68823),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: Colors.white.withOpacity(0.1),
                  strokeWidth: 2,
                  dashArray: [3, 3],
                ),
                FlDotData(show: false),
              );
            }).toList();
          },
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipBgColor: const Color(0xff2e3747).withOpacity(0.75),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y} $currency \n' +
                      DateFormat("yMd").format(DateTime.fromMillisecondsSinceEpoch((touchedSpot.x*1000).toInt())),
                  const TextStyle(color: Colors.white, fontSize: 12.0),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: listSpots,
            isCurved: false,
            colors: gradientColors,
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
                show: true,
                gradientFrom: const Offset(0, 0),
                gradientTo: const Offset(0, 1),
                colors: [
                  const Color(0xffe68823).withOpacity(0.18),
                  const Color(0xffe68823).withOpacity(0),
                ]),
          )
        ],
      ),
      swapAnimationCurve: Curves.easeInOut,
      swapAnimationDuration: const Duration(
        milliseconds: 800
      ),
    );
  }
}