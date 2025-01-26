import 'package:domashni_proekt/providers/issuer_data_provider.dart';
import 'package:domashni_proekt/widgets/graph/line_chart.dart';
import 'package:domashni_proekt/widgets/lstm/legend_item.dart';
import 'package:domashni_proekt/widgets/lstm/percentage_chip.dart';
import 'package:domashni_proekt/widgets/shared/signal_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SignalCard(signal: signal),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LegendItem(label: 'Actual Prices', color: Colors.blue),
                  SizedBox(width: 16),
                  LegendItem(label: 'Predicted Prices', color: Colors.green),
                ],
              ),
              const SizedBox(height: 8),
              LineChartSection(graphData: graphData, yAxisDomain: yAxisDomain),
              const SizedBox(height: 24),
              Card(
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
                        children: dailyPercent
                            .map((day) => PercentageChip(day: day))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
