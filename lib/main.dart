// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:healthcare/app/app.dart';
import 'package:healthcare/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final secureStorage = FlutterSecureStorage();
  final accessToken = await secureStorage.read(key: 'access_token');

  User? user;
  final userBox = await Hive.openBox('userBox');
  final userJson = userBox.get('user');
  if (accessToken != null && userJson != null) {
    user = User.fromJson(Map<String, dynamic>.from(userJson));
  }

  runApp(MyApp(user: user));
}
