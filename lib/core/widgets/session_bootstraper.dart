import 'package:flutter/material.dart';
import 'package:healthcare/app/app.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/widgets/splash_screen.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/auth_service.dart';

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
    bootstrapSession();
  }

  Future<void> bootstrapSession() async {
    user = await SessionManager.initializeSession(validateInBackground: true);
    setState(() => isLoading = false);

    // ✅ Defer server check until after UI is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reachable = await AuthService().isServerReachable();
      if (!reachable && mounted) {
        setState(() => serverUnreachable = true);
        print("⚠️ Server unreachable — continuing with cached session");
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
