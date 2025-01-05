import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/issuer_data_provider.dart';

class TechnicalAnalysisScreen extends StatelessWidget {
  const TechnicalAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final technicalData = Provider.of<IssuerDataProvider>(context).technical;

    if (technicalData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Technical Analysis")),
        body: const Center(
          child: Text(
            "There is not enough data for the Technical Analysis",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
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
        title: const Text('Technical Analysis'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSignalCard(overallSignal),
            const SizedBox(height: 24),
            _buildTimeframeButtons(),
            const SizedBox(height: 24),
            _buildAnalysisTables(timeframeData),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalCard(String signal) {
    Color signalColor;
    IconData signalIcon;

    switch (signal.toLowerCase()) {
      case 'buy':
        signalColor = Colors.green;
        signalIcon = Icons.trending_up;
        break;
      case 'sell':
        signalColor = Colors.red;
        signalIcon = Icons.trending_down;
        break;
      default:
        signalColor = Colors.orange;
        signalIcon = Icons.trending_flat;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    'Overall Signal',
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

  Widget _buildTimeframeButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['daily', 'weekly', 'monthly'].map((tf) {
          final isSelected = timeframe == tf;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ElevatedButton(
                onPressed: () => setState(() => timeframe = tf),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelected ? Colors.white : Colors.transparent,
                  foregroundColor: isSelected ? Colors.black : Colors.grey,
                  elevation: isSelected ? 1 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  tf[0].toUpperCase() + tf.substring(1),
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnalysisTables(Map<String, dynamic> timeframeData) {
    return Column(
      children: [
        _buildTableSection(
          'Moving Averages',
          getMovingAverages(timeframeData),
        ),
        const SizedBox(height: 24),
        _buildTableSection(
          'Oscillators',
          getOscillators(timeframeData),
        ),
      ],
    );
  }

  Widget _buildTableSection(String title, Map<String, String> signals) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(0.8),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Indicator',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Signal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                ...signals.entries.map((entry) {
                  Color signalColor;
                  switch (entry.value.toLowerCase()) {
                    case 'buy':
                      signalColor = Colors.green;
                      break;
                    case 'sell':
                      signalColor = Colors.red;
                      break;
                    default:
                      signalColor = Colors.orange;
                  }

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(entry.key),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: signalColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
