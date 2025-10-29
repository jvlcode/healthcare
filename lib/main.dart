import 'package:flutter/material.dart';
import 'package:healthcare/features/doctor/application_form_screen.dart';
import 'package:healthcare/features/user/appointments/appointments_screen.dart';
import 'package:healthcare/features/user/appointments/videocall_history_screen.dart';
import 'package:healthcare/auth/register_screen.dart';
import 'package:healthcare/core/app_theme.dart';
import 'package:healthcare/core/main_scaffold.dart';
import 'package:healthcare/features/user/dashboard/faq_screen.dart';
import 'package:healthcare/features/user/dashboard/home_screen.dart';
import 'package:healthcare/features/user/profile/settings_screen.dart';

void main() {
  const bool isDoctorMode = true; // 🔁 change to false for user mode
  runApp(MyApp(isDoctorMode: isDoctorMode));
}

class MyApp extends StatelessWidget {
  final bool isDoctorMode;
  const MyApp({super.key, required this.isDoctorMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: isDoctorMode ? '/doctor/application' : '/',
      routes: {
        // --- User routes ---
        '/': (context) => const MainScaffold(),
        '/home': (context) => const HomeScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/faqs': (context) => const FAQScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/videocallhistory': (context) => const VideoCallHistoryScreen(),

        // --- Doctor routes ---
        '/doctor/application': (context) => const ApplicationFormScreen(),
        '/doctor/terms': (context) => const TermsAckScreen(),
        '/doctor/certificate': (context) => const CertificateUploadScreen(),
        '/doctor/slots': (context) => const SlotManagementScreen(),
        // '/doctor/slots/edit': (context) => const SlotEditScreen(),
      },
    );
  }
}
