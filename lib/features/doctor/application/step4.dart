import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/services/doctor_service.dart';
import 'package:hive/hive.dart';

class ApplicationStep4ReviewSubmitScreen extends StatelessWidget {
  const ApplicationStep4ReviewSubmitScreen({super.key});

  Future<void> _submitApplication(BuildContext context) async {
    final box = Hive.box('doctor_application');

    try {
      final doctorService = DoctorService();
      final personalInfo =
          box.get('step1PersonalInfo') as Map<String, dynamic>? ?? {};
      final clinicInfo =
          box.get('step2ClinicInfo') as Map<String, dynamic>? ?? {};
      final uploadedFiles = (box.get('step3Documents') as List<dynamic>? ?? [])
          .cast<Map<String, String>>();

      // Call API
      final result = await doctorService.submitApplication(
        personalInfo: personalInfo,
        clinicInfo: clinicInfo,
        documents: uploadedFiles,
      );

      if (result['success'] == true) {
        final data = result['data'];

        /// 1️⃣ Set approval flag FALSE (very important)
        await SessionManager.setDoctorApproved(false);

        /// 2️⃣ Store doctor data inside user session
        try {
          final updatedDoctor = Doctor.fromJson(data['doctor']);
          final currentUser = await SessionManager.getCurrentUser();
          if (currentUser != null) {
            final updatedUser = currentUser.copyWith(doctor: updatedDoctor);
            await SessionManager.updateUser(updatedUser);
          }
        } catch (e, stack) {
          print("Error updating user $e");
          print(stack);
        }

        /// 3️⃣ Clear all saved application form data
        await box.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application Submitted Successfully!")),
        );

        /// 4️⃣ Redirect to doctor home
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.doctorHome,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Submission failed: ${result['message'] ?? 'Unknown error'}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting application: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('doctor_application');
    final personalInfo =
        box.get('step1PersonalInfo') as Map<String, dynamic>? ?? {};
    final clinicInfo =
        box.get('step2ClinicInfo') as Map<String, dynamic>? ?? {};
    final uploadedFiles = (box.get('step3Documents') as List<dynamic>? ?? [])
        .cast<Map<String, String>>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 4: Review & Submit"),
        backgroundColor: const Color(0xFF01312F),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Review your information before submitting the application.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Personal Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Name: ${personalInfo['fullName'] ?? ''}"),
                    Text("Email: ${personalInfo['email'] ?? ''}"),
                    Text("Phone: ${personalInfo['phone'] ?? ''}"),
                  ],
                ),
              ),
            ),

            // Clinic Info Card
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Clinic Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Clinic Name: ${clinicInfo['clinicName'] ?? ''}"),
                    Text("Address: ${clinicInfo['clinicAddress'] ?? ''}"),
                    Text(
                      "Specialization: ${clinicInfo['specialization'] ?? ''}",
                    ),
                  ],
                ),
              ),
            ),

            // Uploaded Files Card
            if (uploadedFiles.isNotEmpty) ...[
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Uploaded Documents",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...uploadedFiles.map(
                        (file) => Row(
                          children: [
                            const Icon(Icons.insert_drive_file),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                file['name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
            // Back & Submit buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back", style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01312F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _submitApplication(context),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
