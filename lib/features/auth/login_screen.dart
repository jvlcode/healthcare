import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/auth_service.dart';
import 'package:hive/hive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.teal, width: 1.5),
      ),
      labelStyle: const TextStyle(fontSize: 15),
    );
  }

  void _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final res = await _authService.login(email, password);

      if (res['success'] == true) {
        // Extract data safely
        final data = res['data'] as Map<String, dynamic>?;
        if (data == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid login response")),
          );
          return;
        }

        final userJson = data['user'] as Map<String, dynamic>?;
        final accessToken = data['accessToken']?.toString();
        final refreshToken = data['refreshToken']?.toString() ?? '';

        if (userJson != null && accessToken != null) {
          final user = User.fromJson(userJson);

          // Save session
          // await SessionManager.saveSession(user, accessToken, refreshToken);
          final secureStorage = FlutterSecureStorage();
          await secureStorage.write(key: 'access_token', value: accessToken);
          await secureStorage.write(key: 'refresh_token', value: refreshToken);

          final userBox = await Hive.openBox('userBox');
          await userBox.put('user', user.toJson()); // Ensure User has toJson()

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successful")));

          // Navigate based on role
          if (user.role.toUpperCase() == 'DOCTOR') {
            Navigator.pushReplacementNamed(context, '/doctor');
          } else {
            Navigator.pushReplacementNamed(context, '/user');
          }
          // Navigator.pushReplacementNamed(context, '/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid login credentials")),
          );
        }
      } else {
        final msg = res['message'] ?? 'Login failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $msg")));
      }
    } catch (e) {
      print('Login Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network / Server error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const CircleAvatar(
                radius: 50,
                // backgroundImage: AssetImage('assets/health_logo.png'),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Email or Phone', Icons.person),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter email or phone' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: _inputDecoration('Password', Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Enter valid password' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _loginUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, "/register");
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Forgot password clicked")),
                  );
                },
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
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
