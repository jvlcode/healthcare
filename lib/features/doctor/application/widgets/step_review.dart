import 'package:flutter/material.dart';
import '../controllers/application_controller.dart';

class StepReview extends StatelessWidget {
  final ApplicationController controller;
  const StepReview({required this.controller, super.key});

  Widget _card(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = controller.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _card('Personal Information', [
          Text('Name: ${d.fullName}'),
          Text('Email: ${d.email}'),
          Text('Phone: ${d.phone}'),
          Text('Qualification: ${d.qualification}'),
          Text('Specialization: ${d.specialization}'),
          Text('Experience: ${d.experienceYears} years'),
        ]),
        const SizedBox(height: 12),
        _card('Clinic Information', [
          Text('Clinic: ${d.clinicName}'),
          Text('Address: ${d.clinicAddress}'),
        ]),
        if (d.uploadedDocuments.isNotEmpty) ...[
          const SizedBox(height: 12),
          _card(
            'Uploaded Documents',
            d.uploadedDocuments.map((doc) => Text(doc['name'] ?? '')).toList(),
          ),
        ],
        const SizedBox(height: 12),
        const Text('If everything looks good, press submit.'),
      ],
    );
  }
}
