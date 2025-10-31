import 'package:flutter/material.dart';

class ApplicationStep1PersonalInfoScreen extends StatefulWidget {
  const ApplicationStep1PersonalInfoScreen({super.key});

  @override
  State<ApplicationStep1PersonalInfoScreen> createState() =>
      _ApplicationStep1PersonalInfoScreenState();
}

class _ApplicationStep1PersonalInfoScreenState
    extends State<ApplicationStep1PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '', email = '', phone = '';

  bool get isFormFilled =>
      name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty;

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
                "Please fill in your personal information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Name field
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      hintText: "John Doe",
                      icon: Icon(Icons.person),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        name = val;
                      });
                    },
                    validator: (val) =>
                        val!.isEmpty ? "Please enter your name" : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email field
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "example@mail.com",
                      icon: Icon(Icons.email),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                    validator: (val) =>
                        val!.isEmpty ? "Please enter your email" : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Phone field
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      hintText: "+91 9876543210",
                      icon: Icon(Icons.phone),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (val) {
                      setState(() {
                        phone = val;
                      });
                    },
                    validator: (val) =>
                        val!.isEmpty ? "Please enter phone number" : null,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Next button (only enabled when all fields are filled)
              if (isFormFilled)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01312F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.pushNamed(context, '/doctor/apply/clinic');
                      }
                    },
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Bright text
                      ),
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
