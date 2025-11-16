import 'package:flutter/material.dart';
import 'package:healthcare/app/app.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/widgets/splash_screen.dart';
import 'package:healthcare/models/doctor_application_form_model.dart';
import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/auth_service.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class SessionBootstrapper extends StatefulWidget {
  const SessionBootstrapper({super.key});

  @override
  State<SessionBootstrapper> createState() => _SessionBootstrapperState();
}

class _SessionBootstrapperState extends State<SessionBootstrapper> {
  User? user;
  bool isLoading = true;
  bool serverUnreachable = false;

  @override
  void initState() {
    super.initState();
    bootstrap();
  }

  Future<void> bootstrap() async {
    bool validateInBackground = true;
    print("🔵 BOOTSTRAP STARTED");

    await Hive.openBox('auth');
    await Hive.deleteBoxFromDisk('doctor_application');
    await Hive.openBox('doctor_application');
    await Hive.openBox('settings');

    print("🟢 Hive Boxes Opened");

    // ✅ Check server first
    final reachable = await AuthService().isServerReachable();
    Provider.of<ReachabilityController>(
      context,
      listen: false,
    ).updateReachability(reachable);

    if (!reachable) {
      validateInBackground = false;
      print("⚠️ Server unreachable — skipping session init");
      if (!mounted) return;
    }

    // ✅ Safe to initialize session now
    try {
      user = await SessionManager.initializeSession(
        validateInBackground: validateInBackground,
      );
      print("🟢 Session Loaded, user: ${user?.toJson()}");
    } catch (e) {
      print("❌ Session init failed: $e");
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(home: SplashScreen());
    }

    return MyApp(user: user);
  }
}
