import 'package:flutter/material.dart';

class CardField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;

  const CardField({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboard,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            icon: icon == null ? null : Icon(icon),
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }
}
