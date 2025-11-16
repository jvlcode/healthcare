import 'package:flutter/material.dart';
import 'package:healthcare/features/doctor/application/welcome.dart';
import 'package:healthcare/features/doctor/appointments_screen.dart';
import 'package:healthcare/features/doctor/application_status_screen.dart';
import 'package:healthcare/features/doctor/slot_management_screen.dart';
import 'step1.dart';
import 'step2.dart';
import 'step3.dart';
import 'step4.dart';

Map<String, WidgetBuilder> applicationRoutes = {
  '/doctor/apply': (context) => const DoctorApplicationWelcomeScreen(),
  '/doctor/apply/personal': (context) =>
      const ApplicationStep1PersonalInfoScreen(),
  '/doctor/apply/clinic': (context) =>
      const ApplicationStep2ClinicDetailsScreen(),
  '/doctor/apply/documents': (context) =>
      const ApplicationStep3DocumentUploadScreen(),
  '/doctor/apply/review': (context) =>
      const ApplicationStep4ReviewSubmitScreen(),
  '/doctor/apply/status': (context) => const ApplicationStatusScreen(),
  '/doctor/slot': (context) => const DoctorSlotManagementScreen(),
  '/doctor/home': (context) => const DoctorAppointmentsScreen(),
};
