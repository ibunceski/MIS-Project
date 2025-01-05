import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class LSTMAnalysis extends StatefulWidget {
  final Map<String, dynamic> data;

  const LSTMAnalysis({Key? key, required this.data}) : super(key: key);

  @override
  State<LSTMAnalysis> createState() => _LSTMAnalysisState();
}

class _LSTMAnalysisState extends State<LSTMAnalysis> {
  List<FlSpot> actualSpots = [];
  List<FlSpot> predictedSpots = [];
  double minY = 0;
  double maxY = 0;
  List<String> dailyPercent = [];
  List<String> signal = [];

  @override
  void initState() {
    super.initState();
    processData();
  }

  void processData() {
    if (widget.data.isEmpty) return;

    final recentDates = List<DateTime>.from(
        widget.data['recentDates'].map((date) => DateTime.parse(date))
    );
    final actualPrices = List<double>.from(widget.data['actualPrices']);
    final dates = List<DateTime>.from(
        widget.data['dates'].map((date) => DateTime.parse(date))
    );
    final predictedPrices = List<double>.from(widget.data['predictedPrices']);

    actualSpots = List.generate(
        recentDates.length,
            (i) => FlSpot(recentDates[i].millisecondsSinceEpoch.toDouble(), actualPrices[i])
    );

    predictedSpots = List.generate(
        dates.length,
            (i) => FlSpot(dates[i].millisecondsSinceEpoch.toDouble(), predictedPrices[i])
    );

    final allPrices = [...actualPrices, ...predictedPrices];
    minY = allPrices.reduce(min) * 0.98;
    maxY = allPrices.reduce(max) * 1.02;

    dailyPercent = List<String>.from(widget.data['dailyPercent'] ?? []);
    signal = List<String>.from(widget.data['signal'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    if (actualSpots.isEmpty && predictedSpots.isEmpty) {
      return const Center(
        child: Text('There is not enough data for the LSTM Analysis to be done'),
      );
    }

    return Column(
      children: [
        const Text(
          'LSTM Analysis',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SignalHeader(signal: signal),
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: const SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Text(DateFormat('MM/dd/yy').format(date));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              minX: actualSpots.first.x,
              maxX: predictedSpots.last.x,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: actualSpots,
                  isCurved: true,
                  color: Colors.blue,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: predictedSpots,
                  isCurved: true,
                  color: Colors.green,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  // tooltipBgColor: Colors.white,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                      return LineTooltipItem(
                        '${DateFormat('MM/dd/yy').format(date)}\n${spot.y.toStringAsFixed(2)}',
                        TextStyle(color: spot.bar.color),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          children: dailyPercent.map((day) => Text(day)).toList(),
        ),
      ],
    );
  }
}

class SignalHeader extends StatelessWidget {
  final List<String> signal;

  const SignalHeader({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: signal.map((s) => Text(s)).toList(),
    );
  }
}