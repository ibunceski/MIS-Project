import 'package:domashni_proekt/providers/issuer_data_provider.dart';
import 'package:domashni_proekt/widgets/fundamental/news_item.dart';
import 'package:domashni_proekt/widgets/shared/signal_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FundamentalAnalysisScreen extends StatelessWidget {
  const FundamentalAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nlpData = Provider.of<IssuerDataProvider>(context).nlp;

    if (nlpData.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildNoDataContent(),
      );
    }

    return FundamentalAnalysisContent(nlpData: nlpData);
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: const Text(
        'Fundamental Analysis',
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
    );
  }

  Widget _buildNoDataContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.blue.shade400),
            const SizedBox(height: 16),
            Text(
              "No Recent News Available",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Fundamental analysis requires news data\nfrom the past 20 days",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FundamentalAnalysisContent extends StatelessWidget {
  final List<dynamic> nlpData;

  const FundamentalAnalysisContent({super.key, required this.nlpData});

  @override
  Widget build(BuildContext context) {
    final labels = nlpData.map((item) => item['signal']['label'] as String).toList();
    final signal = _findMajorityElement(labels).join("/");

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Fundamental Analysis",
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SignalCard(signal: signal),
              const SizedBox(height: 24),
              Text(
                "Recent News Analysis",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
            ],
          ),
        ),
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