import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/issuer_data_provider.dart';

class LSTMAnalysisScreen extends StatelessWidget {
  const LSTMAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lstmData = Provider.of<IssuerDataProvider>(context).lstm;

    if (lstmData.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: Text(
            "There is not enough data for the LSTM Analysis to be done",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return LSTMAnalysisContent(data: lstmData);
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "LSTM Analysis",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }
}

class LSTMAnalysisContent extends StatefulWidget {
  final Map<String, dynamic> data;

  const LSTMAnalysisContent({super.key, required this.data});

  @override
  _LSTMAnalysisContentState createState() => _LSTMAnalysisContentState();
}

class _LSTMAnalysisContentState extends State<LSTMAnalysisContent> {
  late List<Map<String, dynamic>> graphData;
  late List<String> dailyPercent;
  late String signal;
  late List<double> yAxisDomain;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  void _processData() {
    final recentDates = (widget.data['recentDates'] as List).cast<String>();
    final actualPrices = (widget.data['actualPrices'] as List)
        .map((price) => price.toDouble())
        .toList();
    final predictedDates = (widget.data['dates'] as List).cast<String>();
    final predictedPrices = (widget.data['predictedPrices'] as List)
        .map((price) => price.toDouble())
        .toList();

    // Combine actual and predicted data
    final actualData = List.generate(recentDates.length, (index) {
      return {
        'date': DateTime.parse(recentDates[index]),
        'actual': actualPrices[index],
        'predicted': null,
      };
    });

    final predictedData = List.generate(predictedDates.length, (index) {
      return {
        'date': DateTime.parse(predictedDates[index]),
        'actual': null,
        'predicted': predictedPrices[index],
      };
    });

    graphData = [...actualData, ...predictedData];

    // Determine y-axis domain
    final prices = graphData
        .map((item) => item['actual'] ?? item['predicted'])
        .where((price) => price != null)
        .cast<double>()
        .toList();
    final minPrice =
        (prices.reduce((a, b) => a < b ? a : b) * 0.98).floorToDouble();
    final maxPrice =
        (prices.reduce((a, b) => a > b ? a : b) * 1.02).ceilToDouble();

    yAxisDomain = [minPrice, maxPrice];

    // Daily percent and signal
    dailyPercent = List<String>.from(widget.data['dailyPercent']);
    signal = widget.data['signal'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "LSTM Analysis",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSignalCard(),
              const SizedBox(height: 24),
              _buildLegend(),
              const SizedBox(height: 8),
              _buildChartSection(),
              const SizedBox(height: 24),
              _buildDailyPercentageSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalCard() {
    Color signalColor;
    IconData signalIcon;

    switch (signal.toLowerCase()) {
      case 'bullish':
        signalColor = Colors.green;
        signalIcon = Icons.trending_up;
        break;
      case 'bearish':
        signalColor = Colors.red;
        signalIcon = Icons.trending_down;
        break;
      default:
        signalColor = Colors.grey;
        signalIcon = Icons.trending_flat;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(signalIcon, color: signalColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Market Signal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    signal,
                    style: TextStyle(
                      fontSize: 20,
                      color: signalColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Actual Prices', Colors.blue),
        const SizedBox(width: 16),
        _buildLegendItem('Predicted Prices', Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyPercentageSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Percentage Changes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  dailyPercent.map((day) => _buildPercentageChip(day)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageChip(String day) {
    final percentage = double.tryParse(day
            .split('(')[1]
            .split(')')[0]
            .replaceAll('%', '')
            .replaceAll('+', '')) ??
        0.0;

    final isPositive = day.contains('+');
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        day,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
