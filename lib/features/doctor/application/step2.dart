import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:hive/hive.dart';

class ApplicationStep2ClinicDetailsScreen extends StatefulWidget {
  const ApplicationStep2ClinicDetailsScreen({super.key});

  @override
  State<ApplicationStep2ClinicDetailsScreen> createState() =>
      _ApplicationStep2ClinicDetailsScreenState();
}

class _ApplicationStep2ClinicDetailsScreenState
    extends State<ApplicationStep2ClinicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  String clinicName = '';
  String clinicAddress = '';

  bool showValidationErrors = false; // 👈 SAME PATTERN AS STEP-1

  @override
  void initState() {
    super.initState();
    _loadFromHive();
  }

  // Load saved draft data
  void _loadFromHive() {
    final box = Hive.box('doctor_application');
    final info = box.get('step2ClinicInfo') as Map<dynamic, dynamic>?;

    if (info != null) {
      clinicName = info['clinicName'] ?? '';
      clinicAddress = info['clinicAddress'] ?? '';
    }
  }

  bool get isFormFilled => clinicName.isNotEmpty && clinicAddress.isNotEmpty;

  // Save nested draft object (same as Step-1)
  Future<void> _saveToHive() async {
    final box = Hive.box('doctor_application');

    await box.put('step2ClinicInfo', {
      "clinicName": clinicName,
      "clinicAddress": clinicAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 2: Clinic Details"),
        backgroundColor: const Color(0xFF01312F),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: showValidationErrors
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              const Text(
                "Please provide your clinic details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // ---------------------- CLINIC NAME ----------------------
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    initialValue: clinicName,
                    decoration: const InputDecoration(
                      labelText: "Clinic Name",
                      icon: Icon(Icons.local_hospital),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => setState(() => clinicName = val),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter clinic name" : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------------- CLINIC ADDRESS ----------------------
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    initialValue: clinicAddress,
                    decoration: const InputDecoration(
                      labelText: "Clinic Address",
                      icon: Icon(Icons.location_on),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => setState(() => clinicAddress = val),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter clinic address"
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ---------------------- NEXT BUTTON ----------------------
              if (isFormFilled)
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
                  onPressed: () async {
                    setState(() => showValidationErrors = true);

                    if (_formKey.currentState!.validate()) {
                      await _saveToHive();
                      Navigator.pushNamed(
                        context,
                        AppRoutes.doctorApplyDocuments,
                      );
                    }
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
