import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/issuer_data_provider.dart';

class FundamentalAnalysisScreen extends StatelessWidget {
  const FundamentalAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nlpData = Provider.of<IssuerDataProvider>(context).nlp;
    if (nlpData.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No Recent News Available",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Fundamental analysis requires news data\nfrom the past 20 days",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final labels =
        nlpData.map((item) => item['signal']['label'] as String).toList();
    final signal = _findMajorityElement(labels).join("/");

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          "Fundamental Analysis",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignalHeader(signal: signal),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Recent News Analysis",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: nlpData.length,
              itemBuilder: (context, index) {
                final item = nlpData[index];
                return NewsItem(
                  label: item['signal']['label'] as String,
                  score: item['signal']['score'] as double,
                  text: item['text'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _findMajorityElement(List<String> array) {
    final countMap = <String, int>{};
    for (var label in array) {
      countMap[label] = (countMap[label] ?? 0) + 1;
    }

    int maxCount = 0;
    final majorityElements = <String>[];

    countMap.forEach((label, count) {
      if (count > maxCount) {
        maxCount = count;
        majorityElements.clear();
        majorityElements.add(label);
      } else if (count == maxCount) {
        majorityElements.add(label);
      }
    });

    return majorityElements;
  }
}

class SignalHeader extends StatelessWidget {
  final String signal;

  const SignalHeader({Key? key, required this.signal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overall Market Signal",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            signal.toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class NewsItem extends StatelessWidget {
  final String label;
  final double score;
  final String text;

  const NewsItem({
    Key? key,
    required this.label,
    required this.score,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;
    Color backgroundColor;

    switch (label) {
      case 'positive':
        iconData = Icons.trending_up_rounded;
        color = Colors.green.shade700;
        backgroundColor = Colors.green.shade50;
        break;
      case 'negative':
        iconData = Icons.trending_down_rounded;
        color = Colors.red.shade700;
        backgroundColor = Colors.red.shade50;
        break;
      default:
        iconData = Icons.remove_rounded;
        color = Colors.blue.shade700;
        backgroundColor = Colors.blue.shade50;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Confidence: ${(score * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
