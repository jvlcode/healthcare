import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:hive/hive.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;

  final _formKeys = [
    GlobalKey<FormState>(), // Step 0
    GlobalKey<FormState>(), // Step 1
    GlobalKey<FormState>(), // Step 2
  ];

  // Controllers
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  // UI State
  bool _isDoctor = false;
  bool _otpSent = false;
  bool _isVerifying = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _loading = false;

  InputDecoration _field(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 1.5,
        ),
      ),
    );
  }

  void _nextStep() {
    final form = _formKeys[_step].currentState!;
    if (!form.validate()) return;

    if (_step == 1 && !_otpSent) {
      _sendOtp();
      return;
    }

    if (_step == 1 && _otpSent) {
      _verifyOtp();
      return;
    }

    if (_step < 2) {
      setState(() => _step++);
      return;
    }

    _registerUser();
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  void _sendOtp() {
    if (_phone.text.trim().length != 10) {
      _toast("Enter valid 10-digit phone");
      return;
    }
    setState(() => _otpSent = true);
    _toast("OTP Sent (Simulated)");
  }

  void _verifyOtp() {
    setState(() => _isVerifying = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isVerifying = false;
        _step = 2;
      });
      _toast("Phone Verified (Simulated)");
    });
  }

  Future<void> _registerUser() async {
    final form = _formKeys[_step].currentState!;
    if (!form.validate()) return;

    setState(() => _loading = true);

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      role: _isDoctor ? "DOCTOR" : "PATIENT",
    );

    final password = _password.text.trim();

    try {
      await NetworkHelper().safeCall(
        context,
        () => AuthService().register(user, password),
        onSuccess: (res) async {
          final data = res['data'];
          if (data == null || data['user'] == null) {
            _toast("Invalid API response");
            return;
          }

          final token = data['accessToken']?.toString() ?? '';
          final refresh = data['refreshToken']?.toString() ?? '';
          final json = data['user'];
          final registeredUser = User.fromJson(json);

          // Save securely
          // const store = FlutterSecureStorage();
          // await store.write(key: 'access_token', value: token);
          // await store.write(key: 'refresh_token', value: refresh);

          // final box = await Hive.openBox('userBox');
          // await box.put('user', registeredUser.toJson());
          SessionManager.saveSession(json, token, refresh);

          _toast("Registration Successful");

          Navigator.pushReplacementNamed(
            context,
            registeredUser.role == "DOCTOR"
                ? AppRoutes.doctorHome
                : AppRoutes.userHome,
          );
        },
        onApiError: (msg) => _toast(msg.toString()),
        onException: (e) => _toast("Error: $e"),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Step widgets kept exactly the same to not affect UI ---
    final step0 = Form(
      key: _formKeys[0],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text("Patient"),
                  selected: !_isDoctor,
                  onSelected: (v) => setState(() => _isDoctor = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Text("Doctor"),
                  selected: _isDoctor,
                  onSelected: (v) => setState(() => _isDoctor = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _name,
            decoration: _field("Full Name", Icons.person),
            validator: (v) => v!.isEmpty ? "Enter name" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            decoration: _field("Email", Icons.email),
            validator: (v) {
              if (v!.isEmpty) return "Enter email";
              if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v)) {
                return "Enter valid email";
              }
              return null;
            },
          ),
        ],
      ),
    );

    final step1 = Form(
      key: _formKeys[1],
      child: Column(
        children: [
          TextFormField(
            controller: _phone,
            decoration: _field("Phone", Icons.phone),
            validator: (v) => v!.length == 10 ? null : "Enter 10-digit phone",
          ),
          const SizedBox(height: 12),
          if (!_otpSent)
            ElevatedButton.icon(
              onPressed: _sendOtp,
              icon: const Icon(Icons.sms),
              label: const Text("Send OTP"),
            )
          else
            Column(
              children: [
                TextFormField(
                  controller: _otp,
                  decoration: _field("Enter OTP", Icons.verified),
                  validator: (v) => v!.isEmpty ? "Enter OTP" : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Verify OTP"),
                ),
              ],
            ),
        ],
      ),
    );

    final step2 = Form(
      key: _formKeys[2],
      child: Column(
        children: [
          TextFormField(
            controller: _password,
            obscureText: !_isPasswordVisible,
            decoration: _field("Password", Icons.lock).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (v) => v!.length < 6 ? "Minimum 6 characters" : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirm,
            obscureText: !_isConfirmVisible,
            decoration: _field("Confirm Password", Icons.lock).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _isConfirmVisible = !_isConfirmVisible),
              ),
            ),
            validator: (v) =>
                v != _password.text ? "Passwords don't match" : null,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Register"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: ValueKey(_step),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    height: 8,
                    width: _step == i ? 26 : 12,
                    decoration: BoxDecoration(
                      color: _step >= i
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: [step0, step1, step2][_step],
                ),
              ),

              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _nextStep,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_step < 2 ? "Next" : "Register"),
              ),
              if (_step > 0)
                TextButton(onPressed: _prevStep, child: const Text("Back")),
            ],
          ),
        ),
      ),
    );
  }
}
