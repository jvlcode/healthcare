import 'package:flutter/material.dart';

class ApplicationStep2ClinicDetailsScreen extends StatefulWidget {
  const ApplicationStep2ClinicDetailsScreen({super.key});

  @override
  State<ApplicationStep2ClinicDetailsScreen> createState() =>
      _ApplicationStep2ClinicDetailsScreenState();
}

class _ApplicationStep2ClinicDetailsScreenState
    extends State<ApplicationStep2ClinicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String clinicName = '', clinicAddress = '', specialization = '';

  bool get isFormFilled => clinicName.isNotEmpty && clinicAddress.isNotEmpty;

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
          child: Column(
            children: [
              const Text(
                "Enter your clinic information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Clinic Name
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Clinic Name",
                      hintText: "ABC Clinic",
                      icon: Icon(Icons.local_hospital),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        clinicName = val;
                      });
                    },
                    validator: (val) =>
                        val!.isEmpty ? "Please enter clinic name" : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Clinic Address
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Clinic Address",
                      hintText: "123 Main Street, City",
                      icon: Icon(Icons.location_on),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        clinicAddress = val;
                      });
                    },
                    validator: (val) =>
                        val!.isEmpty ? "Please enter address" : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Specialization (optional)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Specialization (optional)",
                      hintText: "Cardiology, Pediatrics...",
                      icon: Icon(Icons.medical_services),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        specialization = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Navigator.pushNamed(
                            context,
                            '/doctor/apply/documents',
                          );
                        }
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
      ),
    );
  }
}
