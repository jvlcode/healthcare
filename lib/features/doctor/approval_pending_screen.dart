import 'package:flutter/material.dart';

/* ------------------------
   4) Approval Pending Screen
   ------------------------ */
class ApprovalPendingScreen extends StatelessWidget {
  const ApprovalPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Pending')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.hourglass_top, size: 80, color: Color(0xFF01312F)),
            const SizedBox(height: 16),
            const Text(
              'Your documents are under review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'We will review your application and documents within 24-48 hours. You will be notified once your account is approved.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // In a real app, we would check status from backend. For demo, go to slots to simulate approval.
                Navigator.pushReplacementNamed(context, '/slots');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01312F),
              ),
              child: const Text('Simulate Approved — Go to Slots'),
            ),
          ],
        ),
      ),
    );
  }
}
