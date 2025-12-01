import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/image_util.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/core/widgets/safe_avatar.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/user_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final User? prefilledUser;

  const EditProfileScreen({super.key, this.prefilledUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  File? _profileImage;
  String _profileImageUrl = '';
  bool _isSaving = false;
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = widget.prefilledUser;

    if (user != null && mounted) {
      setState(() {
        _nameController.text = user.name ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
        _bioController.text = user.bio ?? '';
        _profileImageUrl = user.profileImage ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await NetworkHelper().safeCall(
        context,
        () => _userService.updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          bio: _bioController.text.trim(),
          profileImage: _profileImage,
        ),
        onSuccess: (res) async {
          // Update user in session
          final updatedUser = User.fromJson(res['data']);
          await SessionManager.updateUser(updatedUser);

          if (mounted) {
            ToastUtil.success("Profile updated!", gravity: ToastGravity.TOP);
            Navigator.pop(context);
          }
        },
        onApiError: (res) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res['message'] ?? "Profile update failed"),
              ),
            );
          }
        },
        onException: (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
          }
        },
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01312F),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ------------------ PROFILE IMAGE ------------------
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: SafeAvatar(
                        imageUrl: ImageUtils.resolve(_profileImageUrl),
                        localFile: _profileImage,
                        size: 120,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF01312F),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ------------------ FORM FIELDS ------------------
              _buildInputCard(
                child: _buildTextField(
                  controller: _nameController,
                  label: "Full Name",
                  icon: Icons.person,
                  validator: (v) =>
                      v!.isEmpty ? "Please enter your name" : null,
                ),
              ),

              const SizedBox(height: 15),

              _buildInputCard(
                child: _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email,
                  validator: (v) =>
                      v!.isEmpty ? "Please enter your email" : null,
                ),
              ),

              const SizedBox(height: 15),

              _buildInputCard(
                child: _buildTextField(
                  controller: _phoneController,
                  label: "Phone Number",
                  icon: Icons.phone,
                  validator: (v) =>
                      v!.isEmpty ? "Please enter your phone number" : null,
                ),
              ),

              const SizedBox(height: 15),

              _buildInputCard(
                child: TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.info_outline),
                    labelText: "About",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ------------------ SAVE BUTTON ------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01312F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

  // ------------------ REUSABLE INPUT FIELD ------------------

  Widget _buildInputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: InputBorder.none,
      ),
    );
  }
}
