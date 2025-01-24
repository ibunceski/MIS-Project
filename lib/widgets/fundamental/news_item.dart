import 'package:flutter/material.dart';

class NewsItem extends StatelessWidget {
  final String label;
  final double score;
  final String text;

  const NewsItem({
    super.key,
    required this.label,
    required this.score,
    required this.text,
  });

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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.blue.shade200),
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}