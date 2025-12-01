import 'package:flutter/material.dart';
import 'package:healthcare/app/app_routes.dart';
import 'package:healthcare/app/app_theme.dart';
import 'package:healthcare/models/user_model.dart';

class MyApp extends StatelessWidget {
  final User? user;
  final bool isFirstLogin;

  const MyApp(this.user, this.isFirstLogin, {super.key});

  @override
  Widget build(BuildContext context) {
    // Decide initial route
    final initialRoute = isFirstLogin
        ? AppRoutes.gettingStarted
        : user == null
        ? AppRoutes.login
        : user!.role.toUpperCase() == "DOCTOR"
        ? AppRoutes.doctorHome
        : AppRoutes.userHome;

    return MaterialApp(
      title: 'Healthcare App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
