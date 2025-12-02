import 'package:flutter/material.dart';
import 'package:healthcare/features/doctor/application/utils/application_validators.dart';
import '../controllers/application_controller.dart';
import 'form_fields.dart';

class StepPersonal extends StatelessWidget {
  final ApplicationController controller;
  const StepPersonal({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        CardField(
          controller: controller.fullNameCtrl,
          label: 'Full Name',
          icon: Icons.person,
          hint: 'John Doe',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Please enter name' : null,
        ),
        const SizedBox(height: 12),
        CardField(
          controller: controller.emailCtrl,
          label: 'Email',
          icon: Icons.email,
          keyboard: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter email';
            final ok = RegExp(
              r"^[a-zA-Z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$",
            ).hasMatch(v.trim());
            return ok ? null : 'Enter valid email';
          },
        ),
        const SizedBox(height: 12),
        CardField(
          controller: controller.phoneCtrl,
          label: 'Phone',
          icon: Icons.phone,
          keyboard: TextInputType.phone,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter phone';
            if (!RegExp(r"^[0-9]{10,}$").hasMatch(v.trim()))
              return 'Enter valid phone';
            return null;
          },
        ),
        const SizedBox(height: 12),
        CardField(
          controller: controller.qualificationCtrl,
          label: 'Qualification',
          icon: Icons.school,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter qualification' : null,
        ),
        const SizedBox(height: 12),
        CardField(
          controller: controller.specializationCtrl,
          label: 'Specialization',
          icon: Icons.medical_services,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter specialization' : null,
        ),
        const SizedBox(height: 12),
        CardField(
          controller: controller.experienceCtrl,
          label: 'Years of Experience',
          icon: Icons.timeline,
          keyboard: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter experience';
            if (int.tryParse(v.trim()) == null) return 'Must be number';
            return null;
          },
        ),
        if (controller.showValidationErrors &&
            !ApplicationValidators.validatePersonal(
              fullName: controller.data.fullName,
              email: controller.data.email,
              phone: controller.data.phone,
              qualification: controller.data.qualification,
              specialization: controller.data.specialization,
              experience: controller.data.experienceYears,
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
