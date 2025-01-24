import 'package:flutter/material.dart';

class TimeframeButtons extends StatefulWidget {
  final String initialTimeframe;
  final Function(String) onTimeframeChanged;

  const TimeframeButtons({
    super.key,
    required this.initialTimeframe,
    required this.onTimeframeChanged,
  });

  @override
  State<TimeframeButtons> createState() => _TimeframeButtonsState();
}

class _TimeframeButtonsState extends State<TimeframeButtons> {
  late String timeframe;

  @override
  void initState() {
    super.initState();
    timeframe = widget.initialTimeframe;
  }

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
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['daily', 'weekly', 'monthly'].map((tf) {
          final isSelected = timeframe == tf;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : [],
                ),
                child: TextButton(
                  onPressed: () {
                    setState(() => timeframe = tf);
                    widget.onTimeframeChanged(tf);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: isSelected ? Colors.black : Colors.grey,
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
            ),
          );
        }).toList(),
      ),
    );
  }
}