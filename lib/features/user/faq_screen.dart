import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> faqData = const [
    {
      'question': 'How do I reschedule?',
      'answer':
          'You can reschedule your session by going to your appointments and selecting "Reschedule".',
    },
    {
      'question': 'What if I miss my session?',
      'answer':
          'If you miss your session, you can reschedule it through the contact support option for assistance.',
    },
    {
      'question': 'Promotional emails',
      'answer':
          'You can manage promotional emails in your account settings under Notifications.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBEFEA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text(
              'FAQ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Frequently asked questions',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 25),

            // FAQ Cards
            ...faqData.map((item) => _faqItem(item)).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(Map<String, String> item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        title: Text(
          item['question']!,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['answer']!,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: Colors.orangeAccent,
        collapsedIconColor: Colors.black54,
      ),
    );
  }
}
