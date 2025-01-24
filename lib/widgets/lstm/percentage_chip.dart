import 'package:flutter/material.dart';

class PercentageChip extends StatelessWidget {
  final String day;

  const PercentageChip({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
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
}