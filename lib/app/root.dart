import 'package:flutter/material.dart';
import 'package:healthcare/app/app_theme.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/core/widgets/session_bootstraper.dart';
import 'package:provider/provider.dart';

class MyAppRoot extends StatelessWidget {
  const MyAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReachabilityController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Healthcare",
        theme: AppTheme.light,
        home: const SessionBootstrapper(), // << This is correct place
      ),
    );
  }
}
