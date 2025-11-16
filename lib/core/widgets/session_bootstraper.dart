import 'package:flutter/material.dart';
import 'package:healthcare/app/app.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/widgets/splash_screen.dart';
import 'package:healthcare/models/doctor_application_form_model.dart';
import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/auth_service.dart';
import 'package:hive/hive.dart';

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
    print("🔵 BOOTSTRAP STARTED");

    // Register adapters if needed
    // Hive.registerAdapter(DoctorApplicationAdapter());
    // Hive.registerAdapter(UserAdapter());

    // OPEN ALL REQUIRED BOXES BEFORE ANY ROUTING
    await Hive.openBox('auth');
    await Hive.deleteBoxFromDisk('doctor_application');
    await Hive.openBox('doctor_application');
    await Hive.openBox('settings');

    print("🟢 Hive Boxes Opened");

    // Now safely initialize session
    user = await SessionManager.initializeSession(validateInBackground: true);

    print("🟢 Session Loaded, user: $user");

    if (!mounted) return;
    setState(() => isLoading = false);

    // Optional server reachability check
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reachable = await AuthService().isServerReachable();
      if (!reachable && mounted) {
        setState(() => serverUnreachable = true);
        print("⚠️ Server unreachable — using offline session");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(home: SplashScreen());
    }

    return MyApp(user: user);
  }
}
