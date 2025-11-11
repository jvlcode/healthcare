// register_screen.dart
import 'package:flutter/material.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // step 0
    GlobalKey<FormState>(), // step 1
    GlobalKey<FormState>(), // step 2
  ];

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // UI state
  bool _isDoctor = false;
  bool _otpSent = false;
  bool _isVerifying = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _isLoading = false;

  // --- Input decoration used across fields
  InputDecoration _inputDecoration(String label, IconData icon) {
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
      labelStyle: const TextStyle(fontSize: 15),
    );
  }

  // --- handle next; validate only current step
  void _nextStep() {
    final form = _formKeys[_step].currentState!;
    if (!form.validate()) return;

    if (_step == 1 && _otpSent == false) {
      // If on phone step and OTP not sent, require sending OTP first
      _sendOtp();
      return;
    }

    if (_step == 1 && _otpSent == true) {
      // If OTP field exists validate; for this flow we'll require verification before proceeding
      if (_otpController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Enter OTP or resend")));
        return;
      }
      _verifyOtp();
      return;
    }

    if (_step < 2) {
      setState(() => _step++);
      return;
    }

    // final step -> register
    _registerUser();
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  // --- simulated OTP send (replace with backend /auth/send-otp)
  void _sendOtp() {
    if (_phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 10-digit phone")),
      );
      return;
    }
    // Ideally call backend to send OTP here.
    setState(() => _otpSent = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("OTP sent (simulated)")));
  }

  // --- simulated verify (replace with backend /auth/verify-otp)
  void _verifyOtp() {
    setState(() => _isVerifying = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isVerifying = false;
        _step = 2; // move to final step
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone verified (simulated)")),
      );
    });
  }

  // --- register API call
  Future<void> _registerUser() async {
    final form = _formKeys[_step].currentState!;
    if (!form.validate()) return;

    // For doctor, we may want specialization and qualifications (optional fields)
    final role = _isDoctor ? "DOCTOR" : "PATIENT";

    setState(() => _isLoading = true);

    final user = User(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      role: role,
    );

    final password = _passwordController.text.trim();

    try {
      // final res = await http.post(
      //   uri,
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode(body),
      // );
      final authService = AuthService();
      final res = await authService.register(user, password);

      if (res['success']) {
        final data = res['data'] as Map<String, dynamic>?;
        if (data != null) {
          final userJson = data['user'] as Map<String, dynamic>?;
          final accessToken = data['accessToken']?.toString();
          final refreshToken = data['refreshToken']?.toString() ?? '';

          if (userJson != null && accessToken != null) {
            final registeredUser = User.fromJson(userJson);

            final secureStorage = FlutterSecureStorage();
            await secureStorage.write(key: 'access_token', value: accessToken);
            await secureStorage.write(
              key: 'refresh_token',
              value: refreshToken,
            );

            final userBox = await Hive.openBox('userBox');
            await userBox.put('user', registeredUser.toJson());

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registration successful")),
            );

            Navigator.pushReplacementNamed(
              context,
              registeredUser.role.toUpperCase() == 'DOCTOR'
                  ? '/doctor'
                  : '/user',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid registration response")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid registration response")),
          );
        }
      } else {
        final msg =
            res['message'] ??
            (res['message'] != null
                ? _mapErrorsToString(res['message'])
                : "Registration failed");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $msg")));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _mapErrorsToString(dynamic errors) {
    // errors may be array or object; try best-effort mapping
    if (errors is List) {
      return errors
          .map((e) {
            if (e is Map && e['message'] != null) return e['message'];
            return e.toString();
          })
          .join(", ");
    } else if (errors is Map && errors['message'] != null)
      return errors['message'];
    return errors.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Step widgets - use per-step Form keyed by _formKeys[index]
    final step0 = Form(
      key: _formKeys[0],
      child: Column(
        children: [
          // Role selector
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text("Patient"),
                  selected: !_isDoctor,
                  onSelected: (v) =>
                      setState(() => _isDoctor = !v ? true : false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Text("Doctor"),
                  selected: _isDoctor,
                  onSelected: (v) => setState(() => _isDoctor = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Full Name', Icons.person),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration('Email', Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter email';
              if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v.trim()))
                return 'Enter valid email';
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
            controller: _phoneController,
            decoration: _inputDecoration('Phone Number', Icons.phone),
            keyboardType: TextInputType.phone,
            validator: (v) => v == null || v.trim().length != 10
                ? 'Enter 10-digit phone'
                : null,
          ),
          const SizedBox(height: 12),
          if (!_otpSent)
            ElevatedButton.icon(
              onPressed: _sendOtp,
              icon: const Icon(Icons.sms),
              label: const Text("Send OTP"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else ...[
            TextFormField(
              controller: _otpController,
              decoration: _inputDecoration('Enter OTP', Icons.verified),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Enter OTP' : null,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Verify OTP"),
            ),
          ],
        ],
      ),
    );

    // final step: if doctor collect specialization & qualifications before passwords
    final step2 = Form(
      key: _formKeys[2],
      child: Column(
        children: [
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: _inputDecoration('Password', Icons.lock).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (v) =>
                v == null || v.length < 6 ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmVisible,
            decoration: _inputDecoration('Confirm Password', Icons.lock_outline)
                .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _isConfirmVisible = !_isConfirmVisible),
                  ),
                ),
            validator: (v) =>
                v != _passwordController.text ? 'Passwords do not match' : null,
          ),
        ],
      ),
    );

    // Main scaffold
    return Scaffold(
      appBar: AppBar(title: const Text('Register'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: ValueKey<int>(_step),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // step indicator simple
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    height: 8,
                    width: _step == i ? 26 : 12,
                    decoration: BoxDecoration(
                      color: _step >= i
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              // header text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _step == 0
                      ? 'Who are you?'
                      : (_step == 1 ? 'Verify your phone' : 'Set a password'),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_step == 0) step0,
                      if (_step == 1) step1,
                      if (_step == 2) step2,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _step < 2 ? 'Next' : 'Register',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 12),
              if (_step > 0)
                TextButton(onPressed: _prevStep, child: const Text('Back')),
            ],
          ),
        ),
      ),
    );
  }
}
