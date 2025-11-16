import 'package:flutter/material.dart';

// Auth
import 'package:healthcare/features/auth/login_screen.dart';
import 'package:healthcare/features/auth/register_screen.dart';
import 'package:healthcare/features/auth/forgot_password.dart';
import 'package:healthcare/features/auth/reset_password.dart';

// Doctor
import 'package:healthcare/features/doctor/doctor_home_screen.dart';
import 'package:healthcare/features/doctor/application_status_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';
import 'package:healthcare/features/doctor/application/welcome.dart';
import 'package:healthcare/features/doctor/application/step1.dart';
import 'package:healthcare/features/doctor/application/step2.dart';
import 'package:healthcare/features/doctor/application/step3.dart';
import 'package:healthcare/features/doctor/application/step4.dart';

// User
import 'package:healthcare/features/user/user_home_screen.dart';
import 'package:healthcare/features/user/appointments/user_appointments_screen.dart';
import 'package:healthcare/features/user/appointments/videocall_history_screen.dart';
import 'package:healthcare/features/user/dashboard/faq_screen.dart';
import 'package:healthcare/features/user/profile/settings_screen.dart';

class AppRoutes {
  // Auth
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  // User
  static const userHome = '/user';
  static const appointments = '/appointments';
  static const videocallHistory = '/videocallhistory';
  static const faqs = '/faqs';
  static const settings = '/settings';

  // Doctor
  static const doctorHome = '/doctor/home';
  static const doctorApply = '/doctor/apply';
  static const doctorApplyPersonal = '/doctor/apply/personal';
  static const doctorApplyClinic = '/doctor/apply/clinic';
  static const doctorApplyDocuments = '/doctor/apply/documents';
  static const doctorApplyReview = '/doctor/apply/review';
  static const doctorApplyStatus = '/doctor/apply/status';
  static const doctorSlot = '/doctor/slot';
  static const doctorWrapper = '/doctor';

  static final routes = <String, WidgetBuilder>{
    // Auth
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    forgotPassword: (context) => ForgotPasswordScreen(),
    resetPassword: (context) => ResetPasswordScreen(),

    // User
    userHome: (context) => UserHomeScreen(),
    appointments: (context) => UserAppointmentsScreen(),
    videocallHistory: (context) => VideoCallHistoryScreen(),
    faqs: (context) => FAQScreen(),
    settings: (context) => SettingsScreen(),

    // Doctor
    // doctorWrapper: (context) => DoctorWrapper(),
    doctorHome: (context) => DoctorHomeScreen(),
    doctorApply: (context) => DoctorApplicationWelcomeScreen(),
    doctorApplyPersonal: (context) => ApplicationStep1PersonalInfoScreen(),
    doctorApplyClinic: (context) => ApplicationStep2ClinicDetailsScreen(),
    doctorApplyDocuments: (context) => ApplicationStep3DocumentUploadScreen(),
    doctorApplyReview: (context) => ApplicationStep4ReviewSubmitScreen(),
    doctorApplyStatus: (context) => ApplicationStatusScreen(),
    doctorSlot: (context) => DoctorSlotManagementScreen(),
  };
}
