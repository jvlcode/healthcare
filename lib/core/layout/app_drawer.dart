import 'package:flutter/material.dart';
import 'package:healthcare/app/session/session_manager.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 🌟 Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),

            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Color(0xFF01312F)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Logesh',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'logesh@example.com',
                      style: TextStyle(color: Colors.black45, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🧭 Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(
                  icon: Icons.video_call,
                  label: 'Video Call History',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/videocallhistory");
                  },
                ),
                _drawerItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/settings");
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                _drawerItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  iconColor: Colors.redAccent,
                  onTap: () async {
                    await SessionManager.clearSession();
                    // Remove all routes and navigate to login
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          // 📦 Footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'v1.0.0 • Wellness App',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF01312F),
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
