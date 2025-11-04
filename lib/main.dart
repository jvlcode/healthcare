import 'package:flutter/material.dart';
import 'package:healthcare/features/auth/login_screen.dart';
import 'package:healthcare/features/user/appointments/appointments_screen.dart';
import 'package:healthcare/features/user/appointments/videocall_history_screen.dart';
import 'package:healthcare/features/auth/register_screen.dart';
import 'package:healthcare/core/app_theme.dart';
import 'package:healthcare/core/main_scaffold.dart';
import 'package:healthcare/features/user/dashboard/faq_screen.dart';
import 'package:healthcare/features/user/dashboard/home_screen.dart';
import 'package:healthcare/features/user/profile/settings_screen.dart';
import 'package:healthcare/features/doctor/application/application_routes.dart';

void main() {
  const bool isDoctorMode = true; // 🔁 change to false for user mode
  runApp(MyApp(isDoctorMode: isDoctorMode));
}

class MyApp extends StatelessWidget {
  final bool isDoctorMode;
  const MyApp({super.key, required this.isDoctorMode});
  // ignore: non_constant_identifier_names

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        // --- Auth routes ---
        '/login': (context) => const LoginScreen(),
        // '/register': (context) => const Regist(),
        // --- User routes ---
        '/': (context) => MainScaffold(isDoctorMode: isDoctorMode),
        '/home': (context) => const HomeScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/faqs': (context) => const FAQScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/videocallhistory': (context) => const VideoCallHistoryScreen(),

        // --- Doctor routes ---
        ...applicationRoutes,
        // '/doctor/application': (context) => const ApplicationFormScreen(),

        // '/doctor/slots/edit': (context) => const SlotEditScreen(),
      },
    );
  }
}
