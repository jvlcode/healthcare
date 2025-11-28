import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/core/constants/urls.dart';
import 'package:healthcare/services/upload_service.dart';
import 'package:hive/hive.dart';

class ApplicationStep3DocumentUploadScreen extends StatefulWidget {
  const ApplicationStep3DocumentUploadScreen({super.key});

  @override
  State<ApplicationStep3DocumentUploadScreen> createState() =>
      _ApplicationStep3DocumentUploadScreenState();
}

class _ApplicationStep3DocumentUploadScreenState
    extends State<ApplicationStep3DocumentUploadScreen> {
  List<PlatformFile> selectedFiles = [];
  bool uploading = false;

  bool showValidationErrors = false; // 👈 SAME AS STEP-1 & STEP-2

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

  Future<void> _uploadAndSave() async {
    final box = Hive.box('doctor_application');

    setState(() => uploading = true);

    final uploadService = UploadService();
    final List<Map<String, String>> uploadedDocs = [];

    for (final file in selectedFiles) {
      final path = file.path;
      if (path == null || path.isEmpty) continue;

      try {
        final response = await uploadService.uploadDocument(File(path));
        final fileUrl = response['url'];
        if (fileUrl == null) continue;

        uploadedDocs.add({
          "name": file.name,
          "url": "${AppUrls.baseUrl}$fileUrl",
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload ${file.name}")),
          );
        }
      }
    }

    await box.put("step3Documents", uploadedDocs);

    if (mounted) setState(() => uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 3: Document Upload"),
        backgroundColor: const Color(0xFF01312F),
        elevation: 2,
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Upload your certificates & ID proof",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // FILE PICKER BUTTON
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: pickFiles,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.upload_file, color: Colors.black54),
                          SizedBox(width: 16),
                          Text(
                            "Pick Documents",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ❗ VALIDATION ERROR (same style as previous steps)
                if (showValidationErrors && !isFileSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 12, top: 6),
                    child: Text(
                      "Please upload at least one document",
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),

                const SizedBox(height: 20),

                // FILE LIST UI
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        file.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 15),
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

                // BACK + NEXT BUTTONS
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
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // ENABLE VALIDATION ONCE NEXT IS PRESSED
                          setState(() => showValidationErrors = true);

                          if (!isFileSelected) return;

                          await _uploadAndSave();
                          if (!mounted) return;

                          Navigator.pushNamed(
                            context,
                            AppRoutes.doctorApplyReview,
                          );
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // OVERLAY LOADER
          if (uploading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
