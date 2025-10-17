import 'package:flutter/material.dart';

class TimeBox extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimeBox({
    super.key,
    required this.time,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFFFFE0D1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF01312F)
                : const Color(0xFFFF6B35),
            width: 1.5,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF01312F),
          ),
        ),
      ),
    );
  }
}
