import 'package:flutter/material.dart';
import 'package:healthcare/appointments/booking_screen.dart';
import 'package:healthcare/appointments/appointments_screen.dart';
import 'package:healthcare/appointments/videocall_history_screen.dart';
import 'package:healthcare/auth/register_screen.dart';
import 'package:healthcare/core/app_theme.dart';
import 'package:healthcare/core/main_scaffold.dart';
import 'package:healthcare/dashboard/faq_screen.dart';
import 'package:healthcare/dashboard/home_screen.dart';
import 'package:healthcare/doctors/chat_screen.dart';
import 'package:healthcare/doctors/videocall_screen.dart';
import 'package:healthcare/user/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScaffold(),
        '/home': (context) => const HomeScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/faqs': (context) => const FAQScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/videocallhistory': (context) => const VideoCallHistoryScreen(),
      },
    );
  }
}
