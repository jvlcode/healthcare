import 'package:flutter/material.dart';

class DoctorApplicationWelcomeScreen extends StatelessWidget {
  const DoctorApplicationWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      appBar: AppBar(
        title: const Text(
          "Doctor Onboarding",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF01312F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/doctor_welcome.png',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Welcome, Doctor!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF01312F),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "We’re excited to have you onboard! To start offering consultations, please complete a short verification process. "
              "It includes filling out your profile, uploading certifications, and accepting the terms and conditions.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "You’ll go through the following steps:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF01312F),
              ),
            ),
            const SizedBox(height: 15),

            // Step list inside a Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    _StepItem(number: 1, text: "Personal & Clinic Information"),
                    _StepItem(number: 2, text: "Upload Certificates"),
                    _StepItem(
                      number: 3,
                      text: "Acknowledge Terms & Conditions",
                    ),
                    _StepItem(number: 4, text: "Review & Submit Application"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01312F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/doctor/apply/personal');
                  },
                  child: const Text(
                    "Start Application",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final String text;

  const _StepItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF01312F),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
