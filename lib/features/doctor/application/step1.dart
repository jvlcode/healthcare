import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:hive/hive.dart';

class ApplicationStep1PersonalInfoScreen extends StatefulWidget {
  const ApplicationStep1PersonalInfoScreen({super.key});

  @override
  State<ApplicationStep1PersonalInfoScreen> createState() =>
      _ApplicationStep1PersonalInfoScreenState();
}

class _ApplicationStep1PersonalInfoScreenState
    extends State<ApplicationStep1PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  User? user;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    getUser();
    _setupListeners();
  }

  /// Listen to all fields to refresh button state
  void _setupListeners() {
    fullNameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    qualificationController.addListener(_validateForm);
    specializationController.addListener(_validateForm);
    experienceController.addListener(_validateForm);
  }

  Future<void> getUser() async {
    final currentUser = await SessionManager.getCurrentUser();
    if (mounted && currentUser != null) {
      setState(() {
        user = currentUser;
        fullNameController.text = currentUser.name ?? "";
        emailController.text = currentUser.email ?? "";
        phoneController.text = currentUser.phone ?? "";
      });
    }
  }

  /// Check if all fields have values
  void _validateForm() {
    setState(() {
      isFormValid =
          fullNameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          qualificationController.text.isNotEmpty &&
          specializationController.text.isNotEmpty &&
          experienceController.text.isNotEmpty;
    });
  }

  Future<void> _saveToHive() async {
    final box = Hive.box('doctor_application');

    final Map<String, dynamic> step1Data = {
      'fullName': fullNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'qualifications': qualificationController.text,
      'specialization': specializationController.text,
      'experienceYears': int.tryParse(experienceController.text) ?? 0,
    };

    await box.put('step1PersonalInfo', step1Data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 1: Personal Information"),
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
                "Please provide your personal details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // FULL NAME
              _buildCardField(
                controller: fullNameController,
                label: "Full Name",
                hint: "John Doe",
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? "Please enter your name" : null,
              ),
              const SizedBox(height: 20),

              // EMAIL
              _buildCardField(
                controller: emailController,
                label: "Email",
                hint: "example@mail.com",
                icon: Icons.email,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(
                    r"^[a-zA-Z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$",
                  ).hasMatch(val)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // PHONE
              _buildCardField(
                controller: phoneController,
                label: "Phone Number",
                hint: "9876543210",
                icon: Icons.phone,
                keyboard: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter phone number";
                  }
                  if (val.length < 10) {
                    return "Phone must be at least 10 digits";
                  }
                  if (!RegExp(r"^[0-9]+$").hasMatch(val)) {
                    return "Phone must contain only digits";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // QUALIFICATION
              _buildCardField(
                controller: qualificationController,
                label: "Qualification (MBBS, MD...)",
                icon: Icons.school,
                validator: (v) =>
                    v!.isEmpty ? "Please enter qualification" : null,
              ),
              const SizedBox(height: 20),

              // SPECIALIZATION
              _buildCardField(
                controller: specializationController,
                label: "Specialization",
                icon: Icons.medical_services,
                validator: (v) =>
                    v!.isEmpty ? "Please enter specialization" : null,
              ),
              const SizedBox(height: 20),

              // EXPERIENCE
              _buildCardField(
                controller: experienceController,
                label: "Years of Experience",
                icon: Icons.timeline,
                keyboard: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Experience is required";
                  }
                  if (int.tryParse(val) == null) {
                    return "Experience must be a number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // NEXT BUTTON — ALWAYS VISIBLE BUT DISABLED
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid
                      ? const Color(0xFF01312F)
                      : Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isFormValid
                    ? () async {
                        if (_formKey.currentState!.validate()) {
                          await _saveToHive();
                          Navigator.pushNamed(
                            context,
                            AppRoutes.doctorApplyClinic,
                          );
                        }
                      }
                    : null,
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

  /// Helper widget for DRY TextFormField cards
  Widget _buildCardField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            icon: Icon(icon),
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }
}
