import 'package:flutter/material.dart';
import 'package:healthcare/app/root.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyAppRoot());
}
