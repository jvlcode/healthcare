// lib/features/doctor/doctor_wrapper.dart
import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/widgets/splash_screen.dart';
import 'package:healthcare/models/user_model.dart';

class DoctorWrapper extends StatefulWidget {
  const DoctorWrapper({super.key});

  @override
  State<DoctorWrapper> createState() => _DoctorWrapperState();
}

class _DoctorWrapperState extends State<DoctorWrapper> {
  @override
  void initState() {
    super.initState();
    _checkApproval();
  }

  Future<void> _checkApproval() async {
    final user = await SessionManager.getCurrentUser();

    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else if (user.doctor != null && user.doctor!.approved == true) {
      Navigator.pushReplacementNamed(context, AppRoutes.doctorHome);
    } else if (user.doctor != null && user.doctor!.approved == false) {
      Navigator.pushReplacementNamed(context, AppRoutes.doctorApplyStatus);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.doctorApply);
    }
  }

  @override
  Widget build(BuildContext context) {
    // While waiting for async check, show loader
    return const Scaffold(body: SplashScreen());
  }
}
