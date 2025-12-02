import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:healthcare/features/doctor/application/utils/application_validators.dart'
    show ApplicationValidators;
import '../controllers/application_controller.dart';

class StepDocuments extends StatelessWidget {
  final ApplicationController controller;
  const StepDocuments({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => controller.pickFiles(),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                children: const [
                  Icon(Icons.upload_file),
                  SizedBox(width: 12),
                  Text('Pick Documents'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // picked files preview (local)
        if (controller.pickedFiles.isNotEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: controller.pickedFiles.map((pf) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(pf.name, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // uploaded (persisted) docs
        if (controller.data.uploadedDocuments.isNotEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uploaded Documents',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...controller.data.uploadedDocuments.asMap().entries.map((e) {
                    final idx = e.key;
                    final item = e.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['name'] ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                controller.removeUploadedDocument(idx),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed:
                  controller.pickedFiles.isNotEmpty && !controller.isLoading
                  ? () => controller.uploadPickedFiles(context)
                  : null,
              child: controller.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Upload Selected'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: controller.pickedFiles.isNotEmpty
                  ? () {
                      controller.pickedFiles.clear();
                      controller.notifyListeners();
                    }
                  : null,
              child: const Text('Clear Selected'),
            ),
          ],
        ),

        if (controller.showValidationErrors &&
            !ApplicationValidators.validateDocuments(
              controller.data.uploadedDocuments,
              pickedFiles: controller.pickedFiles,
            ))
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Please upload at least one document',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
