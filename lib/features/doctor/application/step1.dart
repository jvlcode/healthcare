import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:hive/hive.dart';
import 'package:healthcare/models/doctor_application_form_model.dart';

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

  // ADDED CONTROLLERS
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUser();
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

  bool get isFormFilled =>
      fullNameController.text.isNotEmpty &&
      emailController.text.isNotEmpty &&
      phoneController.text.isNotEmpty;

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
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      hintText: "John Doe",
                      icon: Icon(Icons.person),
                      border: InputBorder.none,
                    ),
                    validator: (val) =>
                        val!.isEmpty ? "Please enter your name" : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // EMAIL
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "example@mail.com",
                      icon: Icon(Icons.email),
                      border: InputBorder.none,
                    ),
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
                ),
              ),
              const SizedBox(height: 20),

              // PHONE
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      hintText: "9876543210",
                      icon: Icon(Icons.phone),
                      border: InputBorder.none,
                    ),
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
                ),
              ),
              const SizedBox(height: 20),

              // QUALIFICATION
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: qualificationController,
                    decoration: const InputDecoration(
                      labelText: "Qualification (MBBS, MD...)",
                      icon: Icon(Icons.school),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // SPECIALIZATION
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: specializationController,
                    decoration: const InputDecoration(
                      labelText: "Specialization",
                      icon: Icon(Icons.medical_services),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // EXPERIENCE
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: experienceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Years of Experience",
                      icon: Icon(Icons.timeline),
                      border: InputBorder.none,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return null;
                      if (int.tryParse(val) == null) {
                        return "Experience must be a number";
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // NEXT BUTTON
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
                    if (_formKey.currentState!.validate()) {
                      await _saveToHive();
                      Navigator.pushNamed(context, AppRoutes.doctorApplyClinic);
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
