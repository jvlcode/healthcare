// lib/app/app_routes.dart
import 'package:flutter/material.dart';
import 'package:healthcare/features/auth/forgot_password.dart';
import 'package:healthcare/features/auth/login_screen.dart';
import 'package:healthcare/features/auth/register_screen.dart';
import 'package:healthcare/features/auth/reset_password.dart';
import 'package:healthcare/features/doctor/doctor_home_screen.dart';
import 'package:healthcare/features/user/user_home_screen.dart';
import 'package:healthcare/features/user/appointments/appointments_screen.dart';
import 'package:healthcare/features/user/appointments/videocall_history_screen.dart';
import 'package:healthcare/features/user/dashboard/faq_screen.dart';
import 'package:healthcare/features/user/profile/settings_screen.dart';
import 'package:healthcare/features/doctor/application/application_routes.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const userHome = '/user';
  static const doctorHome = '/doctor';
  static const appointments = '/appointments';
  static const faqs = '/faqs';
  static const settings = '/settings';
  static const videocallHistory = '/videocallhistory';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  static final routes = <String, WidgetBuilder>{
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    userHome: (context) => UserHomeScreen(),
    doctorHome: (context) => DoctorHomeScreen(),
    appointments: (context) => const AppointmentsScreen(),
    faqs: (context) => const FAQScreen(),
    settings: (context) => const SettingsScreen(),
    videocallHistory: (context) => const VideoCallHistoryScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    resetPassword: (context) => const ResetPasswordScreen(),
    ...applicationRoutes,
  };
}
