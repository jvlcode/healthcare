import 'package:flutter/material.dart';
import 'package:healthcare/core/layout/app_header.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBEFEA), // light peach background

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'FAQ',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Frequently asked questions',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 25),

            // Question 1
            _faqItem('How do I reschedule?'),

            // Question 2
            _faqItem('What if I miss my session?'),

            // Question 3
            _faqItem('Promotional emails'),

            const SizedBox(height: 20),

            const Text(
              'If you miss your session, you can reschedule it through a pop of contact present for further assistance.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for each FAQ item
  Widget _faqItem(String question) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.black54,
          ),
          onTap: () {},
        ),
        const Divider(thickness: 0.8),
      ],
    );
  }
}

// Bottom navigation icon (for demo visual)
class _BottomIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  const _BottomIcon({
    required this.label,
    required this.icon,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? Colors.orangeAccent : Colors.white,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.orangeAccent : Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
