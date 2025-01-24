import 'package:domashni_proekt/providers/issuer_data_provider.dart';
import 'package:domashni_proekt/widgets/shared/signal_card.dart';
import 'package:domashni_proekt/widgets/technical/analysis_table.dart';
import 'package:domashni_proekt/widgets/technical/timeframe_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TechnicalAnalysisScreen extends StatelessWidget {
  const TechnicalAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final technicalData = Provider.of<IssuerDataProvider>(context).technical;

    if (technicalData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Technical Analysis"),
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
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "There is not enough data for the Technical Analysis",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return TechnicalAnalysisContent(data: technicalData);
  }
}

class TechnicalAnalysisContent extends StatefulWidget {
  final Map<String, dynamic> data;

  const TechnicalAnalysisContent({super.key, required this.data});

  @override
  State<TechnicalAnalysisContent> createState() =>
      _TechnicalAnalysisContentState();
}

class _TechnicalAnalysisContentState extends State<TechnicalAnalysisContent> {
  String timeframe = 'daily';

  String calculateOverallSignal(Map<String, dynamic> signals) {
    int buyCount = 0, sellCount = 0, holdCount = 0;

    signals.values.forEach((signal) {
      if (signal == 'Buy')
        buyCount++;
      else if (signal == 'Sell')
        sellCount++;
      else
        holdCount++;
    });

    if (buyCount > sellCount && buyCount > holdCount) return 'Buy';
    if (sellCount > buyCount && sellCount > holdCount) return 'Sell';
    return 'Hold';
  }

  Map<String, String> getMovingAverages(Map<String, dynamic> timeframeData) {
    return {
      'SMA 20': timeframeData['SMA_20_Signal'],
      'EMA 20': timeframeData['EMA_20_Signal'],
      'WMA 20': timeframeData['WMA_20_Signal'],
      'TRIX': timeframeData['TRIX_Signal'],
      'MACD': timeframeData['MACD_Signal'],
    };
  }

  Map<String, String> getOscillators(Map<String, dynamic> timeframeData) {
    return {
      'PPO': timeframeData['PPO_Signal'],
      'RSI': timeframeData['RSI_Signal'],
      'Stoch %K': timeframeData['Stoch_%K_Signal'],
      'Williams R': timeframeData['Williams_R_Signal'],
      'ROC': timeframeData['ROC_Signal'],
      'CCI': timeframeData['CCI_Signal'],
    };
  }

  @override
  Widget build(BuildContext context) {
    final timeframeData = widget.data[timeframe] as Map<String, dynamic>;
    final overallSignal = calculateOverallSignal(timeframeData);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Technical Analysis",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SignalCard(signal: overallSignal),
            const SizedBox(height: 24),
            TimeframeButtons(
              initialTimeframe: timeframe,
              onTimeframeChanged: (tf) => setState(() => timeframe = tf),
            ),
            const SizedBox(height: 24),
            AnalysisTable(
              title: 'Moving Averages',
              signals: getMovingAverages(timeframeData),
            ),
            const SizedBox(height: 24),
            AnalysisTable(
              title: 'Oscillators',
              signals: getOscillators(timeframeData),
            ),
          ],
        ),
      ),
    );
  }
}
