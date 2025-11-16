import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/models/doctor_application_form_model.dart';
import 'package:healthcare/services/doctor_service.dart';
import 'package:hive/hive.dart';

class ApplicationStep4ReviewSubmitScreen extends StatelessWidget {
  const ApplicationStep4ReviewSubmitScreen({super.key});

  Future<void> _submitApplication(BuildContext context) async {
    final box = Hive.box('doctor_application');
    final form = box.get('draft');

    if (form == null) {
      // print(form?.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No application to submit.")),
      );
      return;
    }

    try {
      final doctorService = DoctorService();

      // Submit application using the service
      final result = await doctorService.submitApplication(
        personalInfo: form.step1PersonalInfo ?? {},
        clinicInfo: form.step2ClinicInfo ?? {},
        documents: form.step3Documents ?? [],
      );

      print("FORM $result");

      if (result['success'] == true) {
        form.isSubmitted = true;
        await form.save();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application Submitted Successfully!")),
        );

        // Redirect to application status screen
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
    final box = Hive.box<DoctorApplicationForm>('doctor_application');
    final form = box.get('draft');
    final personalInfo = form?.step1PersonalInfo ?? {};
    final clinicInfo = form?.step2ClinicInfo ?? {};
    final uploadedFiles = form?.step3Documents ?? [];

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
            const SizedBox(height: 20),

            // Clinic Info Card
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
            const SizedBox(height: 20),

            // Uploaded Files Card
            if (uploadedFiles.isNotEmpty)
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
                      ...uploadedFiles
                          .map(
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
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
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
