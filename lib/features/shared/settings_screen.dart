import 'package:flutter/material.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/utils/navigation_util.dart';
import 'package:healthcare/features/shared/change_password_screen.dart';
import 'package:healthcare/features/shared/edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF01312F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Account"),
          _settingsTile(
            icon: Icons.person,
            title: "Edit Profile",
            subtitle: "Update your name, email, and photo",
            onTap: () async {
              final user = await SessionManager.getCurrentUser();
              navigateSlideLeft(
                context,
                page: EditProfileScreen(prefilledUser: user),
              );
            },
          ),
          _settingsTile(
            icon: Icons.lock,
            title: "Change Password",
            subtitle: "Update your password securely",
            onTap: () {
              navigateSlideLeft(context, page: ChangePasswordScreen());
            },
          ),

          // const SizedBox(height: 20),
          // _sectionTitle("Preferences"),
          // SwitchListTile(
          //   value: notificationsEnabled,
          //   activeColor: const Color(0xFF01312F),
          //   title: const Text("Push Notifications"),
          //   subtitle: const Text("Receive alerts for appointments and calls"),
          //   onChanged: (val) {
          //     setState(() => notificationsEnabled = val);
          //   },
          // ),
          // SwitchListTile(
          //   value: darkMode,
          //   activeColor: const Color(0xFF01312F),
          //   title: const Text("Dark Mode"),
          //   subtitle: const Text("Use dark theme for better night reading"),
          //   onChanged: (val) {
          //     setState(() => darkMode = val);
          //   },
          // ),
          const SizedBox(height: 20),
          _sectionTitle("Support"),
          _settingsTile(
            icon: Icons.help_outline,
            title: "Help Center",
            subtitle: "FAQs and support articles",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.feedback_outlined,
            title: "Send Feedback",
            subtitle: "Let us know your thoughts",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            subtitle: "Read how we handle your data",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // 🔹 Section title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF01312F),
        ),
      ),
    );
  }

  // 🔹 Reusable settings tile
  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF01312F)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 13))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
