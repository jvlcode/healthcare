import 'package:flutter/material.dart';

class ApplicationStep4ReviewSubmitScreen extends StatelessWidget {
  // Sample data passed from previous steps
  final Map<String, dynamic> personalInfo;
  final Map<String, dynamic> clinicInfo;
  final List<String> uploadedFiles;

  const ApplicationStep4ReviewSubmitScreen({
    super.key,
    this.personalInfo = const {
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+91 9876543210',
    },
    this.clinicInfo = const {
      'clinicName': 'Care Health',
      'address': '123 Main Street',
      'specialization': 'Cardiology',
    },
    this.uploadedFiles = const ['certificate1.pdf', 'id_proof.png'],
  });

  @override
  Widget build(BuildContext context) {
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
                    Text("Name: ${personalInfo['name']}"),
                    Text("Email: ${personalInfo['email']}"),
                    Text("Phone: ${personalInfo['phone']}"),
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
                    Text("Clinic Name: ${clinicInfo['clinicName']}"),
                    Text("Address: ${clinicInfo['address']}"),
                    Text("Specialization: ${clinicInfo['specialization']}"),
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
                                    file,
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Application Submitted Successfully!"),
                      ),
                    );
                    // Navigator.pushNamed(context, '/doctor/apply/status');
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/doctor/apply/status',
                      (route) => false,
                    );
                  },
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
