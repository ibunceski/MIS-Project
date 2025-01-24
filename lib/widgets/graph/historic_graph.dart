import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class PriceChart extends StatelessWidget {
  final List<Map<String, dynamic>> jsonData;

  const PriceChart({super.key, required this.jsonData});

  List<FlSpot> prepareChartData() {
    const maxPoints = 20;
    final step = (jsonData.length / maxPoints).ceil();
    final reversedData = jsonData.reversed.toList();

    List<FlSpot> result = List.generate(
      (reversedData.length / step).ceil(),
      (index) {
        final dataIndex = index * step;

        if (dataIndex >= reversedData.length) return null;

        final price = double.tryParse(
          reversedData[dataIndex]['avgPrice']
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        );
        return price != null ? FlSpot(dataIndex.toDouble(), price) : null;
      },
    ).whereType<FlSpot>().toList();

    if (reversedData.isNotEmpty) {
      final firstPrice = double.tryParse(
        reversedData.last['avgPrice'].replaceAll('.', '').replaceAll(',', '.'),
      );
      if (firstPrice != null) {
        final firstPoint =
            FlSpot((reversedData.length - 1).toDouble(), firstPrice);
        if (!result.contains(firstPoint)) {
          result.add(firstPoint);
        }
      }
    }

    result.sort((a, b) => a.x.compareTo(b.x));

    return result;
  }

  String formatThousands(double value) {
    return '${(value / 1000).toStringAsFixed(0)}k';
  }

  @override
  Widget build(BuildContext context) {
    final chartData = prepareChartData();
    if (chartData.isEmpty) {
      return const Center(child: Text('No data available for chart.'));
    }

    final prices = chartData.map((e) => e.y).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    final range = maxPrice - minPrice;
    final magnitude = (range / 5).floor().toString().length - 1;
    final base = pow(10, magnitude).toDouble();
    final yInterval = (range / 5 / base).ceil() * base;
    final xInterval = (jsonData.length / 6).ceil().toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 8, 20),
      child: SizedBox(
        height: 350,
        width: 400,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: chartData,
                isCurved: true,
                color: const Color(0xFF2196F3),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    return FlDotCirclePainter(
                      radius: 3,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF2196F3),
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) => SizedBox(
                    width: 40,
                    child: Text(
                      formatThousands(value),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: xInterval,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= jsonData.length) {
                      return const SizedBox.shrink();
                    }
                    final reversedIndex = jsonData.length - 1 - index;
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          jsonData[reversedIndex]['date'],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            minY: (minPrice / base).floor() * base,
            maxY: (maxPrice / base).ceil() * base + yInterval,
            backgroundColor: Colors.white,
            clipData: const FlClipData.all(),
          ),
        ),
      ),
    );
  }
}
