import 'package:flutter/material.dart';
import 'package:healthcare/app/app.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/constants/urls.dart';
import 'package:healthcare/core/widgets/splash_screen.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/auth_service.dart';
import 'package:healthcare/services/socket_service.dart';
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
  bool isFirstLogin = false;

  @override
  void initState() {
    super.initState();
    bootstrap();
  }

  Future<void> bootstrap() async {
    print("🔵 BOOTSTRAP STARTED");

    try {
      // 1. Init Hive
      await _initHive();

      print(AppUrls.apiUrl);

      // 2. Server Reachability
      final reachability = context.read<ReachabilityController>();
      final reachable = await AuthService().isServerReachable();
      reachability.updateReachability(reachable);

      // 3. Load / Validate Session
      if (reachable) {
        user = await SessionManager.initializeSession(validate: true);
      } else {
        user = await SessionManager.getCurrentUser();
      }

      // 4. Init Socket
      if (user != null) {
        SocketService().init();
      } else {
        isFirstLogin = await SessionManager.isFirstLogin();
      }
    } catch (e, st) {
      print("❌ Bootstrap error: $e");
      print(st);
    }

    if (!mounted) return;

    setState(() => isLoading = false);
  }

  Future<void> _initHive() async {
    // Auth Box
    if (!Hive.isBoxOpen('auth')) {
      await Hive.openBox('auth');
    }

    // Doctor application box — DO NOT DELETE EVERY TIME
    if (!Hive.isBoxOpen('doctor_application')) {
      await Hive.openBox('doctor_application');
    }

    // Settings Box
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }

    print("🟢 Hive Boxes Ready");
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SplashScreen();

    return MyApp(user, isFirstLogin);
  }
}
