import 'package:flutter/material.dart';
import 'package:healthcare/features/doctor/application/utils/application_validators.dart';
import '../controllers/application_controller.dart';
import 'form_fields.dart';

class StepClinic extends StatelessWidget {
  final ApplicationController controller;
  const StepClinic({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        CardField(
          controller: controller.clinicNameCtrl,
          label: 'Clinic Name',
          icon: Icons.local_hospital,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter clinic name' : null,
        ),
        const SizedBox(height: 12),
        CardField(
          controller: controller.clinicAddressCtrl,
          label: 'Clinic Address',
          icon: Icons.location_on,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter clinic address' : null,
        ),
        if (controller.showValidationErrors &&
            !ApplicationValidators.validateClinic(
              clinicName: controller.data.clinicName,
              clinicAddress: controller.data.clinicAddress,
            ))
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Please complete required fields',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
