// lib/core/constants/api_constants.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppUrls {
  static String baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://default.com';
  // or your production URL
  static String apiUrl = '$baseUrl/api/v1';
}
