import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthcare/app/app.dart';
import 'package:healthcare/app/app_theme.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/utils/toast_util.dart';
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
  bool serverUnreachable = false;
  bool shouldRedirectToLogin = false;

  @override
  void initState() {
    super.initState();
    bootstrap();
  }

  Future<void> bootstrap() async {
    print("🔵 BOOTSTRAP STARTED");

    try {
      // ---------------------------
      // 1. Initialize Hive Boxes
      // ---------------------------
      await _initHive();

      // ---------------------------
      // 2. Server Reachability
      // ---------------------------
      final reachability = context.read<ReachabilityController>();

      final serverReachable = await AuthService().isServerReachable();
      reachability.updateReachability(serverReachable);

      if (!serverReachable) {
        print("⚠️ Server unreachable — skip validation, load cached user");

        // Load cached user only
        user = await SessionManager.getCurrentUser();
      } else {
        // ---------------------------
        // 3. Initialize Session with validation
        // ---------------------------
        user = await SessionManager.initializeSession(validate: true);
      }
      // ---------------------------
      // 4. Socket Init
      // ---------------------------
      if (user != null) {
        SocketService().init();
      } else {
        if (SessionManager.sessionInvalid) {
          ToastUtil.error(
            "Session Invalid...Please Login",
            gravity: ToastGravity.TOP,
          );
        }
        if (!mounted) return;
        setState(() {
          shouldRedirectToLogin = true;
          isLoading = false;
        });
        print("⚠️ Skipping socket init — no logged-in user.");
      }
    } catch (e, stack) {
      print("❌ Bootstrap error: $e");
      print(stack);
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _initHive() async {
    await Hive.openBox('auth');

    // ❗ If you always delete the doctor_application box,
    // just recreate instead of open + delete + open
    await Hive.deleteBoxFromDisk('doctor_application');
    await Hive.openBox('doctor_application');

    await Hive.openBox('settings');

    print("🟢 Hive Boxes Ready");
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(theme: AppTheme.light, home: SplashScreen());
    }

    return MyApp(
      user,
    ); // MyApp already contains MaterialApp// MyApp already wraps MaterialApp with theme
  }
}
