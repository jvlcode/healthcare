import 'package:flutter/material.dart';
import 'package:healthcare/app/app.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final user = await SessionManager.initializeSession();

  runApp(MyApp(user: user));
}
