import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSection extends StatelessWidget {
  final List<Map<String, dynamic>> graphData;
  final List<double> yAxisDomain;

  const LineChartSection({
    super.key,
    required this.graphData,
    required this.yAxisDomain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: LineChart(_buildLineChart()),
        ),
      ),
    );
  }

  LineChartData _buildLineChart() {
    final firstDate = graphData.first['date'] as DateTime;
    final lastDate = graphData.last['date'] as DateTime;
    final daysDifference = lastDate.difference(firstDate).inDays;
    final interval =
    Duration(days: (daysDifference / 5).ceil()).inMilliseconds.toDouble();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.1),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (yAxisDomain[1] - yAxisDomain[0]) / 4,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10),
              );
            },
            reservedSize: 28,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            getTitlesWidget: (value, meta) {
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Text(
                "${date.day}/${date.month}",
                style: const TextStyle(fontSize: 10),
              );
            },
            reservedSize: 22,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: graphData.first['date'].millisecondsSinceEpoch.toDouble(),
      maxX: graphData.last['date'].millisecondsSinceEpoch.toDouble(),
      minY: yAxisDomain[0],
      maxY: yAxisDomain[1],
      lineBarsData: [
        LineChartBarData(
          spots: graphData
              .where((item) => item['actual'] != null)
              .map((item) => FlSpot(
              item['date'].millisecondsSinceEpoch.toDouble(),
              item['actual']))
              .toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: graphData
              .where((item) => item['predicted'] != null)
              .map((item) => FlSpot(
            item['date'].millisecondsSinceEpoch.toDouble(),
            double.parse(item['predicted'].toStringAsFixed(1)),
          ))
              .toList(),
          isCurved: true,
          color: Colors.green,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }
}