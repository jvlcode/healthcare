import 'package:flutter/material.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/core/widgets/session_bootstraper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ReachabilityController(),
      child: const SessionBootstrapper(),
    ),
  );
}
