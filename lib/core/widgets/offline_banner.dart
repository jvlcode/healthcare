import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      padding: const EdgeInsets.all(8),
      child: const Text(
        "⚠️ Server unreachable. You're in offline mode.",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
