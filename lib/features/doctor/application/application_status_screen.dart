import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/services/doctor_service.dart';

class ApplicationStatusScreen extends StatelessWidget {
  const ApplicationStatusScreen({super.key});

  Future<void> _approveDoctor(BuildContext context) async {
    try {
      // Get doctorId from session manager
      final doctorId = await SessionManager.getDoctorId();

      if (doctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor ID not found in session')),
        );
        return;
      }

      // Call backend API
      final res = await DoctorService().approveDoctor(doctorId);

      if (res['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Doctor approved')));
        Navigator.pushReplacementNamed(context, AppRoutes.doctorHome);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to approve doctor')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.hourglass_top,
                size: 100,
                color: Color(0xFF01312F),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your documents are under review',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We will review your application and documents within 24-48 hours. You will be notified once your account is approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _approveDoctor(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01312F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Approve Doctor',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
