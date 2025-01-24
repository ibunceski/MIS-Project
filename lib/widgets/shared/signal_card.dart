import 'package:flutter/material.dart';

class SignalCard extends StatelessWidget {
  final String signal;

  const SignalCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    Color signalColor;
    IconData signalIcon;
    Color gradientStartColor;
    Color gradientEndColor;

    switch (signal.toLowerCase()) {
      case 'buy':
        signalColor = Colors.green;
        signalIcon = Icons.trending_up;
        gradientStartColor = Colors.green.shade50;
        gradientEndColor = Colors.green.shade100;
        break;
      case 'sell':
        signalColor = Colors.red;
        signalIcon = Icons.trending_down;
        gradientStartColor = Colors.red.shade50;
        gradientEndColor = Colors.red.shade100;
        break;
      default:
        signalColor = Colors.orange;
        signalIcon = Icons.trending_flat;
        gradientStartColor = Colors.orange.shade50;
        gradientEndColor = Colors.orange.shade100;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStartColor, gradientEndColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16), // Slightly larger radius
        boxShadow: [
          BoxShadow(
            color: gradientEndColor.withOpacity(0.5),
            blurRadius: 15, // Increased blur for a softer shadow
            offset: const Offset(0, 6), // Slightly larger offset
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: signalColor.withOpacity(0.1), // Subtle icon background
              shape: BoxShape.circle,
            ),
            child: Icon(
              signalIcon,
              color: signalColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Signal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: signalColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  signal.toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: signalColor,
                    letterSpacing: 1.2, // Added letter spacing for emphasis
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}