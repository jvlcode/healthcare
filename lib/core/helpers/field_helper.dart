import 'package:flutter/material.dart';
import 'package:healthcare/core/constants/colors.dart';

InputDecoration fieldDecoration(
  BuildContext context,
  String label,
  IconData icon,
) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    // 👇 Add this to control label color when focused
    floatingLabelStyle: const TextStyle(
      color: AppColors.accent, // or any contrasting color
      fontSize: 15,
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.secondary,
        width: 1.5,
      ),
    ),
    // 👇 Control error text style here
    errorStyle: const TextStyle(
      color: AppColors.accent, // change to any color you want
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    // 👇 Control error border color here
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accent),
    ),
  );
}
