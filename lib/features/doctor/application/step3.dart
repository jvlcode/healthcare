import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ApplicationStep3DocumentUploadScreen extends StatefulWidget {
  const ApplicationStep3DocumentUploadScreen({super.key});

  @override
  State<ApplicationStep3DocumentUploadScreen> createState() =>
      _ApplicationStep3DocumentUploadScreenState();
}

class _ApplicationStep3DocumentUploadScreenState
    extends State<ApplicationStep3DocumentUploadScreen> {
  List<PlatformFile> selectedFiles = [];

  bool get isFileSelected => selectedFiles.isNotEmpty;

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 3: Upload Certificates"),
        backgroundColor: const Color(0xFF01312F),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Please upload your medical certificates and ID proof.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Upload button
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text(
                "Upload Certificate",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01312F),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: pickFiles,
            ),
            const SizedBox(height: 20),

            // Display selected files
            if (selectedFiles.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selectedFiles
                        .map(
                          (file) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    file.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            const SizedBox(height: 40),

            // Back & Next buttons
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
                if (isFileSelected)
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
                      Navigator.pushNamed(context, '/doctor/apply/review');
                    },
                    child: const Text(
                      "Next",
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
