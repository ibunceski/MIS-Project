import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, {bool isError = false}) {
  // Define colors and icons based on the message type
  final Color backgroundColor = isError ? Colors.red.shade600 : Colors.green.shade600;
  final IconData icon = isError ? Icons.error_outline : Icons.check_circle_outline;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white), // Add an icon
          const SizedBox(width: 12), // Add spacing between the icon and text
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor, // Custom background color
      behavior: SnackBarBehavior.floating, // Make the snackbar float
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      duration: const Duration(seconds: 3), // Adjust the duration
      margin: const EdgeInsets.all(16), // Add margin for floating behavior
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Add padding
    ),
  );
}