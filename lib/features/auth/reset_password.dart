import 'package:flutter/material.dart';
import 'package:healthcare/services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _tokenVerified = false;

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

  Future<void> _verifyToken() async {
    final token = _tokenController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(token)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 6-digit token")),
      );
      return;
    }

    setState(() => _tokenVerified = true);
  }

  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final res = await authService.resetPassword(
        _tokenController.text.trim(),
        _passwordController.text.trim(),
      );

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successful")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${res['message'] ?? 'Unknown error'}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const CircleAvatar(radius: 50),
              const SizedBox(height: 40),

              if (!_tokenVerified) ...[
                TextFormField(
                  controller: _tokenController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Reset Token', Icons.vpn_key),
                  validator: (v) => v == null || !RegExp(r'^\d{6}$').hasMatch(v)
                      ? 'Enter 6-digit token'
                      : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyToken,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Verify Token",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],

              if (_tokenVerified) ...[
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('New Password', Icons.lock),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: _inputDecoration(
                    'Confirm Password',
                    Icons.lock_outline,
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitReset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Reset Password",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
