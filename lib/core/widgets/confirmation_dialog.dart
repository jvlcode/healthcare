import 'package:flutter/material.dart';

/// Shows a confirmation dialog with title, message, and customizable buttons.
/// Returns true if user confirms, false if canceled.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  String title = 'Confirm',
  String message = 'Are you sure?',
  String confirmText = 'Yes',
  String cancelText = 'No',
  Color confirmColor = Colors.red,
  Color cancelColor = Colors.grey,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: cancelColor),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          child: Text(confirmText),
        ),
      ],
    ),
  );

  return result ?? false; // default to false if dismissed
}
