import 'package:flutter/material.dart';
import 'package:healthcare/core/widgets/session_bootstraper.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(const SessionBootstrapper());
}
